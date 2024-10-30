import js from "@eslint/js";
import eslintConfigGoogle from "eslint-config-google";
import eslintConfigPrettier from "eslint-config-prettier";

export default {
  extends: [js.configs.recommended, eslintConfigGoogle],
  plugins: [eslintConfigPrettier],
};
