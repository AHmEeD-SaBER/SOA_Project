from flask import Flask
from flask_cors import CORS
from config import SERVICE_PORT, SERVICE_HOST, DEBUG
from resources import calculate_pricing

app = Flask(__name__)
CORS(app)


# Route definitions
@app.route('/api/pricing/calculate', methods=['POST'])
def pricing():
    return calculate_pricing()


if __name__ == '__main__':
    print(f"Starting Pricing Service on port {SERVICE_PORT}...")
    app.run(host=SERVICE_HOST, port=SERVICE_PORT, debug=DEBUG)