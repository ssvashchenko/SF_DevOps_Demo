--- -----------------------------------------------------------------------
 --Step #0 : Database Change Management
-- ------------------------------------------------------------------------
USE ROLE DEMO_ROLE;
USE WAREHOUSE DEMO_WH;
USE SCHEMA DEMO_DB.DEMO_SH;
--- -----------------------------------------------------------------------
 --Step #1 : Try out the CREATE OR ALTER Command
-- ------------------------------------------------------------------------
SHOW TABLES;
--Create the table with one column
CREATE OR ALTER FOO 
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
