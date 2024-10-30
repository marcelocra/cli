async function main() {
  // Load the Elm application.
  await import("./compiled.js");

  // Start the Elm application.
  let app = Elm.Main.init({
    node: document.getElementById("app"),
    // flags: someFlagsHere,
  });
}

main();
