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
                        * {
                            margin: 0;
                            padding: 0;
                            box-sizing: border-box;
                        }

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

                        h1 {
                            color: #333;
                            font-size: 2.5em;
                            margin-bottom: 10px;
                        }

                        .subtitle {
                            color: #666;
                            font-size: 1.1em;
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

                        .customer-selector label {
                            font-weight: bold;
                            color: #333;
                        }

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
                            display: flex;
                            flex-direction: column;
                        }

                        .product-card:hover {
                            transform: translateY(-5px);
                            box-shadow: 0 5px 20px rgba(102, 126, 234, 0.3);
                            border-color: #667eea;
                        }

                        .product-card h3 {
                            color: #333;
                            margin-bottom: 10px;
                            font-size: 1.2em;
                            min-height: 50px;
                        }

                        .product-info {
                            flex: 1;
                        }

                        .price {
                            font-size: 1.5em;
                            color: #667eea;
                            font-weight: bold;
                            margin: 10px 0;
                        }

                        .stock {
                            color: #28a745;
                            font-size: 0.9em;
                            margin-bottom: 15px;
                        }

                        .stock.low {
                            color: #ffc107;
                        }

                        .stock.out {
                            color: #dc3545;
                        }

                        .quantity-control {
                            display: flex;
                            align-items: center;
                            gap: 10px;
                            margin-bottom: 15px;
                        }

                        .quantity-control label {
                            font-weight: bold;
                            color: #333;
                        }

                        .quantity-control input {
                            width: 70px;
                            padding: 8px;
                            border: 2px solid #ddd;
                            border-radius: 5px;
                            text-align: center;
                            font-size: 1em;
                        }

                        .add-to-cart-btn {
                            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                            color: white;
                            border: none;
                            padding: 12px 20px;
                            border-radius: 5px;
                            cursor: pointer;
                            font-size: 1em;
                            font-weight: bold;
                            transition: all 0.3s ease;
                        }

                        .add-to-cart-btn:hover {
                            transform: scale(1.05);
                            box-shadow: 0 5px 15px rgba(102, 126, 234, 0.4);
                        }

                        .add-to-cart-btn:disabled {
                            background: #ccc;
                            cursor: not-allowed;
                            transform: none;
                        }

                        .cart-section {
                            background: #f8f9fa;
                            padding: 25px;
                            border-radius: 10px;
                            margin-top: 30px;
                        }

                        .cart-section h2 {
                            color: #333;
                            margin-bottom: 20px;
                            font-size: 1.8em;
                        }

                        .cart-items {
                            margin-bottom: 20px;
                        }

                        .cart-item {
                            background: white;
                            padding: 15px;
                            border-radius: 5px;
                            margin-bottom: 10px;
                            display: flex;
                            justify-content: space-between;
                            align-items: center;
                        }

                        .cart-item-info {
                            flex: 1;
                        }

                        .cart-item-name {
                            font-weight: bold;
                            color: #333;
                            margin-bottom: 5px;
                        }

                        .cart-item-details {
                            color: #666;
                            font-size: 0.9em;
                        }

                        .remove-btn {
                            background: #dc3545;
                            color: white;
                            border: none;
                            padding: 8px 15px;
                            border-radius: 5px;
                            cursor: pointer;
                            font-size: 0.9em;
                        }

                        .remove-btn:hover {
                            background: #c82333;
                        }

                        .cart-total {
                            background: white;
                            padding: 20px;
                            border-radius: 5px;
                            margin-bottom: 20px;
                        }

                        .total-row {
                            display: flex;
                            justify-content: space-between;
                            margin-bottom: 10px;
                            font-size: 1.1em;
                        }

                        .total-row.grand-total {
                            font-size: 1.5em;
                            font-weight: bold;
                            color: #667eea;
                            padding-top: 10px;
                            border-top: 2px solid #ddd;
                        }

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

                        .checkout-btn:disabled {
                            background: #ccc;
                            cursor: not-allowed;
                            transform: none;
                        }

                        .empty-cart {
                            text-align: center;
                            color: #999;
                            padding: 40px;
                            font-size: 1.1em;
                        }

                        .error-message {
                            background: #f8d7da;
                            color: #721c24;
                            padding: 15px;
                            border-radius: 5px;
                            margin-bottom: 20px;
                            border: 1px solid #f5c6cb;
                        }

                        .loading {
                            text-align: center;
                            padding: 40px;
                            font-size: 1.2em;
                            color: #667eea;
                        }
                    </style>
                </head>

                <body>
                    <h1 style="color: red; padding: 20px;">TEST - If you see this, HTML is loading!</h1>
                    <div class="container">
                        <header>
                            <h1>🛒 E-Commerce Store</h1>
                            <p class="subtitle">Microservices-Based Order Management System</p>
                        </header>

                        <%
                            // Call Customer Service to get all customers
                            String customersJson = null;
                            String customerError = null;
                            
                            try {
                                System.out.println("JSP: Calling Customer Service for customers list...");
                                HttpClient customerClient = HttpClient.newHttpClient();
                                HttpRequest customerRequest = HttpRequest.newBuilder()
                                    .uri(URI.create("http://localhost:5004/api/customers"))
                                    .GET()
                                    .build();
                                
                                HttpResponse<String> customerResponse = customerClient.send(customerRequest, HttpResponse.BodyHandlers.ofString());
                                System.out.println("JSP: Got customer response with status: " + customerResponse.statusCode());

                                if (customerResponse.statusCode() == 200) {
                                    customersJson = customerResponse.body();
                                } else {
                                    customerError = "Failed to load customers. Status: " + customerResponse.statusCode();
                                }

                            } catch (Exception e) {
                                customerError = "Error connecting to Customer Service: " + e.getMessage();
                                System.err.println("JSP Customer ERROR: " + e.getMessage());
                            }
                        %>

                        <div class="customer-selector">
                            <label for="customerId">Select Customer:</label>
                            <select id="customerId" name="customerId">
                                <option value="">-- Please select a customer --</option>
                            </select>
                            <% if (customerError != null) { %>
                                <small style="color: red;"><%= customerError %></small>
                            <% } %>
                        </div>

                        <%
                            // Call Inventory Service to get products
                            String errorMessage = null;
                            String productsJson = null;
                            
                            try {
                                System.out.println("JSP: Calling Inventory Service...");
                                HttpClient client = HttpClient.newHttpClient();
                                HttpRequest inventoryRequest = HttpRequest.newBuilder()
                                    .uri(URI.create("http://localhost:5002/api/inventory/products"))
                                    .GET()
                                    .build();
                                
                                HttpResponse<String> inventoryResponse = client.send(inventoryRequest, HttpResponse.BodyHandlers.ofString());
                                System.out.println("JSP: Got response with status: " + inventoryResponse.statusCode());

                                if (inventoryResponse.statusCode() == 200) {
                                    productsJson = inventoryResponse.body();
                                    System.out.println("JSP: Products JSON length: " + (productsJson != null ? productsJson.length() : 0));
                                } else {
                                    errorMessage = "Failed to load products. Status: " + inventoryResponse.statusCode();
                                }

                            } catch (Exception e) {
                                errorMessage = "Error connecting to Inventory Service: " + e.getMessage();
                                System.err.println("JSP ERROR: " + e.getMessage());
                                e.printStackTrace();
                            }
                        %>
                        
                        <!-- DEBUG: Show if data was loaded -->
                        <% if (productsJson != null) { %>
                            <div style="background: #d4edda; padding: 10px; margin: 10px 0; border-radius: 5px; color: #155724;">
                                ✓ Products data loaded from Inventory Service (Length: <%= productsJson.length() %>)
                            </div>
                        <% } %>

                        <% if (errorMessage != null) { %>
                            <div class="error-message">
                                <strong>Error:</strong>
                                <%= errorMessage %>
                                <br><small>Make sure the Inventory Service is running on port 5002</small>
                            </div>
                        <% } %>

                        <div id="productsContainer">
                            <div class="loading">Loading products...</div>
                        </div>

                        <div class="cart-section">
                                        <h2>🛍️ Shopping Cart</h2>
                                        <div id="cartItems" class="cart-items">
                                            <div class="empty-cart">Your cart is empty. Add some products!</div>
                                        </div>
                                        <div id="cartTotal" class="cart-total" style="display: none;">
                                            <div class="total-row">
                                                <span>Subtotal:</span>
                                                <span id="subtotal">$0.00</span>
                                            </div>
                                            <div class="total-row">
                                                <span>Discount:</span>
                                                <span id="discount">$0.00</span>
                                            </div>
                                            <div class="total-row">
                                                <span>Tax (14%):</span>
                                                <span id="tax">$0.00</span>
                                            </div>
                                            <div class="total-row grand-total">
                                                <span>Total:</span>
                                                <span id="grandTotal">$0.00</span>
                                            </div>
                                        </div>
                                        <button class="checkout-btn" id="checkoutBtn" onclick="goToCheckout()" disabled>
                                            Proceed to Checkout →
                                        </button>
                                    </div>
                    </div>

                    <script>
                        let cart = [];
                        let products = [];
                        let customers = [];

                        // Load customers from server response
                        <% if (customersJson != null) { %>
                            try {
                                const customerData = <%= customersJson %>;
                                if (customerData.status === 'success') {
                                    customers = customerData.customers;
                                    console.log('Customers loaded:', customers.length);
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
                                    console.log('Products loaded:', products.length);
                                }
                            } catch (e) {
                                console.error('Error parsing products:', e);
                            }
                        <% } else { %>
                            console.error('No products data received from server');
                        <% } %>

                        function populateCustomers() {
                            console.log('populateCustomers() called');
                            console.log('Customers:', customers);
                            const customerSelect = document.getElementById('customerId');
                            customers.forEach(customer => {
                                const option = document.createElement('option');
                                option.value = customer.customer_id;
                                option.textContent = customer.name + ' (Loyalty Points: ' + customer.loyalty_points + ')';
                                customerSelect.appendChild(option);
                            });
                        }

                        function displayProducts() {
                                console.log('displayProducts() called');
                                console.log('Products array:', products);
                                console.log('Products length:', products.length);
                                
                                const container = document.getElementById('productsContainer');
                                console.log('Container element:', container);

                                if (!container) {
                                    console.error('productsContainer element not found!');
                                    return;
                                }

                                if (products.length === 0) {
                                    console.log('No products to display');
                                    container.innerHTML = '<div class="empty-cart">No products available</div>';
                                    return;
                                }

                                console.log('Building products HTML...');
                                let html = '<div class="products-grid">';

                                products.forEach(product => {
                                    const stockClass = product.quantity_available < 50 ? 'low' :
                                        product.quantity_available === 0 ? 'out' : '';
                                    const disabled = product.quantity_available === 0 ? 'disabled' : '';

                                    html += '<div class="product-card">';
                                    html += '  <div class="product-info">';
                                    html += '    <h3>' + product.product_name + '</h3>';
                                    html += '    <div class="price">$' + parseFloat(product.unit_price).toFixed(2) + '</div>';
                                    html += '    <div class="stock ' + stockClass + '">';
                                    html += '      Stock: ' + product.quantity_available + ' units';
                                    html += '    </div>';
                                    html += '  </div>';
                                    html += '  <div class="quantity-control">';
                                    html += '    <label>Qty:</label>';
                                    html += '    <input type="number" id="qty_' + product.product_id + '" value="1" min="1" max="' + product.quantity_available + '" ' + disabled + '>';
                                    html += '  </div>';
                                    html += '  <button class="add-to-cart-btn" onclick="addToCart(' + product.product_id + ')" ' + disabled + '>';
                                    html += '    ' + (disabled ? 'Out of Stock' : 'Add to Cart');
                                    html += '  </button>';
                                    html += '</div>';
                                });

                                html += '</div>';
                                container.innerHTML = html;
                            }

                        function addToCart(productId) {
                            const product = products.find(p => p.product_id === productId);
                            if (!product) return;

                            const qtyInput = document.getElementById('qty_' + productId);
                            const quantity = parseInt(qtyInput.value);

                            if (quantity <= 0 || quantity > product.quantity_available) {
                                alert('Invalid quantity');
                                return;
                            }

                            // Check if product already in cart
                            const existingItem = cart.find(item => item.product_id === productId);

                            if (existingItem) {
                                existingItem.quantity += quantity;
                            } else {
                                cart.push({
                                    product_id: productId,
                                    product_name: product.product_name,
                                    unit_price: product.unit_price,
                                    quantity: quantity
                                });
                            }

                            updateCartDisplay();
                            qtyInput.value = 1;
                        }

                        function removeFromCart(productId) {
                            cart = cart.filter(item => item.product_id !== productId);
                            updateCartDisplay();
                        }

                        function updateCartDisplay() {
                            const cartItemsDiv = document.getElementById('cartItems');
                            const cartTotalDiv = document.getElementById('cartTotal');
                            const checkoutBtn = document.getElementById('checkoutBtn');

                            if (cart.length === 0) {
                                cartItemsDiv.innerHTML = '<div class="empty-cart">Your cart is empty. Add some products!</div>';
                                cartTotalDiv.style.display = 'none';
                                checkoutBtn.disabled = true;
                                return;
                            }

                            // Display cart items
                            let html = '';
                            let subtotal = 0;

                            cart.forEach(item => {
                                const itemTotal = item.unit_price * item.quantity;
                                subtotal += itemTotal;

                                html += '<div class="cart-item">';
                                html += '  <div class="cart-item-info">';
                                html += '    <div class="cart-item-name">' + item.product_name + '</div>';
                                html += '    <div class="cart-item-details">';
                                html += '      $' + parseFloat(item.unit_price).toFixed(2) + ' × ' + item.quantity + ' = $' + itemTotal.toFixed(2);
                                html += '    </div>';
                                html += '  </div>';
                                html += '  <button class="remove-btn" onclick="removeFromCart(' + item.product_id + ')">Remove</button>';
                                html += '</div>';
                            });

                            cartItemsDiv.innerHTML = html;

                            // Calculate totals (approximate - server will calculate exact pricing)
                            const discount = 0; // Will be calculated by pricing service
                            const taxRate = 0.14;
                            const tax = subtotal * taxRate;
                            const grandTotal = subtotal + tax;

                            document.getElementById('subtotal').textContent = '$' + subtotal.toFixed(2);
                            document.getElementById('discount').textContent = '$' + discount.toFixed(2);
                            document.getElementById('tax').textContent = '$' + tax.toFixed(2);
                            document.getElementById('grandTotal').textContent = '$' + grandTotal.toFixed(2);

                            cartTotalDiv.style.display = 'block';
                            checkoutBtn.disabled = false;
                        }

                        function goToCheckout() {
                            const customerId = document.getElementById('customerId').value;

                            console.log('=== INDEX - Proceeding to Checkout ===');
                            console.log('Selected Customer ID:', customerId);
                            console.log('Cart:', cart);

                            if (!customerId) {
                                alert('Please select a customer first!');
                                return;
                            }

                            if (cart.length === 0) {
                                alert('Your cart is empty!');
                                return;
                            }

                            // Store cart in session storage for checkout page
                            console.log('Saving to sessionStorage...');
                            sessionStorage.setItem('cart', JSON.stringify(cart));
                            sessionStorage.setItem('customerId', customerId);
                            console.log('Data saved to sessionStorage:');
                            console.log('- cart:', sessionStorage.getItem('cart'));
                            console.log('- customerId:', sessionStorage.getItem('customerId'));

                            // Redirect to checkout
                            console.log('Redirecting to checkout.jsp...');
                            window.location.href = 'checkout.jsp';
                        }

                        // Initialize page when DOM is ready
                        window.addEventListener('DOMContentLoaded', function() {
                            console.log('DOM loaded, displaying products...');
                            displayProducts();
                        });
                    </script>
                </body>

                </html>