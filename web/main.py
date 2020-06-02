#!/usr/bin/python3
import os
import json
import socket
from flask import Flask, send_from_directory, jsonify
from flask_cors import CORS
from services.snowfall import ServiceSnowfall
from util.db import PGDB

app = Flask(__name__, static_folder='react_app/build')
CORS(app)
pgdb = PGDB()
CONTAINER_ID = socket.gethostname()


@app.route('/snowfall/<resort_name>')
def snowfall(resort_name):
    snow_srv = ServiceSnowfall(pgdb)
    return jsonify(snow_srv.get_snowfall_for_resort(resort_name))


@app.route('/container_id')
def container_id():
    return jsonify({'containerID': CONTAINER_ID})


@app.route('/', defaults={'path': ''})
@app.route('/<path:path>')
def serve(path):
    if path != "" and os.path.exists("frontend/build/" + path):
        return send_from_directory('frontend/build', path)
    else:
        return send_from_directory('frontend/build', 'index.html')

if __name__ == '__main__':
    app.run(host='0.0.0.0', use_reloader=True, port=5000, threaded=True)