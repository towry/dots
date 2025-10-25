import type { Plugin } from "@opencode-ai/plugin";

interface NotifyOptions {
  message: string;
  subtitle?: string;
  group?: string;
  onClick?: string;
}

const onClick = `osascript \\
          -e 'tell application "Ghostty" to activate' \\
          -e 'tell application "System Events" to key code 49 using control down' \\
          -e 'delay 0.1' \\
          -e 'tell application "System Events" to key code 36'`;

export const Notify: Plugin = async ({ directory, client, $ }) => {
  const pathParts = directory.split("/").filter(Boolean);
  const projectName = pathParts[pathParts.length - 1] || "";
  const projectCategory = pathParts[pathParts.length - 2] || "";

  const sendNotification = async (options: NotifyOptions) => {
    const {
      message,
      subtitle = `[${projectCategory}/${projectName}]`,
      group = `opencode-${projectName}`,
      onClick,
    } = options;

    if (onClick) {
      await $`terminal-notifier \
        -title "opencode" \
        -subtitle ${subtitle} \
        -message ${message} \
        -group ${group} \
        -execute ${onClick}`.quiet();
    } else {
      await $`terminal-notifier \
        -title "opencode" \
        -subtitle ${subtitle} \
        -message ${message} \
        -group ${group}`.quiet();
    }
  };

  return {
    async event({ event }) {
      if (event.type === "session.idle") {
        // Session title
        const sessionID = event.properties.sessionID;
        const { data: currentSession } = await client.session.get({
          path: { id: sessionID },
        });
        const sessionTitle = currentSession?.title || "";
        const isDefaultTitle = sessionTitle.startsWith("New session - ");
        const message =
          sessionTitle && !isDefaultTitle ? sessionTitle : "Agent run complete";

        await sendNotification({
          message,
          group: `opencode-${projectName}-${sessionID}`,
          onClick,
        });
      } else if (event.type === "session.error") {
        const errMsg = event.properties.error?.data?.message || "Unknown error";

        await sendNotification({
          message: `ERROR: ${errMsg}`,
          onClick,
        });
      }
    },
  };
};
