(* {{{

= ProjMan - A project manager.

To use this program, you need https://fable.io[Fable].

You can install it locally to your project or globally. Steps below.

== Local install

. <<init,Initialize>> your local configuration file.

    dotnet new tool-manifest

. <<install,Install>> Fable locally.

    dotnet tool install fable

. (Optional) Install a formatter and autocomplete, to improve development.

    # Formatter.
    dotnet tool install fantomas
    # Autocomplete.
    dotnet tool install fsautocomplete

. (Optional) Create a default .gitignore with common F#/dotnet stuff.

    dotnet new gitignore

== Global install

Mostly the same, but:

. You don't need to xref:init[create a local config].
. You need to use the `-g` flag when installing: `dotnet tool install -g fable`.

== How to interop with JavaScript

To access JavaScript functions and objects, see examples below.

=== Simple.

[fsharp]
----

open Fable.Core            // Provides `JS`.
open Fable.Core.JsInterop  // Provides `createObj`.

// Create a JS object.
let obj = createObj [ "stdio" ==> "inherit" ]

// Convert it to string.
let strObj = JS.JSON.stringify(obj)

// Print both the object and the string. Since this is meant to be printed with
// Node, the object will get its default representation of "[object Object]".
printfn "Object: %A" obj
printfn "Object as a string: %s" strObj
----

=== Advanced.

[fsharp]
----
let commandsToExecute =
    createObj [
        "commands" ==> [
            createObj [
                "text" ==> "npm version: ";
                "command" ==> "npm --version";
            ]
            createObj [
                "text" ==> "node version: ";
                "command" ==> "node --version";
            ]
        ]
    ]

let executeCommand (c: obj) : string =
    let text = c?text |> string
    let command = c?command |> string
    childProcess.execSync(command)
    |> string
    |> fun output -> sprintf "%s%s" text (output.Trim())

let main() =
    commandsToExecute?commands
    // This coercion most likely won't make a lot of sense in real code, as we could use F#
    // structures directly. This is simply a Node interop test.
    |> List.map (fun (x: obj) -> (x :?> obj list))
    // Iterate over the commands, executing one by one.
    |> List.map executeCommand
    // Print results.
    |> List.iter (printfn "%s")

main()
----

}}} *)

#r "nuget: Fable.Node"
#r "nuget: Fable.Core"

open Node.Api
open Fable.Core            // Provides `JS`.
open Fable.Core.JsInterop  // Provides `createObj`.

