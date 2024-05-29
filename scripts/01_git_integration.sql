--- -----------------------------------------------------------------------
 --Step #1 : Create a Secret to Store the GitHub PAT
-- ------------------------------------------------------------------------
USE SCHEMA DEMO_DB.DEMO_SCHEMA;

CREATE OR REPLACE SECRET SSV_SECRET
TYPE = PASSWORD
USERNAME = 'ssvashchenko'
PASSWORD = 'SeniorSergio1970';

show secrets;

DESCRIBE SECRET SSV_SECRET;

--- -----------------------------------------------------------------------
 --Step #2 : Create a Git API Integration
-- ------------------------------------------------------------------------
CREATE OR REPLACE API INTEGRATION GIT_API_INTEGRATION
API_PROVIDER = GIT_HTTPS_API
API_ALLOWED_PREFIXES = ('https://github.com/ssvashchenko')
ALLOWED_AUTHENTICATION_SECRETS = (SSV_SECRET)
ENABLED = TRUE;

SHOW INTEGRATIONS;
SHOW API INTEGRATIONS;

DESCRIBE API INTEGRATION GIT_API_INTEGRATION;

--- -----------------------------------------------------------------------
 --Step #3 : Create a Git Repository
-- ------------------------------------------------------------------------

CREATE OR REPLACE GIT REPOSITORY GIT_REPO
API_INTEGRATION = GIT_API_INTEGRATION
GIT_CREDENTIALS = SSV_SECRET
origin ='https://github.com/ssvashchenko/SF_DevOps_Demo.git';

SHOW GIT REPOSITORIES;

DESCRIBE GIT REPOSITORY GIT_REPO;

GRANT READ ON GIT REPOSITORY GIT_REPO TO ROLE SVASHCHENKO__U_ROLE;

USE ROLE SVASHCHENKO__U_ROLE;


--- -----------------------------------------------------------------------
 --Step #4 : Working with Git Repository
-- ------------------------------------------------------------------------
--using LIST "File paths in git repositories must specify a scope"
--For Example a branch Name, a tag name or a valid commit hash
-- Commit hashes are between 6 and 40 characters long.

LIST @GIT_REPO/branches/main;
LIST @GIT_REPO/branches/tag_name;
LIST @GIT_REPO/branches/commit_hash;


--Show commands
SHOW GIT BRANCHES IN GIT_REPO;
SHOW GIT TAGS IN GIT_REPO;

-- Fetch new changes
ALTER GIT REPOSITORY GIT_REPO FETCH;















