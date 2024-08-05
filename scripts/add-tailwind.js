#!/usr/bin/env node
// @ts-check

import { copyTemplate, npmInstall, run } from "./_helpers.js";

npmInstall("tailwindcss postcss autoprefixer @tailwindcss/typography daisyui@latest");
run("npx tailwindcss init -p");
copyTemplate("tailwind+twTypography+daisyui.js", { filename: "tailwind.config.js" });
copyTemplate("tailwind-index.css", { filename: "index.css", folder: "src" });
