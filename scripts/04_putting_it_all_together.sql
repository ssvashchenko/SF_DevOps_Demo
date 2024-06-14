
USE ROLE SVASHCHENKO__U_ROLE;
USE WAREHOUSE DEV_ETL_WH;
USE SCHEMA DEMO_DB.DEMO_SHEMA;
--- -----------------------------------------------------------------------
 --Step #1 : Review the "snowflake_objects" folder
-- ------------------------------------------------------------------------
--Browsethe foldr structure

--- -----------------------------------------------------------------------
 --Step #2 : Run CREATE OR ALTER with EXECUTE IMMEDIATE FROM <file>
-- ------------------------------------------------------------------------
LIST @GIT_REPO/branches/main/snowflake_objects;

DESCRIBE TABLE MY_INVENTORY;

--This should make no changes to the table since the destination is the same as before
EXECUTE IMMEDIATE FROM @GIT_REPO/branches/main/snowflake_objects/databases/demo_db/schemas/demo_schema/tables/my_inventory.sql;

DESCRIBE TABLE MY_INVENTORY;

--- -----------------------------------------------------------------------
 --Step #3 : Make a change to the table definition and commit it to your repo
 --example databases-demo_db-demo_schemas-tables my_inventory.sql
 -- add any column (Description varchar)
 --commit changes

-- ------------------------------------------------------------------------
ALTER GIT REPOSITORY GIT_REPO FETCH;

--APPLY THE NEW CHANGES declaratively
EXECUTE IMMEDIATE FROM @GIT_REPO/branches/main/snowflake_objects/databases/demo_db/schemas/demo_schema/tables/my_inventory.sql;
EXECUTE IMMEDIATE FROM @GIT_REPO/branches/main/snowflake_objects/databases/demo_db/schemas/demo_schema/views/v_my_inventory.sql;

DESCRIBE TABLE MY_INVENTORY;

SELECT * FROM MY_INVENTORY;
SELECT * FROM V_MY_INVENTORY;


