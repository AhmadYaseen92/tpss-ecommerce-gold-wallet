/*
Recreate database script (SQL Server).
Usage example (sqlcmd):
  sqlcmd -S <server> -v DbName="GoldWalletSystemDb" -i recreate-database.sql
Then apply EF migrations and run Seed/sample-data.sql.
*/

:setvar DbName GoldWalletSystemDb

IF DB_ID('$(DbName)') IS NOT NULL
BEGIN
    ALTER DATABASE [$(DbName)] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [$(DbName)];
END;
GO

CREATE DATABASE [$(DbName)];
GO
