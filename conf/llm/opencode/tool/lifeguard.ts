import { tool } from "@opencode-ai/plugin";
import { $ } from "bun";

export default tool({
  description:
    "Review code by following the lifeguard.yaml rules, give review comments.",
  args: {
    reviewInstructions: tool.schema
      .string()
      .describe("Extra review instructions, rules to follow"),
    conversationContext: tool.schema
      .string()
      .describe(
        "Conversation context for the review, project and vcs info(git or jj repo?), files changed, command to get the diff, do not provide full diff here.",
      ),
  },
  async execute(args) {
    const { reviewInstructions, conversationContext } = args;
    const prompt = [
      "Below is extra context for code review:",
      conversationContext,
      "Extra review instructions to follow:",
      reviewInstructions,
    ].join("\n");

    if (!reviewInstructions.trim()) {
      return "No review instructions provided.";
    }

    const result = await $`claude-lifeguard -p ${prompt}`;

    return result.stdout.toString();
  },
});
