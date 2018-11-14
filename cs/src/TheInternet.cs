using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Net;

namespace TddExMicrotest
{
    public class GameUrls {
        public const string WORDS = "https://www.wordgamedictionary.com/word-lists/{0}-letter-words/{0}-letter-words.json";
        public const string OTHER = "https://httpstat.us/{0}";
        public const string TURTLES = "https://www.turtles.com/api/{0}/command/{1}";
    }

    public class TheInternet {
        public WebClient _client = new WebClient();

        public string Get(string url, params object[] parameters){
            string urlWithValues = String.Format(url, parameters);
            Console.WriteLine("Downloading from " + urlWithValues);
            return _client.DownloadString(urlWithValues);
        }

    }
}