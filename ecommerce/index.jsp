<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" buffer="64kb" autoFlush="true" %>
<%@ page import="java.net.http.*" %>
<%@ page import="java.net.URI" %>
<%@ page import="org.json.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>E-Commerce Store - Product Catalog</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
            padding: 30px;
        }
        header {
            text-align: center;
            margin-bottom: 40px;
            padding-bottom: 20px;
            border-bottom: 3px solid #667eea;
        }
        h1 { color: #333; font-size: 2.5em; margin-bottom: 10px; }
        .subtitle { color: #666; font-size: 1.1em; }
        .nav-links {
            margin-top: 15px;
            display: flex;
            justify-content: center;
            gap: 20px;
        }
        .nav-links button {
            color: #667eea;
            background: white;
            padding: 10px 20px;
            border: 2px solid #667eea;
            border-radius: 5px;
            font-weight: bold;
            cursor: pointer;
            font-size: 1em;
            transition: all 0.3s ease;
        }
        .nav-links button:hover {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        .customer-selector {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 10px;
            margin-bottom: 30px;
            display: flex;
            align-items: center;
            gap: 15px;
        }
        .customer-selector label { font-weight: bold; color: #333; }
        .customer-selector select {
            flex: 1;
            padding: 10px 15px;
            border: 2px solid #667eea;
            border-radius: 5px;
            font-size: 1em;
            cursor: pointer;
        }
        .products-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
            gap: 25px;
            margin-bottom: 30px;
        }
        .product-card {
            background: white;
            border: 2px solid #e0e0e0;
            border-radius: 10px;
            padding: 20px;
            transition: all 0.3s ease;
        }
        .product-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 5px 20px rgba(102, 126, 234, 0.3);
            border-color: #667eea;
        }
        .product-card h3 { color: #333; margin-bottom: 10px; font-size: 1.2em; min-height: 50px; }
        .price { font-size: 1.5em; color: #667eea; font-weight: bold; margin: 10px 0; }
        .stock { color: #28a745; font-size: 0.9em; margin-bottom: 15px; }
        .stock.low { color: #ffc107; }
        .quantity-control {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 10px;
        }
        .quantity-control label { font-weight: bold; color: #333; }
        .quantity-control input {
            width: 70px;
            padding: 8px;
            border: 2px solid #ddd;
            border-radius: 5px;
            text-align: center;
            font-size: 1em;
        }
        .product-checkbox { margin-bottom: 10px; }
        .product-checkbox input[type="checkbox"] {
            width: 18px;
            height: 18px;
            margin-right: 8px;
            cursor: pointer;
        }
        .product-checkbox label { font-weight: bold; color: #333; cursor: pointer; }
        .cart-section {
            background: #f8f9fa;
            padding: 25px;
            border-radius: 10px;
            margin-top: 30px;
        }
        .cart-section h2 { color: #333; margin-bottom: 20px; font-size: 1.8em; }
        .checkout-btn {
            width: 100%;
            background: linear-gradient(135deg, #28a745 0%, #20c997 100%);
            color: white;
            border: none;
            padding: 15px;
            border-radius: 5px;
            cursor: pointer;
            font-size: 1.2em;
            font-weight: bold;
            transition: all 0.3s ease;
        }
        .checkout-btn:hover {
            transform: scale(1.02);
            box-shadow: 0 5px 15px rgba(40, 167, 69, 0.4);
        }
        .checkout-btn:disabled { background: #ccc; cursor: not-allowed; transform: none; }
        .error-message {
            background: #f8d7da;
            color: #721c24;
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 20px;
            border: 1px solid #f5c6cb;
        }
        .loading { text-align: center; padding: 40px; font-size: 1.2em; color: #667eea; }
        #selectedInfo { color: #666; margin-bottom: 20px; }
    </style>
</head>

<body>
    <div class="container">
        <header>
            <h1>🛒 E-Commerce Store</h1>
            <p class="subtitle">Microservices-Based Order Management System</p>
            <div class="nav-links">
                <button type="button" onclick="goToProfile()">👤 My Profile</button>
                <button type="button" onclick="goToOrdersHistory()">📋 Orders History</button>
            </div>
        </header>

        <% 
            // Display error message from servlet if any
            String error = (String) request.getAttribute("error");
            if (error != null) { 
        %>
            <div class="error-message">
                <strong>Error:</strong> <%= error %>
            </div>
        <% } %>

        <%
            // Call Customer Service to get all customers
            String customersJson = null;
            String customerError = null;
            
            try {
                HttpClient customerClient = HttpClient.newHttpClient();
                HttpRequest customerRequest = HttpRequest.newBuilder()
                    .uri(URI.create("http://localhost:5004/api/customers"))
                    .GET()
                    .build();
                
                HttpResponse<String> customerResponse = customerClient.send(customerRequest, HttpResponse.BodyHandlers.ofString());

                if (customerResponse.statusCode() == 200) {
                    customersJson = customerResponse.body();
                } else {
                    customerError = "Failed to load customers. Status: " + customerResponse.statusCode();
                }
            } catch (Exception e) {
                customerError = "Error connecting to Customer Service: " + e.getMessage();
            }
        %>

        <%
            // Call Inventory Service to get products (quantity > 0)
            String errorMessage = null;
            String productsJson = null;
            
            try {
                HttpClient client = HttpClient.newHttpClient();
                HttpRequest inventoryRequest = HttpRequest.newBuilder()
                    .uri(URI.create("http://localhost:5002/api/inventory/products"))
                    .GET()
                    .build();
                
                HttpResponse<String> inventoryResponse = client.send(inventoryRequest, HttpResponse.BodyHandlers.ofString());

                if (inventoryResponse.statusCode() == 200) {
                    productsJson = inventoryResponse.body();
                } else {
                    errorMessage = "Failed to load products. Status: " + inventoryResponse.statusCode();
                }
            } catch (Exception e) {
                errorMessage = "Error connecting to Inventory Service: " + e.getMessage();
            }
        %>

        <% if (errorMessage != null) { %>
            <div class="error-message">
                <strong>Error:</strong> <%= errorMessage %>
                <br><small>Make sure the Inventory Service is running on port 5002</small>
            </div>
        <% } %>

        <!-- Main Form - Submits to CheckoutServlet -->
        <form id="orderForm" action="CheckoutServlet" method="POST">
            <div class="customer-selector">
                <label for="customerId">Select Customer:</label>
                <select id="customerId" name="customerId" required>
                    <option value="">-- Please select a customer --</option>
                </select>
                <% if (customerError != null) { %>
                    <small style="color: red;"><%= customerError %></small>
                <% } %>
            </div>

            <div id="productsContainer">
                <div class="loading">Loading products...</div>
            </div>

            <div class="cart-section">
                <h2>🛍️ Make Order</h2>
                <p id="selectedInfo">Select products above and click "Proceed to Checkout"</p>
                <button type="submit" class="checkout-btn" id="checkoutBtn" disabled>
                    Proceed to Checkout →
                </button>
            </div>
        </form>
    </div>

    <!-- Hidden forms for navigation to ProfileServlet and OrdersHistoryServlet -->
    <form id="profileForm" action="ProfileServlet" method="GET">
        <input type="hidden" id="profileCustomerId" name="customerId" value="">
    </form>

    <form id="ordersHistoryForm" action="OrdersHistoryServlet" method="GET">
        <input type="hidden" id="ordersCustomerId" name="customerId" value="">
    </form>

    <script>
        let products = [];
        let customers = [];

        // Load customers from server response
        <% if (customersJson != null) { %>
            try {
                const customerData = <%= customersJson %>;
                if (customerData.status === 'success') {
                    customers = customerData.customers;
                    populateCustomers();
                }
            } catch (e) {
                console.error('Error parsing customers:', e);
            }
        <% } %>

        // Load products from server response
        <% if (productsJson != null) { %>
            try {
                const response = <%= productsJson %>;
                if (response.status === 'success') {
                    products = response.products;
                }
            } catch (e) {
                console.error('Error parsing products:', e);
            }
        <% } %>

        function populateCustomers() {
            const customerSelect = document.getElementById('customerId');
            customers.forEach(customer => {
                const option = document.createElement('option');
                option.value = customer.customer_id;
                option.textContent = customer.name + ' (Loyalty Points: ' + customer.loyalty_points + ')';
                customerSelect.appendChild(option);
            });
        }

        function displayProducts() {
            const container = document.getElementById('productsContainer');
            if (!container) return;

            if (products.length === 0) {
                container.innerHTML = '<div class="loading">No products available</div>';
                return;
            }

            let html = '<div class="products-grid">';
            products.forEach(product => {
                const stockClass = product.quantity_available < 50 ? 'low' : '';
                const disabled = product.quantity_available === 0 ? 'disabled' : '';

                html += '<div class="product-card">';
                html += '  <h3>' + product.product_name + '</h3>';
                html += '  <div class="price">$' + parseFloat(product.unit_price).toFixed(2) + '</div>';
                html += '  <div class="stock ' + stockClass + '">Stock: ' + product.quantity_available + ' units</div>';
                html += '  <div class="product-checkbox">';
                html += '    <input type="checkbox" id="select_' + product.product_id + '" onchange="toggleProduct(' + product.product_id + ')" ' + disabled + '>';
                html += '    <label for="select_' + product.product_id + '">Select this product</label>';
                html += '  </div>';
                html += '  <div class="quantity-control">';
                html += '    <label>Qty:</label>';
                html += '    <input type="number" id="qty_' + product.product_id + '" value="1" min="1" max="' + product.quantity_available + '" ' + disabled + ' disabled>';
                html += '    <input type="hidden" id="pid_' + product.product_id + '" name="productId" value="' + product.product_id + '" disabled>';
                html += '    <input type="hidden" id="qtyval_' + product.product_id + '" name="quantity" value="1" disabled>';
                html += '  </div>';
                html += '</div>';
            });
            html += '</div>';
            container.innerHTML = html;
        }

        function toggleProduct(productId) {
            const checkbox = document.getElementById('select_' + productId);
            const qtyInput = document.getElementById('qty_' + productId);
            const pidInput = document.getElementById('pid_' + productId);
            const qtyvalInput = document.getElementById('qtyval_' + productId);

            if (checkbox.checked) {
                qtyInput.disabled = false;
                pidInput.disabled = false;
                qtyvalInput.disabled = false;
            } else {
                qtyInput.disabled = true;
                pidInput.disabled = true;
                qtyvalInput.disabled = true;
            }
            updateSelection();
        }

        function updateSelection() {
            let selectedCount = 0;
            let totalItems = 0;

            products.forEach(product => {
                const checkbox = document.getElementById('select_' + product.product_id);
                const qtyInput = document.getElementById('qty_' + product.product_id);
                const qtyvalInput = document.getElementById('qtyval_' + product.product_id);

                if (checkbox && checkbox.checked) {
                    selectedCount++;
                    const qty = parseInt(qtyInput.value) || 0;
                    totalItems += qty;
                    // Sync the hidden quantity field
                    qtyvalInput.value = qtyInput.value;
                }
            });

            const selectedInfo = document.getElementById('selectedInfo');
            const checkoutBtn = document.getElementById('checkoutBtn');

            if (selectedCount > 0) {
                selectedInfo.textContent = selectedCount + ' product(s) selected, ' + totalItems + ' total items';
                checkoutBtn.disabled = false;
            } else {
                selectedInfo.textContent = 'Select products above and click "Proceed to Checkout"';
                checkoutBtn.disabled = true;
            }
        }

        // Add event listeners for quantity changes
        document.addEventListener('change', function(e) {
            if (e.target.type === 'number' && e.target.id.startsWith('qty_')) {
                const productId = e.target.id.replace('qty_', '');
                const qtyvalInput = document.getElementById('qtyval_' + productId);
                if (qtyvalInput) {
                    qtyvalInput.value = e.target.value;
                }
                updateSelection();
            }
        });

        function goToProfile() {
            const customerId = document.getElementById('customerId').value;
            if (!customerId) {
                alert('Please select a customer first!');
                return;
            }
            document.getElementById('profileCustomerId').value = customerId;
            document.getElementById('profileForm').submit();
        }

        function goToOrdersHistory() {
            const customerId = document.getElementById('customerId').value;
            if (!customerId) {
                alert('Please select a customer first!');
                return;
            }
            document.getElementById('ordersCustomerId').value = customerId;
            document.getElementById('ordersHistoryForm').submit();
        }

        // Validate form before submission
        document.getElementById('orderForm').addEventListener('submit', function(e) {
            const customerId = document.getElementById('customerId').value;
            if (!customerId) {
                e.preventDefault();
                alert('Please select a customer first!');
                return false;
            }

            let hasSelection = false;
            products.forEach(product => {
                const checkbox = document.getElementById('select_' + product.product_id);
                if (checkbox && checkbox.checked) {
                    hasSelection = true;
                }
            });

            if (!hasSelection) {
                e.preventDefault();
                alert('Please select at least one product!');
                return false;
            }
            return true;
        });

        // Initialize page
        window.addEventListener('DOMContentLoaded', function() {
            displayProducts();
        });
    </script>
</body>

</html>