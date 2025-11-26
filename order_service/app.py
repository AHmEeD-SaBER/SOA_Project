from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

# Create order endpoint (placeholder)
@app.route('/api/orders/create', methods=['POST'])
def create_order():
    return jsonify({
        "message": "Order Service is ready",
        "endpoint": "/api/orders/create",
        "status": "placeholder"
    }), 200

# Get order details endpoint (placeholder)
@app.route('/api/orders/<order_id>', methods=['GET'])
def get_order(order_id):
    return jsonify({
        "message": f"Get order endpoint ready",
        "order_id": order_id,
        "status": "placeholder"
    }), 200

# Get orders by customer (placeholder)
@app.route('/api/orders', methods=['GET'])
def get_orders_by_customer():
    customer_id = request.args.get('customer_id')
    return jsonify({
        "message": "Get orders by customer endpoint ready",
        "customer_id": customer_id,
        "status": "placeholder"
    }), 200

if __name__ == '__main__':
    print("Starting Order Service on port 5001...")
    app.run(host='0.0.0.0', port=5001, debug=True)