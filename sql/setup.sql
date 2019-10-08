-- HANGMAN SETUP SCRIPT
-- ====================

-- Please execute each of the 6 steps separately.


-- 1. Execute to get started
EXEC sp_configure 'clr enabled', 1;
RECONFIGURE;
CREATE DATABASE hangman;
GO
ALTER DATABASE [hangman] SET TRUSTWORTHY ON;
GO

-- 2. Load in the testing framework 
--   (execute the following in a shell prompt)
--   sqlcmd -S localhost -d hangman -U <USER> -P <PWD> -i ./lib/tSQLt.class.sql

-- 3. Prepare testing framework
EXEC hangman.tSQLt.InstallExternalAccessKey;
EXEC master.sys.sp_executesql N'GRANT UNSAFE ASSEMBLY TO [tSQLtExternalAccessKey];';

-- 4. Clean up the setup.
ALTER DATABASE [hangman] SET TRUSTWORTHY OFF;

-- 5. Execute the Hangman program
--   (execute the following in a shell prompt)
--   sqlcmd -S localhost -d hangman -U <USER> -P <PWD> -i ./hangman.sql

-- 6. Now you are ready to run the tests!
--    You can find a starter in "tests.sql"

