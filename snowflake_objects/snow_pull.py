# pull existing objects into files
import snowflake.connector
import json

import os
from retry import retry
import argparse

from rich import print, pretty
from rich.progress import Progress
from rich.tree import Tree
import warnings

warnings.simplefilter(action="ignore", category=UserWarning)
pretty.install()

### Config
PARENT_DIR = "DEMO_DB"

print("Schema focused structure")
tree = Tree(PARENT_DIR)
print(tree)

@retry(tries=3, delay=1)
def get_snowflake(db):
    with open("cred.json","r") as f:
        cred = json.load(f)

    conn = snowflake.connector.connect(
        user=cred["userid"],
        password=cred["password"],
        account=cred["account"],
        database_name=db,
        schema_name="public",
        warehouse_name="dev_etl_wh",
        role_name="DEVELOPER__B_ROLE"
    )
 
    return conn.cursor()

def parse_args():
    parser = argparse.ArgumentParser(description="Write local files to Snowflake")
    parser.add_argument(
        "-d",
        "--database",
        nargs=1,
        required=True,
        help="Choose individual database",
    )
    
    return parser.parse_args()

def safe_open(path, t):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    return open(path, t)

with Progress() as progress:
    args = parse_args()
    print(args)

    cnx = get_snowflake(args.database[0])
    cnx.execute("use database " + args.database[0])
    cnx.execute("use warehouse dev_etl_wh")

    progress.console.log("Fetching tables...")
    cnx.execute("select table_schema, table_name from information_schema.tables where table_type = 'BASE TABLE'")
    rows = cnx.fetchall()

    #progress.console.log("Tables fetched")
    task = progress.add_task("Tables", total=len(rows))
    
    for r in rows:
        get_ddl = "select get_ddl('TABLE', '" + r[0] + '.' + r[1] + "', true)"
        cnx.execute(get_ddl)
        tbldef = str(cnx.fetchall()[0][0])
        tbldef = tbldef.replace("\\t", "").replace("\\n", chr(10))
        #print(tbldef)
        
        if tbldef is None:
            progress.console.log(tbldef)

        with safe_open(f"{PARENT_DIR}/{r[0]}/tables/{r[1]}.sql".lower(), "w") as table:
            table.write(f"{tbldef.lower()}")
        progress.advance(task)

    progress.console.log("Fetching views...")
    cnx.execute("select table_schema, table_name, view_definition from information_schema.views where table_schema !='INFORMATION_SCHEMA'")
    rows = cnx.fetchall()

    #progress.console.log("Views fetched")
    task = progress.add_task("Views", total=len(rows))
    
    for r in rows:
        if r[2] is None:
            progress.console.log(r)

        with safe_open(f"{PARENT_DIR}/{r[0]}/views/{r[1]}.sql".lower(), "w") as view:
            view.write(f"{r[2]}".lower())
                
        progress.advance(task)

    progress.console.log("Fetching procs...")
    cnx.execute("select procedure_schema, procedure_name, procedure_definition, argument_signature, data_type, procedure_language from information_schema.procedures")
    rows = cnx.fetchall()
   
    #progress.console.log("Procs fetched")
    task = progress.add_task("Procedures", total=len(rows))
    
    for r in rows:
        if r[2] is None:
            progress.console.log(r)

        with safe_open(f"{PARENT_DIR}/{r[0]}/procedures/{r[1]}.sql".lower(), "w") as proc:
            proc.write(
                f"create or replace procedure {r[0]}.{r[1]} {r[3]}\n"
                f"returns {r[4]}\n"
                f"language {r[5]}\n"
                f"as\n"
                f"{r[2]};".lower()
            )

        progress.advance(task)

    progress.console.log("Fetching functions...")
    cnx.execute("select function_schema, function_name, function_definition, argument_signature, data_type, function_language from information_schema.functions")
    rows = cnx.fetchall()
    
    #progress.console.log("Functions fetched")
    task = progress.add_task("Functions", total=len(rows))

    for r in rows:
        with safe_open(f"{PARENT_DIR}/{r[0]}/functions/{r[1]}.sql".lower(), "w") as fun:
            fun.write(
                f"create or replace function {r[0]}.{r[1]} {r[3]}\n"
                f"returns {r[4]}\n"
                f"language {r[5]}\n"
                f"as\n"
                f"{r[2]};".lower()
            )
        progress.advance(task)

    cnx.close()
