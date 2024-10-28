import snowflake.connector
import json

from sys import exit
from retry import retry
import argparse
import itertools
import pathlib
from dataclasses import dataclass, astuple

from rich import print, pretty
from rich.table import Column, Table
from rich.progress import track

from datetime import datetime, timedelta
import warnings

warnings.simplefilter(action="ignore", category=UserWarning)
pretty.install()

@dataclass
class Deployable:
    name: str
    modified_time: datetime
    created_time: datetime
    sql: str = ""
    deploy: bool = False

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
 
    return conn

def parse_args():
    parser = argparse.ArgumentParser(description="Write local files to Snowflake")
    parser.add_argument(
        "-d",
        "--database",
        nargs=1,
        required=True,
        help="Choose individual database",
    )
    
    parser.add_argument(
        "-s",
        "--schema",
        nargs=1,
        # choices=["stg","vault","dim"],
        required=True,
        help="choose individual schema",
    )
    
    parser.add_argument(
        "-f",
        "--filter",
        nargs=1,
        type=int,
        default=[1],
        help="Filter files by modified time in days",
    )

    return parser.parse_args()

if __name__ == "__main__":

    # parse args 
    args = parse_args()
    print(args)
    
    # grab all .sql files in schema dir
    filenames = sorted(list(itertools.chain(*[list(pathlib.Path(f"{args.database[0]}/{args.schema[0]}/").glob("**/*.sql"))])))
    #print(filenames)

    today = datetime.today()
    delpoyables = [
        Deployable(
            name=args.schema[0] + "." + f.stem,
            modified_time=datetime.fromtimestamp(f.stat().st_mtime),
            created_time=datetime.fromtimestamp(f.stat().st_ctime),
            sql=open(f).read(),
            deploy=datetime.fromtimestamp(f.stat().st_mtime) >= today - timedelta(days=args.filter[0]),
        )
        for f in filenames
    ]

    pending_actions = Table(
        "script",
        "modified_time",
        "created_time",
        "sql",
        Column("action", justify="right"),
        title="Deploying",
        show_header=True,
        header_style="bold",
        show_lines=False,
    )
    for depl in [d for d in delpoyables if d.deploy]:
        pending_actions.add_row(*[str(v)[:38] for v in astuple(depl)])
    print(pending_actions)

    action = input("Continue? [0 - Cancel / 1 - Deploy all / 2 - Deploy individually]: ") 
    
    # Cancel
    if action == "0":
        print("Deployment cancelled...")
        exit(0)

    # Deploy all
    elif action == "1":
        # create snowflake connection
        cnx = get_snowflake(args.database[0])
        cnx.cursor().execute("use database " + args.database[0])
    
        # iterate over list of ddl scripts to deploy 
        try:
            for d in track([d for d in delpoyables if d.deploy], description="Deploying..."):
                cnx.cursor().execute(d.sql)
                #print(d.sql[:360] + "...")
            
        except Exception as e:
            print(e)

        finally:
            cnx.close()    
    
    # Deploy individually
    elif action == "2":
        # create snowflake connection
        cnx = get_snowflake(args.database[0])
        cnx.cursor().execute("use database " + args.database[0])
    
        # iterate over list of ddl scripts to deploy 
        try:
            for d in [d for d in delpoyables if d.deploy]:
                if input("Deploy file " + d.name + " [y/n]: ") != "y":
                    print("Skipping " + args.schema[0] + "." + d.name + "...")
                    continue
                else:
                    print("Deploying " + args.schema[0] + "." + d.name + "...")
                    cnx.cursor().execute(d.sql)
                    
            
        except Exception as e:
            print(e)

        finally:
            cnx.close()    
    
    # Incorrect selection
    else:
        print("Incorrect selection, cancelling...")
        exit(0)
