import type { Plugin } from "@opencode-ai/plugin";
import { readdir, readFile } from "node:fs/promises";
import { join } from "node:path";

export const SessionContinuity: Plugin = async ({ client }) => {
  const getPreviousSummary = async (cwd: string) => {
    const summaryDir = join(cwd, ".claude", "session-summary");
    try {
      const files = await readdir(summaryDir);
      const summaryFiles = files
        .filter((f) => f.endsWith(".md") && f.includes("-summary-ID_"))
        .sort()
        .reverse();

      if (summaryFiles.length === 0) return null;

      const content = await readFile(join(summaryDir, summaryFiles[0]), "utf-8");
      return content.trim();
    } catch (e) {
      return null;
    }
  };

  return {
    async event({ event }) {
      // session.created is triggered on start and when /new is run
      if (event.type === "session.created") {
        const sessionID = event.properties.info.id as string;
        const cwd = process.cwd(); // OpenCode runs in project root

        const summary = await getPreviousSummary(cwd);
        if (summary) {
          console.log(`[Continuity] Loading previous session summary for ${sessionID}`);

          await client.session.prompt({
            path: { id: sessionID },
            body: {
              noReply: true,
              parts: [
                {
                  type: "text",
                  text: `<last-session>\n\n${summary}\n</last-session>`,
                },
              ],
            },
          });
        }
      }
    },
  };
};
