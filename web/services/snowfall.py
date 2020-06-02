#!/usr/bin/python3
import os
import psycopg2
from util.db import PGDB

PG_DB_ADDR = os.environ["PG_DB_ADDR"]
PG_DB_NAME = os.environ["PG_DB_NAME"]
PG_DB_UN = os.environ["PG_DB_UN"]
PG_DB_PW = os.environ["PG_DB_PW"]


class ServiceSnowfall:

    def __init__(self, db_conn_pool):
        self._db_conn_pool = db_conn_pool

    def get_snowfall_for_resort(self, resort_name):
        select_stmt = "SELECT * FROM %s_daily ORDER BY date ASC" % (resort_name)

        conn = self._db_conn_pool.get_conn()
        cur = conn.cursor()
        cur.execute(select_stmt)
        rows = cur.fetchall()

        headers = [desc[0] for desc in cur.description]
        data = []
        for row in rows:
            datum = {}
            for i, col in enumerate(headers):
                datum[col] = row[i]
            data.append(datum)
        return data

