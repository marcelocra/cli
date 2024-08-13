/**
 * Simple script created to compare the output of Fable with a manually written ES script.
 */
import fs from "node:fs"
import { execSync } from "node:child_process"

const commandsToExecute = {
  commands: [
    {
      text: "npm version: ",
      command: "npm --version",
    },
    {
      text: "node version: ",
      command: "node --version",
    },
  ]
}

function executeCommand(obj) {
  return `${obj.text}${execSync(obj.command).toString().trim()}`
}

Object.entries(commandsToExecute.commands).map(([key, value]) => console.log(executeCommand(value)))

