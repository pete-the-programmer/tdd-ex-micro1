namespace HangmanTests

open System
open Microsoft.VisualStudio.TestTools.UnitTesting

open TddExMicrotest

[<TestClass>]
type TestHangman () =

    [<TestMethod>]
    member _.ThisTestFails () =
        let hangman = create "precious"
        Assert.IsNull(hangman)
