import type { Plugin } from "@opencode-ai/plugin";
import { writeFile, mkdir } from "node:fs/promises";
import { join } from "node:path";

export const Handoff: Plugin = async ({ client }) => {
  return {
    // Inject handoff-aware context into automatic compaction
    "experimental.session.compacting": async (input, output) => {
      output.context.push(`
## Handoff & Continuity Context
This session uses a handoff-based workflow. When compacting:
1. Preserve the current high-level task status.
2. Maintain references to active handoff files in \`.claude/handoffs/\`.
3. Ensure "Next Steps" are clearly defined for the continued session.
`);
    },

    async event({ event }) {
      // When session is compacted, save a summary for the next session to pick up
      // This mimics Claude's session_save.py behavior
      if (event.type === "session.compacted") {
        const sessionID = event.properties.sessionID as string;
        const summary = event.properties.summary as string;
        const cwd = process.cwd();

        if (summary) {
          const summaryDir = join(cwd, ".claude", "session-summary");
          await mkdir(summaryDir, { recursive: true });

          const timestamp = new Date().toISOString().replace(/[:.]/g, "-");
          const filename = `${timestamp}-summary-ID_${sessionID}.md`;

          await writeFile(join(summaryDir, filename), summary);
          console.log(`[Handoff] Saved session summary to ${filename}`);
        }
      }
    },
  };
};
