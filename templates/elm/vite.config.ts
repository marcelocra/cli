import { defineConfig } from "vite";
import { elmCompilerPlugin } from "vite-elm-plugin";

export default defineConfig({
  plugins: [elmCompilerPlugin()],
});
