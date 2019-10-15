module TddExMicrotest

type GameState = NotStarted | Guessing | Winner | Hanged
type LetterStatus = NotGuessed | GuessedCorrect | GuessedIncorrect

type Letter = {
    value: char
    status: LetterStatus
}

let DEATH_LIMIT = 11

type Hangman = {
    word: string
    state: GameState
    letters: Letter seq
}

let create word = 
    {
        word=word
        state = NotStarted
        letters = Seq.init 26 (fun i -> {value = (char) (i + (int)'a'); status = NotGuessed})
    }

let numberWrongGuesses game = 
    game.letters
    |> Seq.filter (fun x -> x.status = GuessedIncorrect)
    |> Seq.length

let numberRightGuesses game = 
    game.word
    |> Seq.map (fun c -> 
        game.letters 
        |> Seq.find (fun x -> x.value = c)
    )
    |> Seq.filter (fun x -> x.status = GuessedCorrect)
    |> Seq.length

let guess (letter:char) game =
    let validGame = 
        match game.state with
        | Winner -> failwith "You have already won."
        | Hanged -> failwith "You cannot guess after you have been hanged."
        | NotStarted -> {game with state = Guessing}
        | Guessing -> game
    let isCorrect = if validGame.word.IndexOf(letter) >= 0 then GuessedCorrect else GuessedIncorrect
    let gameWithLetters = 
        {validGame with 
            letters = 
                validGame.letters 
                |> Seq.map (fun x -> 
                    if x.value = letter 
                    then {value=letter; status = isCorrect} 
                    else x 
                )
        }
    let isWinner = numberRightGuesses gameWithLetters >= gameWithLetters.word.Length
    let isHanged = numberWrongGuesses gameWithLetters >= DEATH_LIMIT
    printfn "%A %A %A" (numberRightGuesses gameWithLetters) (numberWrongGuesses gameWithLetters) (gameWithLetters.word.Length)
    let updatedState = 
        match isWinner, isHanged with
        | true, _ -> Winner
        | _, true -> Hanged
        | _, _ -> validGame.state
    {gameWithLetters with state = updatedState}