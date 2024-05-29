--- -----------------------------------------------------------------------
 --Step #0 : Database Change Management
-- ------------------------------------------------------------------------
USE ROLE SVASHCHENKO__U_ROLE;
USE WAREHOUSE DEV_ETL_WH;
USE SCHEMA DEMO_DB.DEMO_SHEMA;
--- -----------------------------------------------------------------------
 --Step #1 : Try out the CREATE OR ALTER Command
-- ------------------------------------------------------------------------
SHOW TABLES;

--Create the table with one column
CREATE OR ALTER TABLE FOO 
(
    COLUMN1 VARCHAR
);

DESCRIBE TABLE FOO;

--Add second column
CREATE OR ALTER TABLE FOO 
(
    COLUMN1 VARCHAR,
    COLUMN2 VARCHAR
);

DROP TABLE FOO;
--Notes: All limitations of the existing ALTER TABLE command apply
