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
    
    
# Get customer profile endpoint (with basic DB query)
@app.route('/api/customers/<int:customer_id>', methods=['GET'])
def get_customer(customer_id):
    conn = get_db_connection()
    if conn:
        try:
            cursor = conn.cursor(dictionary=True)
            cursor.execute("SELECT * FROM customers WHERE customer_id = %s", (customer_id,))
            customer = cursor.fetchone()
            cursor.close()
            conn.close()
            
            if customer:
                return jsonify({
                    "status": "success",
                    "customer": customer
                }), 200
            else:
                return jsonify({
                    "status": "not_found",
                    "message": f"Customer {customer_id} not found"
                }), 404
        except Error as e:
            return jsonify({
                "status": "error",
                "message": str(e)
            }), 500
    else:
        return jsonify({
            "status": "error",
            "message": "Database connection failed"
        }), 500

# Get customer order history endpoint (placeholder)
@app.route('/api/customers/<int:customer_id>/orders', methods=['GET'])
def get_customer_orders(customer_id):
    return jsonify({
        "message": "Customer order history endpoint ready",
        "customer_id": customer_id,
        "endpoint": "/api/customers/{customer_id}/orders",
        "status": "placeholder"
    }), 200

# Update customer loyalty points endpoint (placeholder)
@app.route('/api/customers/<int:customer_id>/loyalty', methods=['PUT'])
def update_loyalty(customer_id):
    data = request.get_json()
    return jsonify({
        "message": "Loyalty points update endpoint ready",
        "customer_id": customer_id,
        "received_data": data,
        "status": "placeholder"
    }), 200


if __name__ == '__main__':
    print("Starting Customer Service on port 5004...")
    app.run(host='0.0.0.0', port=5004, debug=True)