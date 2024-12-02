/**
 * @see https://prettier.io/docs/en/configuration.html
 * @type {import("prettier").Config}
 */
const config = {
  importOrder: ["^node:", "^npm:", "^jsr:", "<THIRD_PARTY_MODULES>", "^@/(.*)$", "^~/(.*)$", "^[./]", "^[../]"],
  importOrderSeparation: true,
  importOrderSortSpecifiers: true,
  plugins: ["@trivago/prettier-plugin-sort-imports", "prettier-plugin-tailwindcss"],
  overrides: [
    {
      files: ["*.md"],
      options: {
        parser: "markdown",
        proseWrap: "always",
      },
    },
  ],
};

export default config;
