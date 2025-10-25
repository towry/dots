import type { Plugin } from "@opencode-ai/plugin";

export const Kiro: Plugin = async ({ client }) => {
  return {
    async event({ event }) {
      if (
        event.type === "session.compacted" &&
        process.env.KIRO_SYSTEM_PROMPT
      ) {
        // after session is compacted, we need attach our kiro system prompt
        // to the chat. otherwise, agent will forget it on next runs.
        const SystemPromptFromEnv = [
          process.env.KIRO_SYSTEM_PROMPT || "Kiro spec not found",
        ].concat([
          "This is just a friendly reminder, please just reply 'Got it' or do not reply. If you have unfinished task before, please continue to work on it.",
        ]);

        const sessionID = event.properties.sessionID;
        await client.session.prompt({
          path: { id: sessionID },
          body: {
            agent: "kiro",
            system: process.env.KIRO_SYSTEM_PROMPT,
            parts: [
              {
                type: "text",
                text: SystemPromptFromEnv.join("\n"),
              },
            ],
          },
        });
      }
    },
  };
};
