USE SCHEMA DEMO_DB.DEMO_SCHEMA;
--- -----------------------------------------------------------------------
 --Step #1 : Execute scripts in a Git Repository Stage
-- ------------------------------------------------------------------------
LIST @GIT_REPO/branches/main;

LIST @GIT_REPO/branches/main/scripts/02_execute_immediate;

SHOW TABLES;

EXECUTE IMMEDIATE FROM @GIT_REPO/branches/main/scripts/02_execute_immediate/create-inventory.sql