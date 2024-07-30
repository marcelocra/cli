import { stringify } from "jsr:@std/yaml";

const jsonFilePath = Deno.args[0];
const yamlFilePath = Deno.args[1];

console.log(`Will write json content from '${jsonFilePath}' as yaml in '${yamlFilePath}'...`);

const jsonFile = Deno.readFileSync(jsonFilePath);
const decoder = new TextDecoder();
const jsonFileContent = JSON.parse(decoder.decode(jsonFile));

const encoder = new TextEncoder();
Deno.writeFileSync(yamlFilePath, encoder.encode(stringify(jsonFileContent)));

