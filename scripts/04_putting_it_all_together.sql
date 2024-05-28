USE  ROLE DEMO_ROLE;
USE WAREHOUSE DEMO_WH;
USE SCHEMA DEMO_BB.DEMO_SH;

--- -----------------------------------------------------------------------
 --Step #1 : Review the "snowflake_objects" folder
-- ------------------------------------------------------------------------
--Browsethe foldr structure

--- -----------------------------------------------------------------------
 --Step #2 : Run CREATE OR ALTER with EXECUTE IMMEDIATE FROM <file>
-- ------------------------------------------------------------------------
LIST @DEMO_REPO/branches/main/snowflake_objects;

DECRIBE TABLE MY_INVENTORY;
--This should make no changes to the table since the destination is the same as before
EXECUTE IMMEDIATE FROM @DEMO_REPO/branches/main/snowflake_objects/demo_db/schemas/demo_schema/tables/my_inventory.sql;

DESCRIBE TABLE MY_INVENTORY;

--- -----------------------------------------------------------------------
 --Step #3 : Make a change to the table definition and commit it to your repo
 --exemple databases-demo_db-demo_schemas-tables my_inventory.sql
 -- add column Description varchar 
 --commit changes

-- ------------------------------------------------------------------------
ALER GIT REPOSITORY DEMO_REPO FETCH ;
--APPLY THE NEW CHANGES declaratively
EXECUTE IMMEDIATE FROM @DEMO_REPO/branches/main/snowflake_objects/databases/demo_db/schemas/tables/my_inventory.sql 
DESCRIBE TABLE MY_INVENTORY;
SELECT * FROM MY_INVENTORYl;



