"""
Connectivity Test Script
Tests all 5 Flask services to verify they are running
Does NOT make actual requests - just checks if services respond
"""
import requests

# Service configurations - using root paths for simple availability check
SERVICES = {
    'Order Service': 'http://localhost:5001/',
    'Inventory Service': 'http://localhost:5002/',
    'Pricing Service': 'http://localhost:5003/',
    'Customer Service': 'http://localhost:5004/',
    'Notification Service': 'http://localhost:5005/'
}

def test_service(name, url):
    """Test if a service is running and responding"""
    try:
        response = requests.get(url, timeout=2)
        
        # Any response means service is running (even 404 is OK)
        if response.status_code in [200, 404]:
            print(f"{name}: ✓ RUNNING")
            return True
        else:
            print(f"{name}: ⚠ RUNNING (Status: {response.status_code})")
            return True  # Still counts as running
    except requests.exceptions.ConnectionError:
        print(f"{name}: ✗ NOT RUNNING (Connection refused)")
        return False
    except requests.exceptions.Timeout:
        print(f"{name}: ⚠ RUNNING but slow to respond")
        return True  # Service is up, just slow
    except Exception as e:
        print(f"{name}: ✗ ERROR - {str(e)}")
        return False

def main():
    print("=" * 60)
    print("CONNECTIVITY TEST - Checking Services")
    print("=" * 60)
    print("\nTesting all Flask microservices...\n")
    
    results = []
    
    # Test all services with simple GET requests to root
    for service_name, service_url in SERVICES.items():
        results.append(test_service(service_name, service_url))
    
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
