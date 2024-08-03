#!/usr/bin/env -S deno run -A
/**
 * Creates a new vite project using the `react-swc-ts` template, adding some extra devtools to it.
 */

import { execSync } from "node:child_process";
import fs from "node:fs";
import path from "node:path";
import process from "node:process";

//
//
// Constants.
//

const devDependencies = [
  "@tailwindcss/typography",
  "@trivago/prettier-plugin-sort-imports",
  "@types/node",
  "autoprefixer",
  "cssnano",
  "daisyui",
  "eslint-config-google",
  "eslint-config-prettier",
  "postcss",
  "prettier",
  "prettier-plugin-tailwindcss",
  "tailwindcss",
];

// Kept as reference. To be installed if required.
const extraDevDependencies = ["@types/shelljs", "shelljs", "shx", "zx"];

// Get config templates from the templates folder.
const __filename = new URL(import.meta.url).pathname;
const templatesPath = path.resolve(path.dirname(path.dirname(__filename)), "templates");

//
//
// Helpers.
//

const getTemplate = (templateName: string) =>
  fs.readFileSync(path.resolve(templatesPath, templateName), "utf8");

const execTrim = (command: string) => execSync(command, { stdio: "pipe" }).toString().trim();

//
//
// Main.
//

const projectName = process.argv[2];

if (!projectName) {
  console.error("Please provide a project name.");
  process.exit(1);
}

// Create Vite Preact project.
execSync(`npm create vite@latest ${projectName} -- --template preact-ts`, {
  stdio: "inherit",
});

// Install stuff before loading the package.json.
execSync(`npm install --save-dev ${devDependencies.join(" ")}`, {
  stdio: "inherit",
});

// Load the package.json file, to apply updates.
const currentDir = process.cwd();
const packageJsonPath = `${currentDir}/package.json`;
const { default: packageJson } = await import(packageJsonPath, {
  with: { type: "json" },
});

console.log(packageJsonPath);
console.log(packageJson);

packageJson.eslintConfig = JSON.parse(getTemplate(".eslintrc.json"));
packageJson.prettier = JSON.parse(getTemplate(".prettierrc.json"));

const nodeVersion = execTrim("node --version").replaceAll(/(v|\..+)/g, "");
packageJson.engines = { node: `>=${nodeVersion}` };
packageJson.engineStrict = true;

const npmVersion = execTrim("npm --version");
packageJson.packageManager = `npm@${npmVersion}`;

const gitUser = execTrim("git config --global user.name");
const gitEmail = execTrim("git config --global user.email");
packageJson.author = { name: `${gitUser}`, email: `${gitEmail}` };

const gitRepo = execTrim("git config --get remote.origin.url");
packageJson.repository = { type: "git", url: `${gitRepo}` };

// Write the applied updates to the file.
fs.writeFileSync(packageJsonPath, JSON.stringify(packageJson, null, 2));

// Print the result.
console.log(packageJson);
