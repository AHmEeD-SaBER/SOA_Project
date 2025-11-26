"""
Phase 1 Connectivity Test Script
Tests all 5 Flask services and their basic endpoints
"""
import requests
import time

# Service configurations
SERVICES = {
    'Order Service': 'http://localhost:5001/api/orders/create',
    'Inventory Service': 'http://localhost:5002/api/inventory/check/1',
    'Pricing Service': 'http://localhost:5003/api/pricing/calculate',
    'Customer Service': 'http://localhost:5004/api/customers/1',
    'Notification Service': 'http://localhost:5005/api/notifications/send'
}

def test_service(name, url, method='GET', json_data=None):
    """Test if a service is running and responding"""
    try:
        if method == 'POST':
            response = requests.post(url, json=json_data, timeout=3)
        else:
            response = requests.get(url, timeout=3)
        
        if response.status_code in [200, 404]:  # 404 is ok for test data
            print(f"{name}: RUNNING (Status: {response.status_code})")
            return True
        else:
            print(f"{name}: Unexpected status {response.status_code}")
            return False
    except requests.exceptions.ConnectionError:
        print(f"{name}: NOT RUNNING (Connection refused)")
        return False
    except Exception as e:
        print(f"{name}: ERROR - {str(e)}")
        return False

def main():
    print("=" * 60)
    print("PHASE 1 CONNECTIVITY TEST")
    print("=" * 60)
    print("\nTesting all Flask microservices...\n")
    
    results = []
    
    # Test Order Service (POST)
    results.append(test_service(
        'Order Service', 
        'http://localhost:5001/api/orders/create',
        method='POST',
        json_data={'customer_id': 1, 'products': []}
    ))
    
    # Test Inventory Service (GET)
    results.append(test_service(
        'Inventory Service',
        'http://localhost:5002/api/inventory/check/1'
    ))
    
    # Test Pricing Service (POST)
    results.append(test_service(
        'Pricing Service',
        'http://localhost:5003/api/pricing/calculate',
        method='POST',
        json_data={'products': []}
    ))
    
    # Test Customer Service (GET)
    results.append(test_service(
        'Customer Service',
        'http://localhost:5004/api/customers/1'
    ))
    
    # Test Notification Service (POST)
    results.append(test_service(
        'Notification Service',
        'http://localhost:5005/api/notifications/send',
        method='POST',
        json_data={'order_id': 1}
    ))
    
    print("\n" + "=" * 60)
    print(f"RESULTS: {sum(results)}/5 services are running")
    print("=" * 60)
    
    if sum(results) == 5:
        print("\nSUCCESS! All services are operational.")
    else:
        print("\nSome services are not running.")
        print("Start missing services and run this test again.")

if __name__ == '__main__':
    main()
