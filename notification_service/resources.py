from flask import request, jsonify
from mysql.connector import Error
import requests
from datetime import datetime
from config import CUSTOMER_SERVICE_URL, INVENTORY_SERVICE_URL, ORDER_SERVICE_URL
from db import get_db_connection


def send_notification():
    """Send order confirmation notification"""
    try:
        data = request.get_json()
        
        if not data:
            return jsonify({
                "status": "error",
                "message": "No data provided"
            }), 400
        
        order_id = data.get('order_id')
        
        if not order_id:
            return jsonify({
                "status": "error",
                "message": "order_id is required"
            }), 400
        
        print(f"=== Processing notification for order {order_id} ===")
        
        # Step 1: Get order details from Order Service
        print("Step 1: Fetching order details...")
        try:
            order_response = requests.get(
                f"{ORDER_SERVICE_URL}/api/orders/{order_id}",
                timeout=5
            )
            
            if order_response.status_code == 404:
                return jsonify({
                    "status": "error",
                    "message": f"Order {order_id} not found"
                }), 404
            
            if order_response.status_code != 200:
                return jsonify({
                    "status": "error",
                    "message": "Failed to retrieve order details"
                }), 500
            
            order_data = order_response.json()
            
            if order_data.get('status') != 'success':
                return jsonify({
                    "status": "error",
                    "message": "Order service returned error"
                }), 500
            
            order = order_data['order']
            print(f"Order retrieved: Customer {order['customer_id']}, Total ${order['total_amount']}")
            
        except requests.exceptions.RequestException as e:
            print(f"Error calling Order Service: {str(e)}")
            return jsonify({
                "status": "error",
                "message": f"Failed to connect to Order Service: {str(e)}"
            }), 500
        
        # Step 2: Get customer details from Customer Service
        print("Step 2: Fetching customer details...")
        customer_id = order['customer_id']
        
        try:
            customer_response = requests.get(
                f"{CUSTOMER_SERVICE_URL}/api/customers/{customer_id}",
                timeout=5
            )
            
            if customer_response.status_code == 404:
                return jsonify({
                    "status": "error",
                    "message": f"Customer {customer_id} not found"
                }), 404
            
            if customer_response.status_code != 200:
                return jsonify({
                    "status": "error",
                    "message": "Failed to retrieve customer details"
                }), 500
            
            customer_data = customer_response.json()
            
            if customer_data.get('status') != 'success':
                return jsonify({
                    "status": "error",
                    "message": "Customer service returned error"
                }), 500
            
            customer = customer_data['customer']
            print(f"Customer retrieved: {customer.get('name', 'Unknown')} - {customer.get('email', 'No email')}")
            
        except requests.exceptions.RequestException as e:
            print(f"Error calling Customer Service: {str(e)}")
            return jsonify({
                "status": "error",
                "message": f"Failed to connect to Customer Service: {str(e)}"
            }), 500
        
        # Step 3: Send notification
        print("Step 3: Sending notification...")
        
        notification_message = f"""
Order Confirmation - Order #{order_id}

Dear {customer.get('name', 'Valued Customer')},

Your order has been confirmed!

Order Details:
"""
        
        for product in order['products']:
            product_name = product.get('name', f"Product #{product['product_id']}")
            notification_message += f"- {product_name}: {product['quantity']} x ${product['unit_price']:.2f}\n"
        
        notification_message += f"\nTotal Amount: ${order['total_amount']:.2f}\n"
        notification_message += f"Status: {order['status']}\n"
        notification_message += f"\nThank you for your order!"
        
        print("=" * 50)
        print("NOTIFICATION:")
        print(notification_message)
        print("=" * 50)
        
        # Here you would send actual email/SMS
        # send_email(customer['email'], notification_message)
        
        return jsonify({
            "status": "success",
            "message": "Notification sent successfully",
            "notification": {
                "order_id": order_id,
                "customer_id": customer_id,
                "customer_email": customer.get('email', 'N/A'),
                "sent_at": datetime.now().isoformat()
            }
        }), 200
        
    except Exception as e:
        print(f"Notification Service Error: {str(e)}")
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