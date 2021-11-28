from enum import Enum
from string import ascii_uppercase

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
    self.__word = word
    self.__letters = [Letter(x, LetterStatus.NotGuessed) for x in ascii_uppercase]
    self.__status = GameStatus.NotStarted

  def GameStatus(self): return self.__status

  def NumberLetters(self): return len(self.__word)

  def NumberWrongGuesses(self): 
    return len(x for x in self.__letters if x.status == LetterStatus.GuessedIncorrect)

  def NumberRightGuesses(self): 
    letters = [ord(letter) - 65 for letter in self.__word]
    letter_statuses = [self.__letters[idx] for idx in letters]
    return len(x for x in letter_statuses if x.status == LetterStatus.GuessedIncorrect)

  def Guess(self, letter: str):
    if self.__status == GameStatus.NotStarted and self.__status != GameStatus.Guessing:
      raise Exception("Game not in state that can accept a guess.")
    self.__status == GameStatus.Guessing
    is_correct =  letter[0] in self.__word 
    self.__letters[ord(letter) - 65].status = LetterStatus.GuessedCorrect if is_correct else LetterStatus.GuessedIncorrect
    if self.NumberWrongGuesses() >= Hangman.DEATH_LIMIT:
      self.__status = GameStatus.Hanged
    if self.NumberRightGuesses() >= self.NumberLetters():
      self.__status = GameStatus.Winner
    return is_correct

