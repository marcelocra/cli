import { iterate, map, ofArray } from "./fable_modules/fable-library-js.4.19.3/List.js";
import { toString } from "./fable_modules/fable-library-js.4.19.3/Types.js";
import * as child_process from "child_process";
import { toConsole, printf, toText } from "./fable_modules/fable-library-js.4.19.3/String.js";

export const commandsToExecute = {
    commands: ofArray([{
        text: "npm version: ",
        command: "npm --version",
    }, {
        text: "node version: ",
        command: "node --version",
    }]),
};

export function executeCommand(c) {
    const text = toString(c.text);
    const command = toString(c.command);
    const output = toString(child_process.execSync(command));
    const arg_1 = output.trim();
    return toText(printf("%s%s"))(text)(arg_1);
}

export function main() {
    let clo;
    const list_2 = map(executeCommand, map((x) => x, commandsToExecute.commands));
    iterate((clo = toConsole(printf("%s")), (arg) => {
        clo(arg);
    }), list_2);
}

main();

