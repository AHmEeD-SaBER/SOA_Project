from flask import Flask
from flask_cors import CORS
from config import SERVICE_PORT, SERVICE_HOST, DEBUG
from resources import (
    get_all_products,
    check_inventory,
    update_inventory
)

app = Flask(__name__)
CORS(app)


# Route definitions
@app.route('/api/inventory/products', methods=['GET'])
def products():
    return get_all_products()


@app.route('/api/inventory/check/<int:product_id>', methods=['GET'])
def inventory_check(product_id):
    return check_inventory(product_id)


@app.route('/api/inventory/update', methods=['PUT'])
def inventory_update():
    return update_inventory()


if __name__ == '__main__':
    print(f"Starting Inventory Service on port {SERVICE_PORT}...")
    app.run(host=SERVICE_HOST, port=SERVICE_PORT, debug=DEBUG)