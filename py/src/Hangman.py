from enum import Enum
from string import ascii_uppercase
from random import randint
from .TheInternet import GameUrls, TheInternet

class GameStatus(Enum):
  NotStarted = 1
  Guessing = 2
  Winner = 3
  Hanged = 4

class LetterStatus(Enum):
  NotGuessed = 1
  GuessedCorrect = 2
  GuessedIncorrect = 3

class Letter():
  def __init__(self, value: str, status: LetterStatus):
      self.value = value[0]
      self.status = status

class Hangman():
  DEATH_LIMIT = 11
  def __init__(self, word:str) -> None:
    print(f'Hangman started with word: {word}')
    self.__word = word
    self.__letters = [Letter(x, LetterStatus.NotGuessed) for x in ascii_uppercase]
    self.__status = GameStatus.NotStarted

  def from_internet(length: int):
    internet = TheInternet()
    print(f'Starting hangman with a word of length {length}')
    content = internet.get(GameUrls.WORDS, length)
    index = randint(0, len(content))
    word = content[index]['word']
    return Hangman(word)

  def GameStatus(self): return self.__status

  def NumberLetters(self): return len(self.__word)

  def NumberWrongGuesses(self): 
    return len(x for x in self.__letters if x.status == LetterStatus.GuessedIncorrect)

  def NumberRightGuesses(self): 
    letters = [ord(letter) - 65 for letter in self.__word]
    letter_statuses = [self.__letters[idx] for idx in letters]
    return len(x for x in letter_statuses if x.status == LetterStatus.GuessedIncorrect)

  def Guess(self, letter: str):
    print(f'Guessing {letter}')
    if self.__status == GameStatus.NotStarted and self.__status != GameStatus.Guessing:
      raise Exception("Game not in state that can accept a guess.")
    self.__status == GameStatus.Guessing
    is_correct =  letter[0] in self.__word 
    self.__letters[ord(letter) - 65].status = LetterStatus.GuessedCorrect if is_correct else LetterStatus.GuessedIncorrect
    if self.NumberWrongGuesses() >= Hangman.DEATH_LIMIT:
      print("Hanged!!")
      self.__status = GameStatus.Hanged
    if self.NumberRightGuesses() >= self.NumberLetters():
      print('Winner!')
      self.__status = GameStatus.Winner
    print(f'Letter is correct? {is_correct}')
    return is_correct

