#!/usr/bin/python3
from bs4 import BeautifulSoup
from datetime import datetime
from time import sleep
import requests
import psycopg2
import json
import os

PG_DB_ADDR = os.environ["PG_DB_ADDR"]
PG_DB_NAME = os.environ["PG_DB_NAME"]
PG_DB_UN = os.environ["PG_DB_UN"]
PG_DB_PW = os.environ["PG_DB_PW"]

DB_SETUP = """
CREATE TABLE IF NOT EXISTS squaw_daily (
    date timestamp default NULL,
    resort_name varchar(32),
    oneday_6000 int,
    cumulative_6000 int,
    oneday_8200 int,
    cumulative_8200 int
);

DELETE FROM squaw_daily;

CREATE TABLE IF NOT EXISTS alpine_daily (
    date timestamp default NULL,
    resort_name varchar(32),
    oneday_6000 int,
    cumulative_6000 int,
    oneday_8200 int,
    cumulative_8200 int
);

DELETE FROM alpine_daily;
"""

def camel_case(value):
    output = "".join(x for x in value.title() if x.isalnum())
    return output[0].lower() + output[1:]


def scrape_snowfall():
    conn_string = "dbname='%s' user='%s' host='%s' password='%s'" % (PG_DB_NAME, PG_DB_UN, PG_DB_ADDR, PG_DB_PW)
    conn = None
    cur = None 

    try:
        print('Getting connection to the database (%s)...' % conn_string)
        conn = psycopg2.connect(conn_string)
        cur = conn.cursor()
        print('Connected to database.')
    except:
        print("Unable to connect to the database.")

    if cur is not None:
        try:
            print('Executing DB setup...')
            cur.execute(DB_SETUP)
            print('DB setup done.')
        except:
            print("Unable to setup DB.")

    resortResources = [
        {
            "name": "alpine",
            "url": "https://squawalpine.com/skiing-riding/weather-conditions-webcams/alpine-meadows-snowfall-tracker"
        },
        {
            "name": "squaw",
            "url": "https://squawalpine.com/skiing-riding/weather-conditions-webcams/squaw-valley-snowfall-tracker"
        }
    ]

    for resortResource in resortResources:
        headers = []
        data = []
        resort_name = resortResource["name"]
        resort_url = resortResource["url"]
        resp = requests.get(resort_url)
        soup = BeautifulSoup(resp.text, features="html.parser")
        snowfall_table = soup.select("div.tpl_table table")[0]

        for tr in snowfall_table.thead.tr:
            headers.append(camel_case(tr.text))

        for tr in snowfall_table.tbody:
            date = ""
            datum = {
                "resortName": resort_name
            }
            for i, cell in enumerate(tr):
                if i == 0:
                    pyDate =  datetime.strptime(cell.text.strip(), '%A, %B %d, %Y').date()
                    datum['date'] = pyDate.strftime('%Y-%m-%d')
                else:
                    datum[headers[i]] = cell.text.replace('"', '')
            data.append(datum)

        sorted_data = sorted(data, key=lambda i: i['date'], reverse=True)

        if resort_name == "squaw":
            insert_statement_rows = ",".join([
                "('%s','%s',%s,%s,%s,%s)" % (
                    x["date"], x["resortName"],
                    x["620024Hr"], x["6200Cumulative"],
                    x["800024Hr"], x["8000Cumulative"]
                ) for x in sorted_data
            ])
        elif resort_name == "alpine":
            insert_statement_rows = ",".join([
                "('%s','%s',%s,%s,%s,%s)" % (
                    x["date"], x["resortName"],
                    x["680024Hr"], x["6800Cumulative"],
                    x["800024Hr"], x["8000Cumulative"]
                ) for x in sorted_data
            ])

        insert_statement = "INSERT INTO %s_daily VALUES %s;" % (resort_name, insert_statement_rows)
        print("Inserting data for %s..." % resort_name)
        cur.execute(insert_statement)
        print("Data inserted for %s." % resort_name)

    cur.close()
    conn.commit();

if __name__ == "__main__":
    print("Scraping web resources...")
    scrape_snowfall()
    print("Web resources scraped.")