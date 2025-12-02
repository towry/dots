import type { Plugin } from "@opencode-ai/plugin";

export const Kiro: Plugin = async ({ client }) => {
  return {
    async event({ event }) {
      // https://github.com/sst/opencode/pull/3413#issuecomment-3451988873
      if (event.type === "session.created" && process.env.KIRO_SYSTEM_PROMPT) {
        const sessionID = event.properties.info.id as string;

        const SystemPromptFromEnv = [
          process.env.KIRO_SYSTEM_PROMPT || "Kiro spec not found",
        ].concat([""]);

        await client.session.prompt({
          path: { id: sessionID },
          body: {
            noReply: true,
            parts: [
              {
                type: "text",
                text: SystemPromptFromEnv.join("\n"),
              },
            ],
          },
        });
      }

      if (
        event.type === "session.compacted" &&
        process.env.KIRO_SYSTEM_PROMPT &&
        event.properties.sessionID
      ) {
        // after session is compacted, we need attach our kiro system prompt
        // to the chat. otherwise, agent will forget it on next runs.
        const SystemPromptFromEnv = [
          process.env.KIRO_SYSTEM_PROMPT || "Kiro spec not found",
        ].concat([""]);

        const sessionID = event.properties.sessionID as string;
        await client.session.prompt({
          path: { id: sessionID },
          body: {
            noReply: true,
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
