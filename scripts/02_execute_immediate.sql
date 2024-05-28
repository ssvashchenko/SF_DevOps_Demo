USE SCHEMA DEV_DB.DEV_SCHEMA;
--- -----------------------------------------------------------------------
 --Step #1 : Execute scripts in a Git Stage
-- ------------------------------------------------------------------------
LIST @DEMO_REPO/branches/main;
LIST @DEMO_REPO/branches/main/scripts/02_execute_immediate;

SHOW TABLES;

EXECUTE IMMEDIATE FROM @DEMO_REPO/branches/main/scripts/02_execute_immediate/create-inventory.sql
