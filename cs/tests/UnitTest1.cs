using Microsoft.VisualStudio.TestTools.UnitTesting;
using TddExMicrotest;

namespace TddExMicrotest.Tests
{
    [TestClass]
    public class UnitTest1
    {
        [TestMethod]
        public void ThisTestIsNotMicro()
        {
            var x = Hangman.FromInternet(5);
            Assert.AreEqual(6, x.NumberLetters);
        }
    }
}
