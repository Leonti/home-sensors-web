from flask import Flask, Response, request, send_from_directory
import json
import sqlite3
import sys

app = Flask(__name__)
conn = sqlite3.connect(sys.argv[1])

@app.route('/')
def index():
    return app.send_static_file('index.html')

@app.route('/js/<path:path>')
def send_js(path):
    return send_from_directory('static/js', path)

@app.route('/css/<path:path>')
def send_css(path):
    return send_from_directory('static/css', path)

@app.route("/log", methods = ['GET'])
def get_log():
    return Response(json.dumps(read_log(request.args.get('start'), request.args.get('end'))), status=200, mimetype='application/json')

def read_log(start, end):
    if start is None:
        start = 0
    if end is None:
        end = sys.maxint
    c = conn.cursor()
    c.execute('SELECT temperature, humidity, co2, timestamp  FROM log WHERE timestamp >= ? AND timestamp <= ? ORDER BY timestamp DESC', (start, end))
    rows = c.fetchall()
    return [{'temperature' : round(row[0], 2), 'humidity' : round(row[1], 2), 'co2' : row[2], 'timestamp' : row[3]} for row in rows]

if __name__ == "__main__":
    try:
        app.run(host='0.0.0.0', port=5000)
    finally:
        conn.close()
