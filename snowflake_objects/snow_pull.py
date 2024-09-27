# pull existing sprocs into files (handle already deployed sprocs)


import pandas as pd
import sqlalchemy as sqa
import urllib

# import snowflake.connector
import functools
import multiprocessing

from signal import signal, SIGINT
from sys import exit
import os
from retry import retry
import argparse
import functools
import itertools
import pathlib

from rich import print, pretty
from rich.table import Table
from rich.progress import BarColumn, Progress, TaskID, TextColumn, TimeRemainingColumn, TimeElapsedColumn
from rich.progress import track
from rich.console import Console
from rich.tree import Tree


import time
import warnings

warnings.simplefilter(action="ignore", category=UserWarning)

pretty.install()


### Config
PARENT_DIR = "Transform"


print("Ideal Schema Focused Project Structure")
tree = Tree(PARENT_DIR)
etl_tree = tree.add("ETL")
ftree = etl_tree.add("functions")

ftree.add("FNETLKEY")
ftree.add("FNGETSDLC")

ptree = etl_tree.add("procedures")
ptree.add("SPCLEANINIT")
ptree.add("SPLOADINIT")

dmr_tree = tree.add("DMR")
dmr_tree.add("functions").add("...")
dmr_tree.add("procedures").add("...")

print(tree, "\n\n")


@retry(tries=3, delay=1)
def get_snowflake(db, sma="public"):
    global snowflake_engine
    snowflake_engine = sqa.create_engine(
        "snowflake://{user}:{password}@{account}/{database_name}/{schema_name}?warehouse={warehouse_name}&role={role_name}".format(
            user="TKIND",
            password="",
            account="mk50743.west-us-2.azure",
            database_name=db,
            schema_name=sma,
            warehouse_name="SANDBOX_XSMALL",
            role_name="udp_engineer",
        )
    )
    return snowflake_engine.connect().execution_options(autocommit=True)


def safe_open(path, t):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    return open(path, t)


with Progress() as progress:
    cnx = get_snowflake("transform_dev")

    progress.console.log("Fetching procedures")
    res = cnx.execute("select * from transform_dev.information_schema.procedures")
    res = [r._asdict() for r in res.fetchall()]
    progress.console.log("Procedures fetched")
    task = progress.add_task("Procedures", total=len(res),)
    for d in res:
        # if len(d["procedure_definition"]) < 20:
        if d["procedure_definition"] is None:
            progress.console.log(d)
        with safe_open(f"{PARENT_DIR}/{d['procedure_schema']}/procedures/{d['procedure_name']}.sql", "w") as sproc:
            sproc.write(
                (
                    f"CREATE OR REPLACE PROCEDURE {d['procedure_schema']}.{d['procedure_name']} {d['argument_signature']}\n"
                    f"RETURNS {d['data_type']}\n"
                    "LANGUAGE JAVASCRIPT\n"
                    "EXECUTE AS CALLER\n"
                    "AS\n"
                    "$$\n"
                    f"{d['procedure_definition']}$$;"
                )
            )
        progress.advance(task)

    progress.console.log("Fetching sequences")
    res = cnx.execute("select * from transform_dev.information_schema.sequences")
    res = [r._asdict() for r in res.fetchall()]
    progress.console.log("Sequences fetched")
    task = progress.add_task("Sequences", total=len(res),)
    for d in res:
        with safe_open(f"{PARENT_DIR}/{d['sequence_schema']}/sequences/{d['sequence_name']}.sql", "w") as seq:
            seq.write(
                (
                    f"CREATE SEQUENCE IF NOT EXISTS {d['sequence_schema']}.{d['sequence_name']}\n"
                    "WITH\n"
                    f"START WITH {d['start_value']}\n"
                    f"INCREMENT BY {d['INCREMENT']}\n"
                    f"COMMENT = '{d['comment']}'\n;"
                )
            )
        progress.advance(task)

    progress.console.log("Fetching functions")
    res = cnx.execute("select * from transform_dev.information_schema.functions")
    res = [r._asdict() for r in res.fetchall()]
    progress.console.log("Functions fetched")
    task = progress.add_task("Functions", total=len(res),)
    for d in res:
        with safe_open(f"{PARENT_DIR}/{d['function_schema']}/functions/{d['function_name']}.sql", "w") as fun:
            fun.write(
                (
                    f"CREATE OR REPLACE FUNCTION {d['function_schema']}.{d['function_name']} {d['argument_signature']}\n"
                    f"RETURNS {d['data_type']}\n"
                    f"COMMENT = '{d['comment']}'\n"
                    f"AS\n$$\n{d['function_definition']}\n$$\n;"
                )
            )
        progress.advance(task)

    cnx.close()
