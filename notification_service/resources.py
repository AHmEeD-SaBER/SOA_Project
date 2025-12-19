from flask import request, jsonify
from mysql.connector import Error
import requests
from datetime import datetime
from config import CUSTOMER_SERVICE_URL, INVENTORY_SERVICE_URL, ORDER_SERVICE_URL
from db import get_db_connection


def send_notification():
    """Send notification endpoint"""
    try:
        data = request.get_json()
        
        if not data:
            return jsonify({
                "status": "error",
                "message": "No data provided"
            }), 400
            
        order_id = data.get('order_id')
        notification_type = data.get('notification_type', 'order_confirmation')
        
        if not order_id:
            return jsonify({
                "status": "error",
                "message": "order_id is required"
            }), 400
        
        # Step 1: Get order details from Order Service
        try:
            order_response = requests.get(
                f"{ORDER_SERVICE_URL}/api/orders/{order_id}",
                timeout=5
            )
            
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
            
        except requests.exceptions.RequestException as e:
            return jsonify({
                "status": "error",
                "message": f"Error communicating with Order Service: {str(e)}"
            }), 500
        
        # Step 2: Get customer contact information from Customer Service
        try:
            customer_response = requests.get(
                f"{CUSTOMER_SERVICE_URL}/api/customers/{customer_id}",
                timeout=5
            )
            
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
            
        except requests.exceptions.RequestException as e:
            return jsonify({
                "status": "error",
                "message": f"Error communicating with Customer Service: {str(e)}"
            }), 500
        
        # Step 3: Get product details and delivery estimates from Inventory Service
        product_details = []
        estimated_delivery = "3-5 business days"
        
        for product in products:
            product_id = product.get('product_id')
            quantity = product.get('quantity')
            
            try:
                inventory_response = requests.get(
                    f"{INVENTORY_SERVICE_URL}/api/inventory/check/{product_id}",
                    timeout=5
                )
                
                if inventory_response.status_code == 200:
                    inventory_data = inventory_response.json()
                    if inventory_data.get('status') == 'success':
                        product_info = inventory_data.get('product', {})
                        product_details.append({
                            "name": product_info.get('product_name', f'Product {product_id}'),
                            "quantity": quantity,
                            "price": product_info.get('unit_price', 0)
                        })
                        
            except requests.exceptions.RequestException as e:
                print(f"Error getting product {product_id} details: {e}")
                product_details.append({
                    "name": f"Product {product_id}",
                    "quantity": quantity,
                    "price": 0
                })
        
        # Step 4: Generate notification message
        message_lines = [
            f"Dear {customer_name},",
            f"\nYour order #{order_id} has been confirmed!",
            f"\nOrder Details:",
        ]
        
        for item in product_details:
            message_lines.append(f"  - {item['name']} x {item['quantity']} - ${item['price']:.2f}")
        
        message_lines.append(f"\nTotal Amount: ${order.get('total_amount', 0):.2f}")
        message_lines.append(f"Estimated Delivery: {estimated_delivery}")
        message_lines.append(f"\nThank you for shopping with us!")
        
        notification_message = "\n".join(message_lines)
        
        # Step 5: Simulate sending email/SMS (console output)
        print("\n" + "="*60)
        print("EMAIL NOTIFICATION SENT")
        print("="*60)
        print(f"TO: {customer_email}")
        print(f"PHONE: {customer_phone}")
        print(f"Subject: Order #{order_id} Confirmed - {notification_type.replace('_', ' ').title()}")
        print("-"*60)
        print(notification_message)
        print("="*60 + "\n")
        
        # Step 6: Log notification to database
        conn = get_db_connection()
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
                cursor.close()
                conn.close()
                
            except Error as e:
                print(f"Error logging notification: {e}")
                notification_id = None
        else:
            notification_id = None
        
        # Step 7: Return success confirmation
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
        return jsonify({
            "status": "error",
            "message": f"An error occurred: {str(e)}"
        }), 500
