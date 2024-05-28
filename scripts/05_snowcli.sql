USE ROLE DEMO_ROLE;
USE WAREHOUSE DEMO_WH;
USE SCHEMA DEMO_DB.DEMO_SCHEMA;

--- -----------------------------------------------------------------------
 --Step #1 : Run first SQL Statement from snowCLI
-- ------------------------------------------------------------------------
--Configure ~/.snowflake/config.toml
--Set password in the SNOWFLAKE_CONNECTIONS_DEMO_PASSWORD environment variable
--export SNOWFLAKE_CONNECTIONS_DEMO_PASSWORD=""

--Run a simple Hello world example
--snow sql -q " SELECT 'Hello World!'"

--- -----------------------------------------------------------------------
 --Step #2 : Run our DCM process from snowCLI
 -- ------------------------------------------------------------------------

 --Review the deploy_object.sql script
 DESCRIBE TABLE MY_INVENTORY;

 --snow sql -q "ALTER GIT REPOSITORY DEMO_REPO FETCH"
 --snow sql -q "EXECUTE IMMEDIATE FROM @DEMO_REPO/branches/main/snowflake_objects/deploy_objects.sql

 DESCRIBE TABLE MY_INVENTORY;


 