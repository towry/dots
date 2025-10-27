import { tool } from "@opencode-ai/plugin";
import { $ } from "bun";

export default tool({
  description:
    "Execute codex-ai review with provided instructions and conversation context",
  args: {
    reviewInstructions: tool.schema
      .string()
      .describe("Review instructions to pass to codex-ai"),
    conversationContext: tool.schema
      .string()
      .describe("Conversation context for the review, changes made etc"),
  },
  async execute(args) {
    const { reviewInstructions, conversationContext } = args;
    const prompt = `${reviewInstructions}\n----\nContext:\n${conversationContext}\n----\n`;

    if (!reviewInstructions.trim()) {
      return "No review instructions provided.";
    }

    const result = await $`claude-lifeguard -p ${prompt}`;

    return result.stdout.toString();
  },
});
