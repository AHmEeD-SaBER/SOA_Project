from flask import Flask
from flask_cors import CORS
from config import SERVICE_PORT, SERVICE_HOST, DEBUG
from resources import (
    get_all_customers,
    get_customer,
    get_customer_orders,
    update_loyalty
)

app = Flask(__name__)
CORS(app)


# Route definitions
@app.route('/api/customers', methods=['GET'])
def all_customers():
    return get_all_customers()


@app.route('/api/customers/<int:customer_id>', methods=['GET'])
def customer(customer_id):
    return get_customer(customer_id)


@app.route('/api/customers/<int:customer_id>/orders', methods=['GET'])
def customer_orders(customer_id):
    return get_customer_orders(customer_id)


@app.route('/api/customers/<int:customer_id>/loyalty', methods=['PUT'])
def loyalty(customer_id):
    return update_loyalty(customer_id)


if __name__ == '__main__':
    print(f"Starting Customer Service on port {SERVICE_PORT}...")
    app.run(host=SERVICE_HOST, port=SERVICE_PORT, debug=DEBUG)