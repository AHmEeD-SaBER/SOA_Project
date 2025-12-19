from flask import request, jsonify
from mysql.connector import Error
from db import get_db_connection


def get_all_products():
    """Get all products endpoint"""
    conn = get_db_connection()
    if conn:
        try:
            cursor = conn.cursor(dictionary=True)
            cursor.execute("SELECT * FROM inventory WHERE quantity_available > 0")
            products = cursor.fetchall()
            cursor.close()
            conn.close()
            
            return jsonify({
                "status": "success",
                "products": products,
                "count": len(products)
            }), 200
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


def check_inventory(product_id):
    """Check inventory endpoint"""
    conn = get_db_connection()
    if conn:
        try:
            cursor = conn.cursor(dictionary=True)
            cursor.execute("SELECT * FROM inventory WHERE product_id = %s", (product_id,))
            product = cursor.fetchone()
            cursor.close()
            conn.close()
            
            if product:
                in_stock = product['quantity_available'] > 0
                return jsonify({
                    "status": "success",
                    "product": product,
                    "in_stock": in_stock,
                    "available_quantity": product['quantity_available']
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


def update_inventory():
    """Update inventory endpoint"""
    try:
        data = request.get_json()
        
        if not data:
            return jsonify({
                "status": "error",
                "message": "No data provided"
            }), 400
            
        products = data.get('products')
        
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
        updated_products = []
        
        try:
            for product in products:
                product_id = product.get('product_id')
                quantity = product.get('quantity')
                
                if not product_id or quantity is None:
                    continue
                    
                # Check current stock
                cursor.execute("SELECT quantity_available FROM inventory WHERE product_id = %s", (product_id,))
                result = cursor.fetchone()
                
                if result:
                    current_quantity = result['quantity_available']
                    new_quantity = current_quantity - quantity
                    
                    if new_quantity < 0:
                        conn.rollback()
                        cursor.close()
                        conn.close()
                        return jsonify({
                            "status": "error",
                            "message": f"Insufficient stock for product {product_id}. Available: {current_quantity}, Requested: {quantity}"
                        }), 400
                    
                    # Update inventory
                    cursor.execute(
                        "UPDATE inventory SET quantity_available = %s, last_updated = CURRENT_TIMESTAMP WHERE product_id = %s",
                        (new_quantity, product_id)
                    )
                    updated_products.append({
                        "product_id": product_id,
                        "previous_quantity": current_quantity,
                        "new_quantity": new_quantity,
                        "deducted": quantity
                    })
            
            conn.commit()
            cursor.close()
            conn.close()
            
            return jsonify({
                "status": "success",
                "message": "Inventory updated successfully",
                "updated_products": updated_products
            }), 200
            
        except Error as e:
            conn.rollback()
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
