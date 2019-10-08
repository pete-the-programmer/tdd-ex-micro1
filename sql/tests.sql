
EXEC tSQLt.NewTestClass 'HangmanTests';
GO

CREATE PROCEDURE HangmanTests.TestGameNotStarted
AS
BEGIN
    EXEC dbo.InitGame "frankly"
    DECLARE @status NVARCHAR(25)
    SELECT @status=label from Game g join GameStatus s ON g.gameStatus = s.id;
    EXEC tSQLt.AssertEquals @status, 'NotStarted';
END;
GO





EXEC tSQLt.RunAll;