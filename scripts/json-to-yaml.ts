import { parse, stringify } from "jsr:@std/yaml";

const from = Deno.args[0];
const to = Deno.args[1];
const file = Deno.readFileSync(from);
const decoder = new TextDecoder();
const decodedFile = decoder.decode(file);
const encoder = new TextEncoder();
const encode = (content) => encoder.encode(content);

let content: string;
let encodedContent: string;

if (from.endsWith('.json')) {
  content = JSON.parse(decodedFile);
} else if (from.endsWith('.yaml')) {
  content = parse(decodedFile);
} else {
  console.error('Inputs supported: json, yaml');
  process.exit(1);
}

if (to.endsWith('.yaml')) {
  encodedContent = encode(stringify(content))
} else if (to.endsWith('.json')) {
  encodedContent = encode(JSON.stringify(content, null, 2))
} else {
  console.error('Outputs supported: json, yaml');
  process.exit(1);
}

Deno.writeFileSync(to, encodedContent);

