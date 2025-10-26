import type { Plugin } from "@opencode-ai/plugin";

export const Kiro: Plugin = async ({ client }) => {
  return {
    async event({ event }) {
      if (event.type === "session.updated" && process.env.KIRO_SYSTEM_PROMPT) {
        const sessionID = event.properties.info.id as string;
        const messageList = await client.session.messages({
          path: { id: sessionID },
        });

        if (messageList.data?.length) {
          return;
        }

        const SystemPromptFromEnv = [
          process.env.KIRO_SYSTEM_PROMPT || "Kiro spec not found",
        ].concat([
          "🌸 Just a reminder, no need to reply; For quick summary, you can use sage subagent",
        ]);

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
        ].concat(["You are in kiro mode, just a reminder, no need to replay"]);

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
