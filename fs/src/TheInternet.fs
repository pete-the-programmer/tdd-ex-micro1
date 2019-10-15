module TheInternet

open System
open System.Net

let WORDS = "https://www.wordgamedictionary.com/word-lists/{0}-letter-words/{0}-letter-words.json"
let OTHER = "https://httpstat.us/{0}"
let TURTLES = "https://www.turtles.com/api/{0}/command/{1}"

let client = new WebClient()

let Get url parameters = 
    let urlWithValues: string = String.Format(url, parameters)
    printfn "Downloading from %s" urlWithValues
    client.DownloadString urlWithValues
