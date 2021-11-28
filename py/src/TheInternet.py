import requests

class GameUrls():
  WORDS = "https://www.wordgamedictionary.com/word-lists/{0}-letter-words/{0}-letter-words.json"
  OTHER = "https://httpstat.us/{0}"
  TURTLES = "https://www.turtles.com/api/{0}/command/{1}"

class TheInternet():
  def get(self, url: str, parameters):
    urlWithValues = url.format(parameters)
    print(f'Downloading from {urlWithValues}')
    return requests.get(urlWithValues).json()
