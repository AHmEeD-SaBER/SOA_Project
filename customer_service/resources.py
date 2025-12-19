from flask import request, jsonify
from mysql.connector import Error
import requests
from config import ORDER_SERVICE_URL
from db import get_db_connection


def get_all_customers():
    """Get all customers endpoint"""
    conn = get_db_connection()
    if conn:
        try:
            cursor = conn.cursor(dictionary=True)
            cursor.execute("SELECT customer_id, name, email, loyalty_points FROM customers ORDER BY name")
            customers = cursor.fetchall()
            cursor.close()
            conn.close()
            
            return jsonify({
                "status": "success",
                "customers": customers,
                "count": len(customers)
            }), 200
        except Error as e:
            if conn:
                conn.close()
            return jsonify({
                "status": "error",
                "message": str(e)
            }), 500
    return jsonify({
        "status": "error",
        "message": "Database connection failed"
    }), 500


def get_customer(customer_id):
    """Get customer profile endpoint"""
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


def get_customer_orders(customer_id):
    """Get customer order history endpoint"""
    try:
        # First verify customer exists
        conn = get_db_connection()
        if not conn:
            return jsonify({
                "status": "error",
                "message": "Database connection failed"
            }), 500
            
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT * FROM customers WHERE customer_id = %s", (customer_id,))
        customer = cursor.fetchone()
        cursor.close()
        conn.close()
        
        if not customer:
            return jsonify({
                "status": "not_found",
                "message": f"Customer {customer_id} not found"
            }), 404
        
        try:
            response = requests.get(f"{ORDER_SERVICE_URL}?customer_id={customer_id}", timeout=5)
            if response.status_code == 200:
                order_data = response.json()
                return jsonify({
                    "status": "success",
                    "customer": {
                        "customer_id": customer['customer_id'],
                        "name": customer['name'],
                        "email": customer['email']
                    },
                    "orders": order_data.get('orders', []),
                    "order_count": order_data.get('count', 0)
                }), 200
            else:
                return jsonify({
                    "status": "error",
                    "message": "Failed to retrieve orders from Order Service"
                }), 500
                
        except requests.exceptions.RequestException as e:
            return jsonify({
                "status": "error",
                "message": f"Error communicating with Order Service: {str(e)}"
            }), 500
            
    except Exception as e:
        return jsonify({
            "status": "error",
            "message": f"An error occurred: {str(e)}"
        }), 500


def update_loyalty(customer_id):
    """Update customer loyalty points endpoint"""
    try:
        data = request.get_json()
        
        if not data:
            return jsonify({
                "status": "error",
                "message": "No data provided"
            }), 400
            
        points = data.get('points')
        operation = data.get('operation', 'add') 
        
        if points is None:
            return jsonify({
                "status": "error",
                "message": "points field is required"
            }), 400
            
        conn = get_db_connection()
        if not conn:
            return jsonify({
                "status": "error",
                "message": "Database connection failed"
            }), 500
            
        cursor = conn.cursor(dictionary=True)
        
        try:
            # Get current loyalty points
            cursor.execute("SELECT loyalty_points FROM customers WHERE customer_id = %s", (customer_id,))
            result = cursor.fetchone()
            
            if not result:
                cursor.close()
                conn.close()
                return jsonify({
                    "status": "not_found",
                    "message": f"Customer {customer_id} not found"
                }), 404
            
            current_points = result['loyalty_points']
            
            # Calculate new points
            if operation == 'add':
                new_points = current_points + points
            elif operation == 'set':
                new_points = points
            else:
                cursor.close()
                conn.close()
                return jsonify({
                    "status": "error",
                    "message": "Invalid operation. Use 'add' or 'set'"
                }), 400
            
            # Ensure points don't go negative
            if new_points < 0:
                new_points = 0
            
            # Update loyalty points
            cursor.execute(
                "UPDATE customers SET loyalty_points = %s WHERE customer_id = %s",
                (new_points, customer_id)
            )
            conn.commit()
            
            cursor.close()
            conn.close()
            
            return jsonify({
                "status": "success",
                "message": "Loyalty points updated successfully",
                "customer_id": customer_id,
                "previous_points": current_points,
                "new_points": new_points,
                "operation": operation
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
