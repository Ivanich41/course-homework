from flask import Flask
import socket

app = Flask(__name__)

# Роут для /python-app/
@app.route('/python-app/')
def hello_world():
    return f'Hello, World from Python! Hostname: {socket.gethostname()}'

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)