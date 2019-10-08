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


IF OBJECT_ID('Guess') IS NOT NULL DROP PROCEDURE Guess;
GO
CREATE PROCEDURE Guess(@letter CHAR)
AS
BEGIN
    IF (SELECT gameStatus from Game) >= 2 
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
