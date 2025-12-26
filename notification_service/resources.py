from flask import request, jsonify
from mysql.connector import Error
import requests
from datetime import datetime
from config import CUSTOMER_SERVICE_URL, INVENTORY_SERVICE_URL, ORDER_SERVICE_URL
from db import get_db_connection


def send_notification():
    """Send notification endpoint"""
    try:
        print("=== NOTIFICATION ENDPOINT CALLED ===")
        data = request.get_json()
        print("Received data:", data)
        
        if not data:
            return jsonify({
                "status": "error",
                "message": "No data provided"
            }), 400
            
        order_id = data.get('order_id')
        notification_type = data.get('notification_type', 'order_confirmation')
        print(f"order_id: {order_id}, type: {notification_type}")
        
        if not order_id:
            return jsonify({
                "status": "error",
                "message": "order_id is required"
            }), 400
        
        # Step 1: Get order details
        print("Fetching order...")
        order_response = requests.get(
            f"{ORDER_SERVICE_URL}/api/orders/{order_id}",
            timeout=5
        )
        print(f"Order status: {order_response.status_code}")
        
        if order_response.status_code != 200:
            return jsonify({
                "status": "error",
                "message": f"Order {order_id} not found"
            }), 404
            
        order_data = order_response.json()
        
        if order_data.get('status') != 'success':
            return jsonify({
                "status": "error",
                "message": "Failed to retrieve order details"
            }), 500
            
        order = order_data.get('order', {})
        customer_id = order.get('customer_id')
        products = order.get('products', [])
        
        if not customer_id:
            return jsonify({
                "status": "error",
                "message": "Missing customer_id in order"
            }), 500
        
        print(f"Customer ID: {customer_id}")
        print(f"Products: {products}")
        
        # Step 2: Get customer details
        print("Fetching customer...")
        customer_response = requests.get(
            f"{CUSTOMER_SERVICE_URL}/api/customers/{customer_id}",
            timeout=5
        )
        print(f"Customer status: {customer_response.status_code}")
        
        if customer_response.status_code != 200:
            return jsonify({
                "status": "error",
                "message": f"Customer {customer_id} not found"
            }), 404
            
        customer_data = customer_response.json()
        
        if customer_data.get('status') != 'success':
            return jsonify({
                "status": "error",
                "message": "Failed to retrieve customer details"
            }), 500
            
        customer = customer_data.get('customer', {})
        customer_email = customer.get('email')
        customer_phone = customer.get('phone')
        customer_name = customer.get('name')
        
        # Step 3: Get product details from Inventory
        product_details = []
        estimated_delivery = "3-5 business days"

        for product in products:
            product_id = product.get('product_id')
            quantity = product.get('quantity')
            
            try:
                inv_response = requests.get(
                    f"{INVENTORY_SERVICE_URL}/api/inventory/check/{product_id}",
                    timeout=5
                )
                
                if inv_response.status_code == 200:
                    inv_data = inv_response.json()
                    if inv_data.get('status') == 'success':
                        prod_info = inv_data.get('product', {})
                        price_str = prod_info.get('unit_price', '0')
                        price_float = float(price_str) if price_str else 0.0
                        product_details.append({
                            "name": prod_info.get('product_name', f'Product {product_id}'),
                            "quantity": quantity,
                            "price": price_float 
                        })
            except Exception as e:
                print(f"Inventory error for {product_id}: {e}")
                product_details.append({
                    "name": f"Product {product_id}",
                    "quantity": quantity,
                    "price": 0.0  # float
                })

        # Step 4: Generate notification message
        message_lines = [
            f"Dear {customer_name},",
            f"\nYour order #{order_id} has been confirmed!",
            f"\nOrder Details:",
        ]

        for item in product_details:
            message_lines.append(f"  - {item['name']} x {item['quantity']} - ${item['price']:.2f}")

        total_amount = order.get('total_amount', 0)
        total_float = float(total_amount) if total_amount else 0.0
        message_lines.append(f"\nTotal Amount: ${total_float:.2f}")

        message_lines.append(f"Estimated Delivery: {estimated_delivery}")
        message_lines.append(f"\nThank you for shopping with us!")

        notification_message = "\n".join(message_lines)
        
        # Step 5: Simulate sending
        print("\n" + "="*60)
        print("EMAIL NOTIFICATION SENT")
        print("="*60)
        print(f"TO: {customer_email}")
        print(f"PHONE: {customer_phone}")
        print(f"Subject: Order #{order_id} Confirmed")
        print("-"*60)
        print(notification_message)
        print("="*60 + "\n")
        
        # Step 6: Log to DB
        conn = get_db_connection()
        notification_id = None
        if conn:
            try:
                cursor = conn.cursor()
                cursor.execute(
                    """INSERT INTO notification_log 
                       (order_id, customer_id, notification_type, message, sent_at) 
                       VALUES (%s, %s, %s, %s, %s)""",
                    (order_id, customer_id, notification_type, notification_message, datetime.now())
                )
                conn.commit()
                notification_id = cursor.lastrowid
            except Error as e:
                print(f"DB log error: {e}")
            finally:
                conn.close()
        
        return jsonify({
            "status": "success",
            "message": "Notification sent successfully",
            "notification_id": notification_id,
            "order_id": order_id,
            "customer_id": customer_id,
            "customer_email": customer_email,
            "customer_phone": customer_phone,
            "notification_type": notification_type,
            "sent_at": datetime.now().isoformat()
        }), 200
        
    except Exception as e:
        print(f"Unexpected error: {str(e)}")
        return jsonify({
            "status": "error",
            "message": f"An error occurred: {str(e)}"
        }), 500


def get_customer_notifications(customer_id):
    """Fetch all notifications for a given customer"""
    conn = get_db_connection()
    if not conn:
        return jsonify({"status": "error", "message": "Database connection failed"}), 500

    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute(
            """
            SELECT 
                notification_id,
                order_id,
                notification_type,
                message,
                sent_at
            FROM notification_log
            WHERE customer_id = %s
            ORDER BY sent_at DESC
            """,
            (customer_id,)
        )
        notifications = cursor.fetchall()
        cursor.close()
        conn.close()

        return jsonify({
            "status": "success",
            "customer_id": customer_id,
            "notifications": notifications,
            "count": len(notifications)
        }), 200

    except Error as e:
        print(f"Database error: {e}")
        return jsonify({
            "status": "error",
            "message": f"Failed to fetch notifications: {str(e)}"
        }), 500