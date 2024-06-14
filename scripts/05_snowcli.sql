USE ROLE SVASHCHENKO__U_ROLE;
USE WAREHOUSE DEV_ETL_WH;
USE SCHEMA DEMO_DB.DEMO_SHEMA;

--- -----------------------------------------------------------------------
 --Step #1 : Run first SQL Statement from snowCLI
-- ------------------------------------------------------------------------
--Configure ~/.snowflake/config.toml
--Set password in the SNOWFLAKE_CONNECTIONS_DEMO_PASSWORD environment variable
--export SNOWFLAKE_CONNECTIONS_DEMO_PASSWORD=""

--Run a simple Hello world example
snowsql -q " SELECT 'Hello World!'"

--- -----------------------------------------------------------------------
 --Step #2 : Run our DCM process from snowCLI
 -- ------------------------------------------------------------------------

 --Review the deploy_object.sql script
 DESCRIBE TABLE MY_INVENTORY;

 snowsql -q "ALTER GIT REPOSITORY GIT_REPO FETCH";
 snowsql -q "EXECUTE IMMEDIATE FROM @GIT_REPO/branches/main/snowflake_objects/deploy_objects.sql;

 DESCRIBE TABLE MY_INVENTORY;


 