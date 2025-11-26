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

def get_db_connection():
    try:
        conn = mysql.connector.connect(**DB_CONFIG)
        return conn
    except Error as e:
        print(f"Database connection error: {e}")
        return None


# Check inventory endpoint (placeholder with basic DB query)
@app.route('/api/inventory/check/<int:product_id>', methods=['GET'])
def check_inventory(product_id):
    conn = get_db_connection()
    if conn:
        try:
            cursor = conn.cursor(dictionary=True)
            cursor.execute("SELECT * FROM inventory WHERE product_id = %s", (product_id,))
            product = cursor.fetchone()
            cursor.close()
            conn.close()
            
            if product:
                return jsonify({
                    "status": "success",
                    "product": product
                }), 200
            else:
                return jsonify({
                    "status": "not_found",
                    "message": f"Product {product_id} not found"
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

# Update inventory endpoint (placeholder)
@app.route('/api/inventory/update', methods=['PUT'])
def update_inventory():
    return jsonify({
        "message": "Inventory update endpoint ready",
        "endpoint": "/api/inventory/update",
        "status": "placeholder"
    }), 200


if __name__ == '__main__':
    print("Starting Inventory Service on port 5002...")
    app.run(host='0.0.0.0', port=5002, debug=True)