from unittest import TestCase
from src import Hangman


class TestHangman(TestCase):
    def test_is_not_micro(self):
      x = Hangman.from_internet(5)
      self.assertEqual(6, x.NumberLetters())