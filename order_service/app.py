from flask import Flask
from flask_cors import CORS
from config import SERVICE_PORT, SERVICE_HOST, DEBUG
from resources import (
    create_order,
    get_order,
    get_orders_by_customer
)

app = Flask(__name__)
CORS(app)


# Route definitions
@app.route('/api/orders/create', methods=['POST'])
def order_create():
    return create_order()


@app.route('/api/orders/<int:order_id>', methods=['GET'])
def order(order_id):
    return get_order(order_id)


@app.route('/api/orders', methods=['GET'])
def orders():
    return get_orders_by_customer()


if __name__ == '__main__':
    print(f"Starting Order Service on port {SERVICE_PORT}...")
    app.run(host=SERVICE_HOST, port=SERVICE_PORT, debug=DEBUG)