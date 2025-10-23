/**
 * @see https://prettier.io/docs/en/configuration.html
 * @type {import("prettier").Config}
 */
export default {
  plugins: ["@prettier/plugin-oxc"],
  overrides: [
    {
      files: "**/*.{ts,mts,cts,tsx}",
      options: {
        parser: "oxc-ts",
      },
    },
  ],
};
