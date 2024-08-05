import path from "node:path";
import fs from "node:fs";
import { execSync } from "node:child_process";

/** @type {string} */
const __filename = new URL(import.meta.url).pathname;

/** @type {string} The default path to the root folder templates directory, `root/templates`. */
const templatesPath = path.resolve(path.dirname(path.dirname(__filename)), "templates");

/**
 * @param {string} templateFilename The name of the file as it is in the {@link templatesPath}.
 * @param {Object} [opts] Options to change how to get the templates
 * @param {string} [opts.templatesPath=templatesPath] The path to the templates directory. If not
 * provided, the default is {@link templatesPath}.
 * @returns {string} The content of the template file.
 */
export function getTemplate(templateFilename, opts) {
  opts = { templatesPath, ...opts };

  return fs.readFileSync(path.resolve(opts.templatesPath, templateFilename), "utf8");
}

/**
 * @param {string} command The command to execute.
 * @returns {string} The trimmed output of the executed command.
 */
export function execTrim(command) {
  return execSync(command, { stdio: "pipe" }).toString().trim();
}

/**
 * @param {string[] | string} packages A list or string of all packages that should be installed.
 * @param {Object} [opts] Options to change how the installation should proceed.
 * @param {boolean} [opts.dev=false] Whether to install the packages as dev dependencies.
 */
export function npmInstall(packages, opts) {
  opts = { dev: false, ...opts };

  const packagesStr = typeof packages === "string" ? packages : packages.join(" ");
  execSync(`npm install ${opts.dev ? "--save-dev" : "--save"} ${packagesStr}`, {
    stdio: "inherit",
  });
}

/**
 * @param {string[] | string} packages A list or string of all packages that should be installed as
 * dev dependencies.
 */
export function npmInstallDev(packages) {
  npmInstall(packages, { dev: true });
}

/** @param {string} cmdWithArgs The command that should be run, with its arguments. */
export function run(cmdWithArgs) {
  execSync(cmdWithArgs, { stdio: "inherit" });
}

/**
 * Copies a template file to the current directory.
 * @param {string} templateFilename The name of the file as it is in the {@link templatesPath}.
 * @param {object} [opts] Options to change the behavior. See details below.
 * @param {string} [opts.filename=templateFilename] The name to use in the copy of the template.
 *    Defaults to the same name of the file.
 * @param {string} [opts.folder='.'] A folder path to resolve for the file.
 *    Defaults to the current folder.
 */
export function copyTemplate(templateFilename, opts) {
  opts = { filename: templateFilename, folder: ".", ...opts };

  const content = getTemplate(templateFilename);
  console.log(opts);
  fs.writeFileSync(path.resolve(opts.folder, opts.filename), content);
}
