open System

printfn "Hello from F#"

let name = Console.ReadLine()
let currentDate = DateTime.Now

Console.WriteLine($"{Environment.NewLine}Hello, {name}, on {currentDate:d} at {currentDate:t}!")
Console.Write($"{Environment.NewLine}Press any key to exit...")
Console.ReadKey(true) |> ignore
