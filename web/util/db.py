#!/usr/bin/python3
import os
from psycopg2 import pool

PG_DB_ADDR = os.environ["PG_DB_ADDR"]
PG_DB_NAME = os.environ["PG_DB_NAME"]
PG_DB_UN = os.environ["PG_DB_UN"]
PG_DB_PW = os.environ["PG_DB_PW"]

MIN_CONNS = 1
MAX_CONNS = 10

class PGDB:

    def __init__(self):
        self.pool = pool.SimpleConnectionPool(
            MIN_CONNS, 
            MAX_CONNS,
            user=PG_DB_UN,
            password=PG_DB_PW,
            host=PG_DB_ADDR,
            database=PG_DB_NAME
        )

        if (self.pool):
            print("Connection pool created successfully")
    
    def get_conn(self):
        conn = self.pool.getconn()
        return conn