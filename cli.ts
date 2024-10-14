#!/usr/bin/env -S deno run
// #region Module description and imports.
/**
 * @module
 *
 * Generates files based on other files, either templates or not.
 * I alias it to `cli` and put it in my `$PATH`, to simplify usage.
 *
 * @example
 * ```sh
 * cli new deno
 * # => Creates a new `deno.json` file in the current folder.
 * ```
 *
 * To develop this script, run:
 *
 *    $ deno run --watch ./manager.ts
 *
 * To run it, compile it first and then add it to your path:
 *
 *    $ deno compile --unstable --allow-read --allow-write ./manager.ts
 *    $ cp ./manager $HOME/bin  # or any other folder in your $PATH
 *
 * You can also simply run this directly, as it has the appropriate shebang:
 *
 *    $ ./manager.ts
 */
import * as path from "jsr:@std/path";
import { parseArgs } from "jsr:@std/cli/parse-args";

// #endregion
// #region SETUP

const ROOT_FOLDER_NAME = "cli";

enum LogLevel {
  /** Print detailed messages, also with {@link console.trace}, for all logs. */
  VERBOSE = "VERBOSE",

  /** Print essential messages only, for example, when an error occurs. */
  ESSENTIAL = "ESSENTIAL", // Default.

  /** Print more detailed logs that might be only useful during development. */
  DEBUG = "DEBUG",
}

const LOG_LEVEL: LogLevel = LogLevel.DEBUG;

function isLogLevelDebug() {
  return LOG_LEVEL === LogLevel.DEBUG;
}

function isLogLevelVerbose() {
  return LOG_LEVEL === LogLevel.VERBOSE;
}

/**
 * Verify if this script is running from the root folder.
 */
function checkIfRunningFromCorrectFolder() {
  const currentFolder = Deno.cwd();
  if (!currentFolder.endsWith(ROOT_FOLDER_NAME)) {
    console.error("%cERROR: This script must be run from the root folder of the project.", "color: red");
    Deno.exit(1);
  }

  _d("Running from the correct folder.");
}

function getPathToTemplateFiles() {
  return path.resolve(Deno.cwd(), "templates");
}

// #endregion
// #region MAIN

function runCommandWithArgs(command: string, args: string[]) {}

function main() {
  checkIfRunningFromCorrectFolder();

  const templateFilesPath = getPathToTemplateFiles();
  _d("Template files path:", templateFilesPath);

  const flags = parseArgs(Deno.args, {
    boolean: ["help", "color"],
    string: ["version"],
    default: { help: false, color: true, version: "0.1.0" },
    negatable: ["color"],
  });

  _d("Flags:", flags);

  // First argument should be the command, with the following ones being its arguments. This means that we NEED at least
  // 1 argument, for commands that have no arguments (like `help`).
  if (flags._.length < 1) {
    console.error("%cERROR: You must provide a command.", "color: red");
    Deno.exit(1);
  }

  const [command, ...args] = flags._;
  runCommandWithArgs(command, args);
}

if (import.meta.main) {
  main();
}

// #endregion
// #region HELPER FUNCTIONS - IGNORE
// #region LOGGER

type BaseLoggerOptions = {
  useErrorFn: boolean;
};

function useError(arg: unknown): arg is BaseLoggerOptions {
  return (<BaseLoggerOptions>arg).useErrorFn !== undefined;
}

function _baseLogger(...args: unknown[]) {
  if (!isLogLevelDebug()) {
    return;
  }

  const timePrefix = `[ ${new Date().toLocaleString()} ][ ${LOG_LEVEL} ]`;

  if (isLogLevelVerbose()) {
    console.trace(timePrefix, ...args);
    return;
  }

  const [first, ...rest] = args;
  useError(first) ? console.error(timePrefix, ...rest) : console.log(timePrefix, ...args);
}

function _d(...args: unknown[]) {
  _baseLogger(...args);
}

function _e(...args: unknown[]) {
  _baseLogger({ useErrorFn: true }, ...args);
}

// #endregion
// #endregion
