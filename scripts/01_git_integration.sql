--- -----------------------------------------------------------------------
 --Step #1 : Create a Secret to Store the GitHub PAT
-- ------------------------------------------------------------------------
CREATE OR REPLACE SECRET FAOUZI_GITHUB_SECRET
TYPE = PASSWORD
USERNAME = 'github-user-name'
PASSWORD = 'github-access-token';

show secrte;

DESCRIBE SECRET FAOUZI_GITHUB_SECRET;

--- -----------------------------------------------------------------------
 --Step #2 : Create a Git API Integration
-- ------------------------------------------------------------------------
CREATE OR REPLACE API INTEGRATION FAOUZI_GITHUB_API_INTEGRATION
API_PROVIDER = GIT_HTTPS_API
API_ALLOWED_PREFIXES = ('https://github.com/ALYFAOUZI')
ALLOWED_AUTHENTICATION_SECRETS = (FAOUZI_GITHUB_SECRET)
ENABLED = TRUE;

SHOW INTEGRATIONS;
SHOW API INTEGRATIONS;

DESCRIBE API INTEGRATION FAOUZI_GITHUB_API_INTEGRATION;

--- -----------------------------------------------------------------------
 --Step #3 : Create a Git Repository
-- ------------------------------------------------------------------------

CREATE OR REPLACE GIT REPOSITORY DEMO_REPO
API_INTEGRATION = FAOUZI_GITHUB_API_INTEGRATION
GIT_CREDENTIALS = FAOUZI_GITHUB_SECRET
origin ='https://github.com/ALYFAOUZI/build-dcm-demo.git';

SHOW GIT REPOSITORIES;

DESCRIBE GIT REPOSITORY DEMO_REPO;

GRANT READ ON GIT REPOSITORY DEMO_REPO TO ROLE DEMO_ROLE;

USE ROLE DEMO_ROLE;


--- -----------------------------------------------------------------------
 --Step #4 : Working with Git Repository
-- ------------------------------------------------------------------------
--using LIST "File paths in git repositories must specify a scope"
--For Example a branch Name, a tag name or a valid commit hash
-- Commit hashes are between 6 and 40 characters long.

LIST @DEMO_REPO/brances/main;
LIST @DEMO_REPO/brances/tag_name;
LIST @DEMO_REPO/brances/commit_hash;


--Show commands
SHOW GIT BRANCHES IN DEMO_REPO;
SHOW GIT TAGS IN DEMO_REPO;

-- Fetch new changes
ALTER GIT REPOSITORY DEMO_REPO FETCH;















