import type { Plugin } from "@opencode-ai/plugin";
import { writeFile, mkdir } from "node:fs/promises";
import { join } from "node:path";
import { pathToFileURL } from "node:url";

type HandoffMessage = { role: "user" | "assistant"; content: string };

const MAX_MESSAGES = 30;
const MAX_MESSAGE_LEN = 500;
const MAX_CONVERSATION_CHARS = 8000;
const RECENT_PROTECT_COUNT = 8;

export const Handoff: Plugin = async ({ client, directory, $ }) => {
  const loadTool = async () => {
    // NOTE: In Nix/Home Manager setups, plugins may be loaded from the Nix store
    // (outside the `node_modules` resolution chain), so a normal import
    // `from "@opencode-ai/plugin"` can fail. Resolve it from the OpenCode config
    // directory where OpenCode installs dependencies.
    const configDir =
      (process.env.XDG_CONFIG_HOME &&
        join(process.env.XDG_CONFIG_HOME, "opencode")) ||
      (process.env.HOME && join(process.env.HOME, ".config", "opencode")) ||
      process.cwd();

    const modulePath = join(
      configDir,
      "node_modules",
      "@opencode-ai",
      "plugin",
      "dist",
      "index.js",
    );

    const mod = await import(pathToFileURL(modulePath).href);
    if (!("tool" in mod)) throw new Error("Failed to load @opencode-ai/plugin");
    return mod.tool as typeof import("@opencode-ai/plugin").tool;
  };

  const tool = await loadTool();

  const extractTextFromParts = (
    parts: Array<{ type: string; text?: string; ignored?: boolean }>,
  ) =>
    parts
      .filter((p) => p.type === "text" && !p.ignored)
      .map((p) => (p.text ?? "").trim())
      .filter(Boolean)
      .join("\n")
      .trim();

  const extractTitleFromSummary = (summary: string): string | null => {
    // Matches formats like:
    // - Title: Something
    // - **Title:** Something
    // - # Title: Something
    const patterns = [
      /^(?:#\s*)?(?:\*\*)?Title(?:\*\*)?:\s*(.+?)(?:\n|$)/i,
      /^Title:\s*(.+?)(?:\n|$)/i,
    ];

    for (const pattern of patterns) {
      const match = summary.trim().match(pattern);
      if (match?.[1]) return match[1].trim().replace(/^["']|["']$/g, "");
    }

    return null;
  };

  const titleToSlug = (title: string) => {
    const slug = title
      .toLowerCase()
      .replace(/[^a-z0-9\s-]/g, "")
      .replace(/\s+/g, "-")
      .replace(/-+/g, "-")
      .replace(/^-+|-+$/g, "");

    if (!slug) return "handoff";

    if (slug.length <= 50) return slug;
    const truncated = slug.slice(0, 50);
    return truncated.includes("-")
      ? truncated.split("-").slice(0, -1).join("-")
      : truncated;
  };

  const isLowValueChatter = (text: string) => {
    const t = text.toLowerCase().trim();
    if (t.length < 40) {
      const filler = [
        "got it",
        "sounds good",
        "ok",
        "okay",
        "let me",
        "i'll",
        "i will",
        "now i'll",
        "now i will",
        "starting with",
        "i'm going to",
        "let's start by",
      ];
      if (filler.some((p) => t.includes(p))) return true;
    }

    const meta = [
      "let me check",
      "let me see",
      "i'll check",
      "i will check",
      "i'll start by",
      "now let me",
      "let me load",
      "loading the",
      "running the",
    ];

    return t.length < 140 && meta.some((p) => t.includes(p));
  };

  const looksLikeDocDump = (text: string) => {
    const t = text.toLowerCase();
    if (text.length <= 400) return false;
    const markers = ["\n## ", "\n### ", "\n- ", "\n* "];
    const count = markers.reduce(
      (acc, m) => acc + (text.includes(m) ? 1 : 0),
      0,
    );
    if (count >= 2) return true;
    return (
      (t.includes("this skill") || t.includes("overview")) &&
      text.includes("##")
    );
  };

  const isDecisionOrSummary = (text: string) => {
    const t = text.toLowerCase();
    const keywords = [
      "decision",
      "we decided",
      "we chose",
      "we'll",
      "summary",
      "recap",
      "next steps",
      "todo",
      "to-do",
      "pending tasks",
      "completed",
      "implemented",
      "fixed",
      "resolved",
      "the plan is",
      "we will do",
    ];
    return keywords.some((k) => t.includes(k));
  };

  const isUserIntentOrQuestion = (text: string, role: string) => {
    if (role !== "user") return false;
    const t = text.toLowerCase();
    const intentKeywords = [
      "need to",
      "i want to",
      "please",
      "can you",
      "how do i",
      "so we need",
    ];
    return text.includes("?") || intentKeywords.some((k) => t.includes(k));
  };

  const filterMessagesForHandoff = (messages: HandoffMessage[]) => {
    if (messages.length === 0) return messages;

    const firstUserIdx = messages.findIndex((m) => m.role === "user");
    const annotated = messages
      .map((msg, index) => {
        const protectedMessage =
          (index === firstUserIdx && firstUserIdx !== -1) ||
          isDecisionOrSummary(msg.content) ||
          isUserIntentOrQuestion(msg.content, msg.role);

        const lowValue =
          !protectedMessage &&
          (isLowValueChatter(msg.content) || looksLikeDocDump(msg.content));
        return { index, msg, protectedMessage, lowValue };
      })
      .filter((a) => !a.lowValue);

    let totalChars = annotated.reduce(
      (acc, a) => acc + a.msg.content.length,
      0,
    );
    if (totalChars <= MAX_CONVERSATION_CHARS)
      return annotated.sort((a, b) => a.index - b.index).map((a) => a.msg);

    let tailStart = Math.max(0, annotated.length - RECENT_PROTECT_COUNT);

    let i = 0;
    while (totalChars > MAX_CONVERSATION_CHARS && i < tailStart) {
      const a = annotated[i];
      if (!a) break;
      if (!a.protectedMessage) {
        totalChars -= a.msg.content.length;
        annotated.splice(i, 1);
        tailStart -= 1;
        continue;
      }
      i += 1;
    }

    while (
      totalChars > MAX_CONVERSATION_CHARS &&
      annotated.length > RECENT_PROTECT_COUNT
    ) {
      const head = annotated[0];
      if (!head) break;
      totalChars -= head.msg.content.length;
      annotated.shift();
      tailStart -= 1;
    }

    return annotated.sort((a, b) => a.index - b.index).map((a) => a.msg);
  };

  const generateSlugFromSession = async (sessionID: string, cwd: string) => {
    const { data: messages } = await client.session.messages({
      path: { id: sessionID },
      query: { directory: cwd, limit: 50 },
    });

    if (!messages?.length) return "handoff";

    const userTexts: string[] = [];
    for (const msg of messages) {
      if (msg.info.role !== "user") continue;
      const text = extractTextFromParts(msg.parts as any);
      if (text) userTexts.push(text);
      if (userTexts.length >= 3) break;
    }

    const combined = userTexts
      .map((t) => t.slice(0, 100))
      .join(" ")
      .toLowerCase()
      .trim();

    if (!combined) return "handoff";

    const stopWords = new Set([
      "the",
      "a",
      "an",
      "and",
      "or",
      "but",
      "in",
      "on",
      "at",
      "to",
      "for",
      "of",
      "with",
      "by",
    ]);

    const keywords = combined
      .split(/\s+/g)
      .map((w) => w.replace(/[^a-z0-9]/g, ""))
      .filter((w) => w.length > 3 && !stopWords.has(w))
      .slice(0, 3);

    return keywords.length ? keywords.join("-") : "handoff";
  };

  const formatTodos = (todos: Array<{ content: string; status: string }>) => {
    if (!todos.length) return "";

    const markerForStatus = (status: string) => {
      if (status === "completed") return "☑";
      if (status === "in_progress") return "▶";
      return "☐";
    };

    return todos
      .map((t) => `  ${markerForStatus(t.status)} ${t.content}`)
      .join("\n");
  };

  const extractMessagesFromSession = async (sessionID: string, cwd: string) => {
    const { data: messages } = await client.session.messages({
      path: { id: sessionID },
      query: { directory: cwd, limit: 200 },
    });

    if (!messages?.length) return [] as HandoffMessage[];

    const extracted: HandoffMessage[] = [];
    for (const msg of messages) {
      const role = msg.info.role;
      if (role !== "user" && role !== "assistant") continue;

      const parts = (msg.parts ?? []) as any[];
      const toolCount = parts.filter((p) => p?.type === "tool").length;
      let text = extractTextFromParts(parts as any);
      if (!text) continue;

      // Skip the trigger message itself so it doesn't pollute the handoff.
      if (role === "user" && text.trim().startsWith("/handoff")) continue;

      text = text.trim();
      if (text.length > MAX_MESSAGE_LEN)
        text = `${text.slice(0, MAX_MESSAGE_LEN)}...`;
      if (toolCount > 0) text = `${text} [+${toolCount} tool call(s)]`;

      extracted.push({ role, content: text });
    }

    const bounded =
      extracted.length > MAX_MESSAGES
        ? extracted.slice(-MAX_MESSAGES)
        : extracted;
    return filterMessagesForHandoff(bounded);
  };

  const formatConversation = (messages: HandoffMessage[]) =>
    messages.map((m) => `${m.role.toUpperCase()}: ${m.content}\n`).join("\n");

  const saveHandoffToFile = async (input: {
    cwd: string;
    summary: string;
    userNote?: string;
    sessionID: string;
  }) => {
    const { cwd, summary, userNote, sessionID } = input;

    const handoffsDir = join(cwd, ".claude", "handoffs");
    await mkdir(handoffsDir, { recursive: true });

    const title = extractTitleFromSummary(summary);
    const slug = title
      ? titleToSlug(title)
      : await generateSlugFromSession(sessionID, cwd);

    const now = new Date();
    // YYYYMMDD-HHMMSS (safe for filenames, stable length)
    const timestamp = now
      .toISOString()
      .replace(/[-:]/g, "")
      .replace("T", "-")
      .replace(/\..*$/, "");
    const filename = `${slug}-${timestamp}.md`;

    const displayTitle =
      title ?? slug.replace(/-/g, " ").replace(/\b\w/g, (c) => c.toUpperCase());

    const created = now.toISOString().replace("T", " ").slice(0, 19);
    const header = [
      `# Handoff: ${displayTitle}`,
      ``,
      `**Created**: ${created}`,
      ``,
      userNote ? `## User Note\n\n> ${userNote}\n` : "",
      `---`,
      ``,
    ]
      .filter(Boolean)
      .join("\n");

    const footer = [
      ``,
      `---`,
      ``,
      `**To resume**: Run \`/pickup ${filename}\` in a new session`,
      ``,
    ].join("\n");

    await writeFile(
      join(handoffsDir, filename),
      `${header}${summary.trim()}\n${footer}`,
      "utf-8",
    );

    return { filename, relativePath: `.claude/handoffs/${filename}` };
  };

  const runHandoffSummary = async (prompt: string) => {
    const proc = $`aichat -r handoff-summary`.quiet();
    const writer = proc.stdin.getWriter();
    await writer.write(new TextEncoder().encode(prompt));
    await writer.close();
    return (await proc.text()).trim();
  };

  const createHandoff = async (input: {
    purpose: string;
    sessionID: string;
    cwd: string;
  }) => {
    const { purpose, sessionID, cwd } = input;

    const [handoffMessages, { data: todos }] = await Promise.all([
      extractMessagesFromSession(sessionID, cwd),
      client.session.todo({
        path: { id: sessionID },
        query: { directory: cwd },
      }),
    ]);

    if (handoffMessages.length === 0) {
      await client.tui.showToast({
        body: {
          variant: "error",
          title: "handoff",
          message: "No conversation history found to summarize.",
        },
        query: { directory: cwd },
      });
      return "No conversation history found to summarize.";
    }

    const todosSection = (() => {
      const formatted = todos ? formatTodos(todos as any) : "";
      if (!formatted) return "";
      return [
        `# Current Todo List (from session):`,
        `The following is the EXACT todo list from the session. Include ALL items in your handoff summary, preserving EXACT wording:`,
        ``,
        formatted,
        ``,
      ].join("\n");
    })();

    const conversation = formatConversation(handoffMessages);
    const prompt = [
      `Project directory: \`${cwd}\``,
      ``,
      `Handoff purpose: ${purpose.trim()}`,
      ``,
      todosSection,
      `# Previous Session Conversation:`,
      ``,
      conversation,
      ``,
      `# Instructions:`,
      `Analyze this conversation and create a comprehensive handoff document following the role's format.`,
    ]
      .filter(Boolean)
      .join("\n");

    const summary = await runHandoffSummary(prompt);

    const { filename, relativePath } = await saveHandoffToFile({
      cwd,
      summary,
      userNote: purpose.trim(),
      sessionID,
    });

    const pickupCommand = `/pickup ${filename}`;
    const hintMessage = [
      `**Handoff Created**`,
      ``,
      `**File**: \`${relativePath}\``,
      ``,
      `**Next Steps**:`,
      `1. Run \`/new\` to start a fresh session`,
      `2. Run: \`${pickupCommand}\``,
      ``,
    ].join("\n");

    await Promise.all([
      client.tui.showToast({
        body: {
          variant: "success",
          title: "handoff",
          message: `Saved ${relativePath}`,
          duration: 8000,
        },
        query: { directory: cwd },
      }),
      client.tui.appendPrompt({
        body: { text: pickupCommand },
        query: { directory: cwd },
      }),
      client.session.prompt({
        path: { id: sessionID },
        query: { directory: cwd },
        body: { noReply: true, parts: [{ type: "text", text: hintMessage }] },
      }),
    ]);

    return hintMessage;
  };

  return {
    tool: {
      handoff: tool({
        description:
          "Generate a handoff markdown file from the current session conversation and todo list, so work can continue in a new session.",
        args: {
          purpose: tool.schema
            .string()
            .min(1)
            .describe("Purpose for the handoff; what the next session should do"),
        },
        async execute(args, context) {
          const cwd = directory || process.cwd();
          return createHandoff({
            purpose: args.purpose,
            sessionID: context.sessionID,
            cwd,
          });
        },
      }),
    },
    async event({ event }) {
      // Back-compat: keep `/handoff ...` command working by intercepting it.
      // NOTE: We revert the command output message so the session looks like it "skipped" the command.
      if (
        event.type !== "command.executed" ||
        event.properties.name !== "handoff"
      )
        return;

      const sessionID = event.properties.sessionID;
      const commandMessageID = event.properties.messageID;
      const purpose = (event.properties.arguments || "").trim();
      const cwd = directory || process.cwd();

      await client.session.revert({
        path: { id: sessionID },
        query: { directory: cwd },
        body: { messageID: commandMessageID },
      });

      if (!purpose) {
        await client.tui.showToast({
          body: {
            variant: "error",
            title: "handoff",
            message: "Please provide a purpose: /handoff <what to do next>",
          },
          query: { directory: cwd },
        });
        return;
      }

      await createHandoff({ purpose, sessionID, cwd });
    },
  };
};
