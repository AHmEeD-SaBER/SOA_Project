from flask import request, jsonify
from mysql.connector import Error
from db import get_db_connection


def create_order():
    """Create order endpoint"""
    try:
        data = request.get_json()
        
        if not data:
            return jsonify({
                "status": "error",
                "message": "No data provided"
            }), 400
            
        customer_id = data.get('customer_id')
        products = data.get('products')
        total_amount = data.get('total_amount')
        
        if not customer_id:
            return jsonify({
                "status": "error",
                "message": "customer_id is required"
            }), 400
            
        if not products or not isinstance(products, list) or len(products) == 0:
            return jsonify({
                "status": "error",
                "message": "products list is required and must not be empty"
            }), 400
            
        for product in products:
            if not isinstance(product, dict):
                return jsonify({
                    "status": "error",
                    "message": "Each product must be an object"
                }), 400
            if 'product_id' not in product or 'quantity' not in product:
                return jsonify({
                    "status": "error",
                    "message": "Each product must have product_id and quantity"
                }), 400
            if not isinstance(product['quantity'], (int, float)) or product['quantity'] <= 0:
                return jsonify({
                    "status": "error",
                    "message": "Product quantity must be a positive number"
                }), 400
        

        conn = get_db_connection()
        if not conn:
            return jsonify({
                "status": "error",
                "message": "Database connection failed"
            }), 500
        
        cursor = conn.cursor(dictionary=True)
        
        try:
            cursor.execute(
                "INSERT INTO orders (customer_id, total_amount, status) VALUES (%s, %s, %s)",
                (customer_id, total_amount or 0, 'confirmed')
            )
            order_id = cursor.lastrowid
            
            for product in products:
                cursor.execute(
                    "SELECT unit_price FROM inventory WHERE product_id = %s",
                    (product['product_id'],)
                )
                result = cursor.fetchone()
                unit_price = result['unit_price'] if result else 0
                
                cursor.execute(
                    "INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES (%s, %s, %s, %s)",
                    (order_id, product['product_id'], product['quantity'], unit_price)
                )
            
            conn.commit()
            
            cursor.execute("SELECT created_at FROM orders WHERE order_id = %s", (order_id,))
            order_timestamp = cursor.fetchone()['created_at'].isoformat()
            
            cursor.close()
            conn.close()
            
            order = {
                "order_id": order_id,
                "customer_id": customer_id,
                "products": products,
                "total_amount": total_amount,
                "status": "confirmed",
                "created_at": order_timestamp
            }
            
            return jsonify({
                "status": "success",
                "message": "Order created successfully",
                "order": order
            }), 201
            
        except Error as e:
            conn.rollback()
            cursor.close()
            conn.close()
            return jsonify({
                "status": "error",
                "message": f"Database error: {str(e)}"
            }), 500
        
    except Exception as e:
        return jsonify({
            "status": "error",
            "message": f"An error occurred: {str(e)}"
        }), 500


def get_order(order_id):
    """Get order by ID endpoint - FIXED with JOIN"""
    try:
        conn = get_db_connection()
        if not conn:
            return jsonify({
                "status": "error",
                "message": "Database connection failed"
            }), 500
        
        cursor = conn.cursor(dictionary=True)
        
        cursor.execute(
            "SELECT * FROM orders WHERE order_id = %s",
            (order_id,)
        )
        order = cursor.fetchone()
        
        if not order:
            cursor.close()
            conn.close()
            return jsonify({
                "status": "not_found",
                "message": f"Order {order_id} not found"
            }), 404
        
        # FIXED: Use JOIN to get product name from inventory table
        cursor.execute(
            """
            SELECT 
                oi.product_id, 
                oi.quantity, 
                oi.unit_price,
                i.product_name as name
            FROM order_items oi
            LEFT JOIN inventory i ON oi.product_id = i.product_id
            WHERE oi.order_id = %s
            """,
            (order_id,)
        )
        items = cursor.fetchall()
        
        cursor.close()
        conn.close()
        
        products = [
            {
                "product_id": item['product_id'], 
                "quantity": item['quantity'], 
                "unit_price": float(item['unit_price']), 
                "name": item['name'] if item['name'] else f"Product #{item['product_id']}"
            }
            for item in items
        ]
        
        order_response = {
            "order_id": order['order_id'],
            "customer_id": order['customer_id'],
            "products": products,
            "total_amount": float(order['total_amount']),
            "status": order['status'],
            "created_at": order['created_at'].isoformat()
        }
        
        return jsonify({
            "status": "success",
            "order": order_response
        }), 200
            
    except Exception as e:
        return jsonify({
            "status": "error",
            "message": f"An error occurred: {str(e)}"
        }), 500


def get_orders_by_customer():
    """Get orders by customer ID endpoint"""
    try:
        customer_id = request.args.get('customer_id')
        
        if not customer_id:
            return jsonify({
                "status": "error",
                "message": "customer_id query parameter is required"
            }), 400
        
        conn = get_db_connection()
        if not conn:
            return jsonify({
                "status": "error",
                "message": "Database connection failed"
            }), 500
        
        cursor = conn.cursor(dictionary=True)
        
        # Get all orders for customer
        cursor.execute(
            "SELECT * FROM orders WHERE customer_id = %s ORDER BY created_at DESC",
            (customer_id,)
        )
        orders = cursor.fetchall()
        
        customer_orders = []
        
        for order in orders:
            cursor.execute(
                "SELECT product_id, quantity FROM order_items WHERE order_id = %s",
                (order['order_id'],)
            )
            items = cursor.fetchall()
            
            products = [
                {"product_id": item['product_id'], "quantity": item['quantity']}
                for item in items
            ]
            
            customer_orders.append({
                "order_id": order['order_id'],
                "customer_id": order['customer_id'],
                "products": products,
                "total_amount": float(order['total_amount']),
                "status": order['status'],
                "created_at": order['created_at'].isoformat()
            })
        
        cursor.close()
        conn.close()
        
        return jsonify({
            "status": "success",
            "customer_id": customer_id,
            "orders": customer_orders,
            "count": len(customer_orders)
        }), 200
        
    except Exception as e:
        return jsonify({
            "status": "error",
            "message": f"An error occurred: {str(e)}"
        }), 500