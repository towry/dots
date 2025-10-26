import { tool } from "@opencode-ai/plugin";

export default tool({
  description:
    "Execute codex-ai review with provided instructions and conversation context",
  args: {
    reviewInstructions: tool.schema
      .string()
      .describe("Review instructions to pass to codex-ai"),
    conversationContext: tool.schema
      .string()
      .describe("Conversation context for the review"),
  },
  async execute(args, ctx) {
    const { reviewInstructions, conversationContext } = args;
    const prompt = `${reviewInstructions}\n\nContext:\n${conversationContext}`;

    const result =
      await ctx.$`codex-ai --profile review e ${prompt} --sandbox read-only --skip-git-repo-check --color never`;
    return result.stdout;
  },
});
