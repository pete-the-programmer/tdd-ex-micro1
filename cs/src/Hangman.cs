using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Newtonsoft.Json.Linq;

namespace TddExMicrotest
{
    public enum GameStatus { NotStarted, Guessing, Winner, Hanged };
    public enum LetterStatus { NotGuessed, GuessedCorrect, GuessedIncorrect };

    public class Letter {
        public char Value;
        public LetterStatus Status;
        public Letter(char value, LetterStatus status){ 
            Value = value;
            Status = status;
        }
    }

    public class Hangman
    {
        private static Random R = new Random();
        private const int DEATH_LIMIT = 11;
        public readonly string _word;
        private Letter[] _letters = Enumerable.Range('A', 26).Select(x => new Letter((char)x, LetterStatus.NotGuessed)).ToArray();

        public Hangman(string word){
            Console.WriteLine("Hangman started with word: " + word);
            _word = word;
            Status = GameStatus.NotStarted;
        }

        public static Hangman FromInternet(int length) {
            TheInternet internet = new TheInternet();
            Console.WriteLine("Starting hangman with a word of length " + length);
            var content = internet.Get(GameUrls.WORDS, length);
            var words = JArray.Parse(content);
            var index = R.Next(0, words.Count);
            var word = words[index].Value<string>("word");
            return new Hangman(word);
        }

        public GameStatus Status{ get; private set; }

        public int NumberLetters{get{ return this._word.Length; }}

        public int NumberWrongGuesses{
            get{
                return this._letters.Where(x => x.Status == LetterStatus.GuessedIncorrect).Count();
            }
        }

        public int NumberRightGuesses{
            get{
                var letters = _word.ToCharArray();
                var letterStatuses = letters.Select( i => _letters[(i - 'a')]);
                return letterStatuses.Where(x => x.Status == LetterStatus.GuessedCorrect).Count();
            }
        }

        public bool Guess(char letter){
            Console.WriteLine("Guessing " + letter);
            if( Status != GameStatus.NotStarted && Status != GameStatus.Guessing) {
                throw new System.ApplicationException("Game not in state that can accept a guess.");
            }
            Status = GameStatus.Guessing;
            var isCorrect = _word.Contains(letter);
            _letters[(letter - 'a')].Status = (isCorrect ? LetterStatus.GuessedCorrect : LetterStatus.GuessedIncorrect);
            if( NumberWrongGuesses >= DEATH_LIMIT){
                Console.WriteLine("Hanged!");
                Status = GameStatus.Hanged;
            }
            if( NumberRightGuesses >= NumberLetters ){
                Console.WriteLine("Winner!");
                Status = GameStatus.Winner;
            }
            Console.WriteLine("Letter is correct? " + isCorrect);
            return isCorrect;
        }
    }
}
