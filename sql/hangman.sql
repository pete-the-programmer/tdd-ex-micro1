-- clear
IF OBJECT_ID('Game') IS NOT NULL DROP TABLE Game;
IF OBJECT_ID('Letter') IS NOT NULL DROP TABLE Letter;
IF OBJECT_ID('LetterStatus') IS NOT NULL DROP TABLE LetterStatus;
IF OBJECT_ID('GameStatus') IS NOT NULL DROP TABLE GameStatus;

-- Reference tables

CREATE TABLE GameStatus ( id INT PRIMARY KEY, label NVARCHAR(25) );
INSERT INTO GameStatus VALUES ( 1, 'NotStarted');
INSERT INTO GameStatus VALUES ( 2, 'Guessing');
INSERT INTO GameStatus VALUES ( 3, 'Winner');
INSERT INTO GameStatus VALUES ( 4, 'Hanged');

CREATE TABLE LetterStatus ( id int PRIMARY KEY, label NVARCHAR(25) );
INSERT INTO LetterStatus VALUES ( 1, 'NotGuessed');
INSERT INTO LetterStatus VALUES ( 2, 'GuessedCorrect');
INSERT INTO LetterStatus VALUES ( 3, 'GuessedIncorrect');

-- Constants

IF OBJECT_ID('DeathLimit') IS NOT NULL DROP FUNCTION DeathLimit;
GO
CREATE FUNCTION dbo.DeathLimit()
RETURNS INT
AS
BEGIN
    RETURN 11;
END;
GO
-- DECLARE @deathLimit INT;  
-- SET @deathLimit = 11;  

-- Working Tables

CREATE TABLE Letter (
    letterValue CHAR PRIMARY KEY,
    letterStatus INT,
    FOREIGN KEY (letterStatus) REFERENCES LetterStatus(id)
);

CREATE TABLE Game (
    gameStatus INT,
    word VARCHAR(255),
    FOREIGN KEY (gameStatus) REFERENCES GameStatus(id)
);
GO

-- Interrogate

IF OBJECT_ID('NumberWrongGuesses') IS NOT NULL DROP FUNCTION NumberWrongGuesses;
GO
CREATE FUNCTION dbo.NumberWrongGuesses()
RETURNS INT
AS
BEGIN
    RETURN (
        SELECT COUNT(*)
        FROM Letter L
        WHERE L.letterStatus = 3
    );
END
GO

IF OBJECT_ID('NumberRightGuesses') IS NOT NULL DROP FUNCTION NumberRightGuesses;
GO
CREATE FUNCTION dbo.NumberRightGuesses()
RETURNS INT
AS
BEGIN
    RETURN (
        SELECT COUNT(*)
        FROM Letter L
        WHERE L.letterStatus = 2
    );
END
GO

-- Actions

IF OBJECT_ID('InitGame') IS NOT NULL DROP PROCEDURE InitGame;
GO
CREATE PROCEDURE InitGame(@word VARCHAR(255))
AS
BEGIN
    TRUNCATE TABLE Letter;
    INSERT INTO Letter
    SELECT Char(number+65), 1 from master.dbo.spt_values
    WHERE name IS NULL AND number < 26;
    TRUNCATE TABLE Game;
    INSERT INTO Game VALUES (1, @word);
END
GO

EXEC master.dbo.sp_configure 'show advanced options', 1
RECONFIGURE;
EXEC master.dbo.sp_configure 'Ole Automation Procedures', 1;
RECONFIGURE;  
GO

IF Object_Id('dbo.GetJsonFromInternet') IS NOT NULL 
    DROP FUNCTION dbo.GetJsonFromInternet
GO
CREATE FUNCTION dbo.GetJsonFromInternet(@TheURL VARCHAR(255))
RETURNS NVARCHAR(MAX)
AS
BEGIN
-- Cribbed from "Importing JSON Data from Web Services and Applications into SQL Server" by Phil Factor
-- https://www.red-gate.com/simple-talk/sql/t-sql-programming/importing-json-web-services-applications-sql-server/
    DECLARE @obj INT, @hr INT, @status INT, @message VARCHAR(255);
    DECLARE @Theresponse NVARCHAR(MAX);
    EXEC @hr = sp_OACreate 'MSXML2.ServerXMLHttp', @obj OUT;
    SET @message = 'sp_OAMethod Open failed';
    IF @hr = 0 
        EXEC @hr = sp_OAMethod @obj, 'open', NULL, 'GET', @TheURL, false;
    SET @message = 'sp_OAMethod setRequestHeader failed';
    IF @hr = 0
        EXEC @hr = sp_OAMethod @obj, 'setRequestHeader', NULL, 'Content-Type', 'application/x-www-form-urlencoded';
    SET @message = 'sp_OAMethod Send failed';
    IF @hr = 0 
        EXEC @hr = sp_OAMethod @obj, send, NULL, '';
    SET @message = 'sp_OAMethod read status failed';
    IF @hr = 0 
        EXEC @hr = sp_OAGetProperty @obj, 'status', @status OUT;
    IF @status <> 200 
    BEGIN
        SELECT @message = 'sp_OAMethod http status ' + Str(@status), @hr = -1;
    END;
    SET @message = 'sp_OAMethod read response failed';
    IF @hr = 0
    BEGIN
        EXEC @hr = sp_OAGetProperty @obj, 'responseText', @Theresponse OUT;
    END;
    EXEC sp_OADestroy @obj;
    IF @hr <> 0 
        SET @Theresponse = @message;
    RETURN @Theresponse;
END;
GO

IF OBJECT_ID('FromInternet') IS NOT NULL DROP PROCEDURE FromInternet;
GO
CREATE PROCEDURE FromInternet(@wordLength INT)
AS
BEGIN
    DECLARE @word VARCHAR(25);
    DECLARE @wordNum INT;
    DECLARE @numWords INT;
    DECLARE @url VARCHAR(255);
    DECLARE @json NVARCHAR(MAX);
    DECLARE @data TABLE(n INT, word VARCHAR(255))
    SET @url = (SELECT REPLACE(
        'https://www.wordgamedictionary.com/word-lists/{0}-letter-words/{0}-letter-words.json',
        '{0}',
        7
    ))
    SET @json =(SELECT dbo.GetJsonFromInternet(@url));
    INSERT INTO @data (n, word) 
        SELECT ROW_NUMBER() OVER(ORDER BY word ASC) AS n, word 
        FROM OpenJson(@json)
        WITH (
            word VARCHAR(100)
        );

    SET @wordNum = (SELECT FLOOR(RAND() * (SELECT COUNT(n) FROM @data)));
    SELECT @word = word FROM @data WHERE n = @wordNum;
    EXEC dbo.InitGame @word
END
GO

IF OBJECT_ID('Guess') IS NOT NULL DROP PROCEDURE Guess;
GO
CREATE PROCEDURE Guess(@letter CHAR)
AS
BEGIN
    IF (SELECT gameStatus FROM Game) >= 2 
        RAISERROR('Game not in state that can accept a guess.', 0, 0);
    UPDATE Game SET gameStatus =2;
    DECLARE @inWord INT
    SET @inWord = (
        SELECT COUNT(*)
    FROM Game
    WHERE CHARINDEX(@letter, word) > 0
    )
    UPDATE Letter
        SET letterStatus = (3 - @inWord)
        WHERE letterValue = @letter

    IF dbo.NumberWrongGuesses() >= dbo.DeathLimit()
        UPDATE Game SET gameStatus = 4
    IF dbo.NumberRightGuesses() >= (SELECT LEN(word) FROM Game)
        UPDATE Game SET gameStatus = 3
END
GO
