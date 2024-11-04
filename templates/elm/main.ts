async function main() {
  // Load the Elm application.
  // @ts-expect-error: This script add `Elm` to the global scope.
  await import("./compiled.js");

  // Start the Elm application.
  let app = Elm.Main.init({
    node: document.getElementById("app"),
    // flags: someFlagsHere,
  });
}

main();
