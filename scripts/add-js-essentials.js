#!/usr/bin/env node
// @ts-check
/**
 * Examples:
 *  - running a command: run("npmx tailwindcss init -p")
 *  - copying a template: copyTemplate("tailwind-index.css", { filename: "index.css", folder: "src" })
 */

import { copyTemplate, npmInstall, run } from "./_helpers.js";

npmInstallDev("lodash lowdb");

