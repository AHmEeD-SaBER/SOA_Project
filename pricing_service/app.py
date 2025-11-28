from flask import Flask, request, jsonify
from flask_cors import CORS
import mysql.connector
from mysql.connector import Error
import requests

app = Flask(__name__)
CORS(app)

# Database configuration
DB_CONFIG = {
    'host': 'localhost',
    'user': 'ecommerce_user',
    'password': 'secure_password',
    'database': 'ecommerce_system'
}

# Service URLs
INVENTORY_SERVICE_URL = "http://localhost:5002"

# Function to get database connection
def get_db_connection():
    try:
        conn = mysql.connector.connect(**DB_CONFIG)
        return conn
    except Error as e:
        print(f"Database connection error: {e}")
        return None

# Calculate pricing endpoint
@app.route('/api/pricing/calculate', methods=['POST'])
def calculate_pricing():
    try:
        data = request.get_json()
        
        if not data:
            return jsonify({
                "status": "error",
                "message": "No data provided"
            }), 400
            
        products = data.get('products')
        region = data.get('region', 'default')
        
        if not products or not isinstance(products, list):
            return jsonify({
                "status": "error",
                "message": "products list is required"
            }), 400
            
        conn = get_db_connection()
        if not conn:
            return jsonify({
                "status": "error",
                "message": "Database connection failed"
            }), 500
            
        cursor = conn.cursor(dictionary=True)
        
        subtotal = 0
        total_discount = 0
        itemized_breakdown = []
        
        try:
            for product in products:
                product_id = product.get('product_id')
                quantity = product.get('quantity')
                
                if not product_id or not quantity:
                    continue
                    
                # Get base price from Inventory Service
                try:
                    inventory_response = requests.get(
                        f"{INVENTORY_SERVICE_URL}/api/inventory/check/{product_id}",
                        timeout=5
                    )
                    
                    if inventory_response.status_code != 200:
                        continue
                        
                    inventory_data = inventory_response.json()
                    if inventory_data.get('status') != 'success':
                        continue
                        
                    product_info = inventory_data.get('product', {})
                    unit_price = float(product_info.get('unit_price', 0))
                    product_name = product_info.get('product_name', f'Product {product_id}')
                    
                except Exception as e:
                    print(f"Error calling Inventory Service: {e}")
                    continue
                
                # Calculate line total
                line_subtotal = unit_price * quantity
                
                # Check for discount rules in database
                cursor.execute(
                    "SELECT discount_percentage FROM pricing_rules WHERE product_id = %s AND min_quantity <= %s ORDER BY min_quantity DESC LIMIT 1",
                    (product_id, quantity)
                )
                discount_rule = cursor.fetchone()
                
                discount_percentage = 0
                line_discount = 0
                
                if discount_rule:
                    discount_percentage = float(discount_rule['discount_percentage'])
                    line_discount = line_subtotal * (discount_percentage / 100)
                
                line_total = line_subtotal - line_discount
                
                subtotal += line_subtotal
                total_discount += line_discount
                
                itemized_breakdown.append({
                    "product_id": product_id,
                    "product_name": product_name,
                    "quantity": quantity,
                    "unit_price": unit_price,
                    "subtotal": round(line_subtotal, 2),
                    "discount_percentage": discount_percentage,
                    "discount_amount": round(line_discount, 2),
                    "line_total": round(line_total, 2)
                })
            
            # Get tax rate from database
            cursor.execute("SELECT tax_rate FROM tax_rates WHERE region = %s", (region,))
            tax_result = cursor.fetchone()
            
            tax_rate = 0
            if tax_result:
                tax_rate = float(tax_result['tax_rate'])
            else:
                cursor.execute("SELECT tax_rate FROM tax_rates WHERE region = 'default'")
                default_tax = cursor.fetchone()
                if default_tax:
                    tax_rate = float(default_tax['tax_rate'])
            
            subtotal_after_discount = subtotal - total_discount
            tax_amount = subtotal_after_discount * (tax_rate / 100)
            grand_total = subtotal_after_discount + tax_amount
            
            cursor.close()
            conn.close()
            
            return jsonify({
                "status": "success",
                "pricing": {
                    "subtotal": round(subtotal, 2),
                    "total_discount": round(total_discount, 2),
                    "subtotal_after_discount": round(subtotal_after_discount, 2),
                    "tax_rate": tax_rate,
                    "tax_amount": round(tax_amount, 2),
                    "grand_total": round(grand_total, 2),
                    "itemized_breakdown": itemized_breakdown
                }
            }), 200
            
        except Error as e:
            cursor.close()
            conn.close()
            return jsonify({
                "status": "error",
                "message": str(e)
            }), 500
            
    except Exception as e:
        return jsonify({
            "status": "error",
            "message": f"An error occurred: {str(e)}"
        }), 500


if __name__ == '__main__':
    print("Starting Pricing Service on port 5003...")
    app.run(host='0.0.0.0', port=5003, debug=True)