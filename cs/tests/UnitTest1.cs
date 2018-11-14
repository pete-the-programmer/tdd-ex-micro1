using Microsoft.VisualStudio.TestTools.UnitTesting;
using TddExMicrotest;

namespace TddExMicrotest.Tests
{
    [TestClass]
    public class UnitTest1
    {
        [TestMethod]
        public void ThisTestFails()
        {
            Assert.AreEqual(4, 0);
        }
    }
}
