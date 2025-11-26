from flask import Flask, request, jsonify
from flask_cors import CORS
import mysql.connector
from mysql.connector import Error

app = Flask(__name__)
CORS(app)

# Database configuration
DB_CONFIG = {
    'host': 'localhost',
    'user': 'ecommerce_user',
    'password': 'secure_password',
    'database': 'ecommerce_system'
}

# Function to get database connection
def get_db_connection():
    try:
        conn = mysql.connector.connect(**DB_CONFIG)
        return conn
    except Error as e:
        print(f"Database connection error: {e}")
        return None


# Send notification endpoint (placeholder)
@app.route('/api/notifications/send', methods=['POST'])
def send_notification():
    data = request.get_json()
    return jsonify({
        "message": "Notification service endpoint ready",
        "received_data": data,
        "endpoint": "/api/notifications/send",
        "status": "placeholder"
    }), 200


if __name__ == '__main__':
    print("Starting Notification Service on port 5005...")
    app.run(host='0.0.0.0', port=5005, debug=True)