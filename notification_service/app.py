from flask import Flask
from flask_cors import CORS
from config import SERVICE_PORT, SERVICE_HOST, DEBUG
from resources import send_notification

app = Flask(__name__)
CORS(app)


# Route definitions
@app.route('/api/notifications/send', methods=['POST'])
def notification():
    return send_notification()


if __name__ == '__main__':
    print(f"Starting Notification Service on port {SERVICE_PORT}...")
    app.run(host=SERVICE_HOST, port=SERVICE_PORT, debug=DEBUG)