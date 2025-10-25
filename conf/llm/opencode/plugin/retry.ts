import type { Plugin } from "@opencode-ai/plugin";

// error messages that should trigger a retry
const RetryMessage = [
  "Tool execution aborted",
  "The socket connection was closed unexpectedly",
];

const RetryPrompt = `You have encountered an error in the previous attempt. Please retry the last action.`;

function shouldRetry(messages: string[], errorMsg: string): boolean {
  let isInRetryMessage = false;
  for (const err of RetryMessage) {
    if (errorMsg.includes(err)) {
      isInRetryMessage = true;
    }
  }
  if (!isInRetryMessage) {
    return false;
  }

  for (const msg of messages) {
    if (msg.includes(RetryPrompt)) {
      return false;
    }
  }
  // not found in last messages
  return true;
}

// retry on error, if last 2 messages does not contain a retry prompt
export const Retry: Plugin = async ({ client }) => {
  return {
    async event({ event }) {
      if (event.type === "session.error") {
        const sessionID = event.properties.sessionID as string;
        const errMsg =
          (event.properties.error?.data?.message as string) || "Unknown error";

        const messages = await client.session.messages({
          path: {
            id: sessionID,
          },
        });
        const messagesData = messages.data || [];
        const messagesText = messagesData.map((m) =>
          m.parts.map((p) => (p.type == "text" ? p.text : "")).join("\n"),
        );

        if (!shouldRetry(messagesText.slice(-3), errMsg)) {
          return;
        }

        await client.session.prompt({
          path: { id: sessionID },
          body: {
            parts: [
              {
                type: "text",
                text: RetryPrompt,
              },
            ],
          },
        });
      }
    },
  };
};
