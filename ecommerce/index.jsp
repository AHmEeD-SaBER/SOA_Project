<%@ page language="java" contentType="text/html; charset=UTF-8"
pageEncoding="UTF-8" buffer="64kb" autoFlush="true" %>
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
        @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap');
        
        * { margin: 0; padding: 0; box-sizing: border-box; }
        
        :root {
            --bg-primary: #0a0a0a;
            --bg-secondary: #141414;
            --bg-tertiary: #1a1a1a;
            --bg-card: #1e1e1e;
            --bg-hover: #2a2a2a;
            --text-primary: #ffffff;
            --text-secondary: #a0a0a0;
            --text-muted: #666666;
            --accent: #00d4ff;
            --accent-glow: rgba(0, 212, 255, 0.3);
            --success: #00ff88;
            --warning: #ffaa00;
            --danger: #ff4757;
            --border: #2a2a2a;
            --border-hover: #404040;
            --gradient-accent: linear-gradient(135deg, #00d4ff 0%, #00ff88 100%);
            --gradient-dark: linear-gradient(180deg, #141414 0%, #0a0a0a 100%);
        }
        
        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            background: var(--bg-primary);
            min-height: 100vh;
            padding: 20px;
            color: var(--text-primary);
            overflow-x: hidden;
        }
        
        body::before {
            content: '';
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: 
                radial-gradient(ellipse at 20% 20%, rgba(0, 212, 255, 0.08) 0%, transparent 50%),
                radial-gradient(ellipse at 80% 80%, rgba(0, 255, 136, 0.05) 0%, transparent 50%),
                radial-gradient(ellipse at 50% 50%, rgba(255, 255, 255, 0.02) 0%, transparent 70%);
            pointer-events: none;
            z-index: -1;
        }
        
        .container {
            max-width: 1400px;
            margin: 0 auto;
            background: var(--bg-secondary);
            border-radius: 24px;
            box-shadow: 
                0 0 0 1px var(--border),
                0 25px 50px -12px rgba(0, 0, 0, 0.8),
                0 0 100px rgba(0, 212, 255, 0.05);
            padding: 40px;
            animation: containerFadeIn 0.8s cubic-bezier(0.16, 1, 0.3, 1);
            backdrop-filter: blur(20px);
        }
        
        @keyframes containerFadeIn {
            from { opacity: 0; transform: translateY(30px) scale(0.98); }
            to { opacity: 1; transform: translateY(0) scale(1); }
        }
        
        header {
            text-align: center;
            margin-bottom: 50px;
            padding-bottom: 30px;
            border-bottom: 1px solid var(--border);
            position: relative;
        }
        
        header::after {
            content: '';
            position: absolute;
            bottom: -1px;
            left: 50%;
            transform: translateX(-50%);
            width: 200px;
            height: 2px;
            background: var(--gradient-accent);
            border-radius: 2px;
            box-shadow: 0 0 20px var(--accent-glow);
        }
        
        h1 { 
            color: var(--text-primary); 
            font-size: 3em; 
            margin-bottom: 12px; 
            font-weight: 800;
            letter-spacing: -0.02em;
            background: linear-gradient(135deg, #ffffff 0%, #a0a0a0 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            animation: titleGlow 3s ease-in-out infinite alternate;
        }
        
        @keyframes titleGlow {
            from { filter: drop-shadow(0 0 20px rgba(0, 212, 255, 0.2)); }
            to { filter: drop-shadow(0 0 30px rgba(0, 212, 255, 0.4)); }
        }
        
        .subtitle { 
            color: var(--text-secondary); 
            font-size: 1.1em; 
            font-weight: 400;
            letter-spacing: 0.5px;
        }
        
        .nav-links {
            margin-top: 25px;
            display: flex;
            justify-content: center;
            gap: 16px;
        }
        
        .nav-links button {
            color: var(--text-primary);
            background: var(--bg-tertiary);
            padding: 14px 28px;
            border: 1px solid var(--border);
            border-radius: 12px;
            font-weight: 600;
            cursor: pointer;
            font-size: 0.95em;
            transition: all 0.4s cubic-bezier(0.16, 1, 0.3, 1);
            position: relative;
            overflow: hidden;
            letter-spacing: 0.3px;
        }
        
        .nav-links button::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: var(--gradient-accent);
            transition: left 0.4s cubic-bezier(0.16, 1, 0.3, 1);
            z-index: -1;
        }
        
        .nav-links button:hover {
            border-color: var(--accent);
            transform: translateY(-3px);
            box-shadow: 
                0 10px 30px rgba(0, 212, 255, 0.2),
                0 0 0 1px var(--accent);
        }
        
        .nav-links button:hover::before {
            left: 0;
        }
        
        .nav-links button:active {
            transform: translateY(-1px);
        }
        
        .customer-selector {
            background: var(--bg-tertiary);
            padding: 24px 28px;
            border-radius: 16px;
            margin-bottom: 35px;
            display: flex;
            align-items: center;
            gap: 20px;
            border: 1px solid var(--border);
            transition: all 0.3s ease;
        }
        
        .customer-selector:hover {
            border-color: var(--border-hover);
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
        }
        
        .customer-selector label { 
            font-weight: 600; 
            color: var(--text-primary);
            font-size: 0.95em;
            white-space: nowrap;
        }
        
        .customer-selector select {
            flex: 1;
            padding: 14px 20px;
            border: 1px solid var(--border);
            border-radius: 10px;
            font-size: 1em;
            cursor: pointer;
            background: var(--bg-card);
            color: var(--text-primary);
            transition: all 0.3s ease;
            appearance: none;
            background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='24' height='24' viewBox='0 0 24 24' fill='none' stroke='%23a0a0a0' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpolyline points='6 9 12 15 18 9'%3E%3C/polyline%3E%3C/svg%3E");
            background-repeat: no-repeat;
            background-position: right 16px center;
            background-size: 18px;
            padding-right: 50px;
        }
        
        .customer-selector select:hover {
            border-color: var(--accent);
        }
        
        .customer-selector select:focus {
            outline: none;
            border-color: var(--accent);
            box-shadow: 0 0 0 3px var(--accent-glow);
        }
        
        .customer-selector select option {
            background: var(--bg-card);
            color: var(--text-primary);
            padding: 12px;
        }
        
        .products-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 24px;
            margin-bottom: 40px;
        }
        
        .product-card {
            background: var(--bg-card);
            border: 1px solid var(--border);
            border-radius: 16px;
            padding: 24px;
            transition: all 0.4s cubic-bezier(0.16, 1, 0.3, 1);
            position: relative;
            overflow: hidden;
            animation: cardSlideIn 0.6s cubic-bezier(0.16, 1, 0.3, 1) backwards;
        }
        
        .product-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 3px;
            background: var(--gradient-accent);
            transform: scaleX(0);
            transform-origin: left;
            transition: transform 0.4s cubic-bezier(0.16, 1, 0.3, 1);
        }
        
        .product-card:hover::before {
            transform: scaleX(1);
        }
        
        @keyframes cardSlideIn {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }
        
        .product-card:nth-child(1) { animation-delay: 0.1s; }
        .product-card:nth-child(2) { animation-delay: 0.15s; }
        .product-card:nth-child(3) { animation-delay: 0.2s; }
        .product-card:nth-child(4) { animation-delay: 0.25s; }
        .product-card:nth-child(5) { animation-delay: 0.3s; }
        .product-card:nth-child(6) { animation-delay: 0.35s; }
        .product-card:nth-child(7) { animation-delay: 0.4s; }
        .product-card:nth-child(8) { animation-delay: 0.45s; }
        .product-card:nth-child(9) { animation-delay: 0.5s; }
        .product-card:nth-child(10) { animation-delay: 0.55s; }
        
        .product-card:hover {
            transform: translateY(-8px) scale(1.02);
            border-color: var(--accent);
            box-shadow: 
                0 20px 40px rgba(0, 0, 0, 0.4),
                0 0 40px var(--accent-glow),
                inset 0 1px 0 rgba(255, 255, 255, 0.05);
        }
        
        .product-card:hover .product-icon {
            transform: scale(1.1) rotate(5deg);
            box-shadow: 0 8px 25px var(--accent-glow);
        }
        
        .product-header {
            display: flex;
            align-items: flex-start;
            gap: 16px;
            margin-bottom: 20px;
            padding-bottom: 18px;
            border-bottom: 1px solid var(--border);
        }
        
        .product-icon {
            width: 56px;
            height: 56px;
            background: linear-gradient(135deg, var(--bg-tertiary) 0%, var(--bg-hover) 100%);
            border-radius: 14px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.6em;
            flex-shrink: 0;
            border: 1px solid var(--border);
            transition: all 0.4s cubic-bezier(0.16, 1, 0.3, 1);
        }
        
        .product-title-section {
            flex: 1;
            min-width: 0;
        }
        
        .product-card h3 { 
            color: var(--text-primary); 
            margin-bottom: 6px; 
            font-size: 1.15em; 
            font-weight: 600;
            line-height: 1.4;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
        }
        
        .product-id-badge {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            background: var(--bg-tertiary);
            padding: 4px 10px;
            border-radius: 6px;
            font-size: 0.75em;
            color: var(--text-muted);
            font-weight: 500;
            border: 1px solid var(--border);
        }
        
        .price-stock-row {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 20px;
            gap: 12px;
        }
        
        .price { 
            font-size: 1.9em; 
            color: var(--accent); 
            font-weight: 800; 
            text-shadow: 0 0 30px var(--accent-glow);
            letter-spacing: -0.5px;
        }
        
        .price-currency {
            font-size: 0.55em;
            color: var(--text-secondary);
            font-weight: 500;
            vertical-align: top;
            margin-right: 2px;
        }
        
        .stock-badge { 
            background: rgba(0, 255, 136, 0.1);
            color: var(--success); 
            font-size: 0.8em; 
            display: inline-flex;
            align-items: center;
            gap: 6px;
            font-weight: 600;
            padding: 8px 14px;
            border-radius: 20px;
            border: 1px solid rgba(0, 255, 136, 0.2);
        }
        
        .stock-badge::before {
            content: '';
            width: 8px;
            height: 8px;
            background: var(--success);
            border-radius: 50%;
            box-shadow: 0 0 10px var(--success);
            animation: pulse 2s ease-in-out infinite;
        }
        
        .stock-badge.low { 
            background: rgba(255, 170, 0, 0.1);
            color: var(--warning);
            border-color: rgba(255, 170, 0, 0.2);
        }
        
        .stock-badge.low::before { 
            background: var(--warning); 
            box-shadow: 0 0 10px var(--warning); 
        }
        
        .stock-badge.out { 
            background: rgba(255, 71, 87, 0.1);
            color: var(--danger);
            border-color: rgba(255, 71, 87, 0.2);
        }
        
        .stock-badge.out::before { 
            background: var(--danger); 
            box-shadow: 0 0 10px var(--danger);
            animation: none;
        }
        
        .product-actions {
            background: var(--bg-tertiary);
            margin: 0 -24px -24px -24px;
            padding: 20px 24px;
            border-radius: 0 0 16px 16px;
            border-top: 1px solid var(--border);
        }
        
        /* Legacy stock class support */
        .stock { 
            color: var(--success); 
            font-size: 0.9em; 
            margin-bottom: 18px;
            display: flex;
            align-items: center;
            gap: 6px;
            font-weight: 500;
        }
        
        .stock::before {
            content: '';
            width: 8px;
            height: 8px;
            background: var(--success);
            border-radius: 50%;
            box-shadow: 0 0 10px var(--success);
            animation: pulse 2s ease-in-out infinite;
        }
        
        @keyframes pulse {
            0%, 100% { opacity: 1; transform: scale(1); }
            50% { opacity: 0.6; transform: scale(1.1); }
        }
        
        .stock.low { color: var(--warning); }
        .stock.low::before { background: var(--warning); box-shadow: 0 0 10px var(--warning); }
        
        .quantity-control {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 10px;
        }
        
        .quantity-control label { 
            font-weight: 600; 
            color: var(--text-secondary);
            font-size: 0.9em;
        }
        
        .quantity-control input {
            width: 80px;
            padding: 12px;
            border: 1px solid var(--border);
            border-radius: 10px;
            text-align: center;
            font-size: 1em;
            background: var(--bg-tertiary);
            color: var(--text-primary);
            transition: all 0.3s ease;
            font-weight: 600;
        }
        
        .quantity-control input:hover {
            border-color: var(--border-hover);
        }
        
        .quantity-control input:focus {
            outline: none;
            border-color: var(--accent);
            box-shadow: 0 0 0 3px var(--accent-glow);
        }
        
        .quantity-control input:disabled {
            opacity: 0.4;
            cursor: not-allowed;
        }
        
        .product-checkbox { 
            margin-bottom: 14px;
            display: flex;
            align-items: center;
        }
        
        .product-checkbox input[type="checkbox"] {
            width: 22px;
            height: 22px;
            margin-right: 12px;
            cursor: pointer;
            appearance: none;
            background: var(--bg-tertiary);
            border: 2px solid var(--border);
            border-radius: 6px;
            transition: all 0.3s ease;
            position: relative;
        }
        
        .product-checkbox input[type="checkbox"]:hover {
            border-color: var(--accent);
        }
        
        .product-checkbox input[type="checkbox"]:checked {
            background: var(--gradient-accent);
            border-color: var(--accent);
            box-shadow: 0 0 15px var(--accent-glow);
        }
        
        .product-checkbox input[type="checkbox"]:checked::after {
            content: '✓';
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            color: var(--bg-primary);
            font-size: 14px;
            font-weight: bold;
        }
        
        .product-checkbox label { 
            font-weight: 500; 
            color: var(--text-secondary); 
            cursor: pointer;
            transition: color 0.3s ease;
        }
        
        .product-checkbox:hover label {
            color: var(--text-primary);
        }
        
        .cart-section {
            background: var(--bg-tertiary);
            padding: 32px;
            border-radius: 20px;
            margin-top: 40px;
            border: 1px solid var(--border);
            position: relative;
            overflow: hidden;
        }
        
        .cart-section::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: radial-gradient(ellipse at 50% 0%, var(--accent-glow) 0%, transparent 70%);
            opacity: 0.3;
            pointer-events: none;
        }
        
        .cart-section h2 { 
            color: var(--text-primary); 
            margin-bottom: 20px; 
            font-size: 1.8em;
            font-weight: 700;
            position: relative;
        }
        
        .checkout-btn {
            width: 100%;
            background: var(--gradient-accent);
            color: var(--bg-primary);
            border: none;
            padding: 18px;
            border-radius: 14px;
            cursor: pointer;
            font-size: 1.15em;
            font-weight: 700;
            transition: all 0.4s cubic-bezier(0.16, 1, 0.3, 1);
            position: relative;
            overflow: hidden;
            letter-spacing: 0.5px;
            text-transform: uppercase;
        }
        
        .checkout-btn::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255,255,255,0.3), transparent);
            transition: left 0.6s ease;
        }
        
        .checkout-btn:hover {
            transform: translateY(-3px) scale(1.01);
            box-shadow: 
                0 15px 40px rgba(0, 212, 255, 0.4),
                0 0 60px var(--accent-glow);
        }
        
        .checkout-btn:hover::before {
            left: 100%;
        }
        
        .checkout-btn:active {
            transform: translateY(-1px) scale(1);
        }
        
        .checkout-btn:disabled { 
            background: var(--bg-hover);
            color: var(--text-muted);
            cursor: not-allowed; 
            transform: none;
            box-shadow: none;
        }
        
        .checkout-btn:disabled::before {
            display: none;
        }
        
        .error-message {
            background: rgba(255, 71, 87, 0.1);
            color: var(--danger);
            padding: 18px 24px;
            border-radius: 12px;
            margin-bottom: 24px;
            border: 1px solid rgba(255, 71, 87, 0.3);
            backdrop-filter: blur(10px);
            animation: shake 0.5s ease-in-out;
        }
        
        @keyframes shake {
            0%, 100% { transform: translateX(0); }
            20%, 60% { transform: translateX(-5px); }
            40%, 80% { transform: translateX(5px); }
        }
        
        .loading { 
            text-align: center; 
            padding: 60px; 
            font-size: 1.2em; 
            color: var(--text-secondary);
            position: relative;
        }
        
        .loading::after {
            content: '';
            display: block;
            width: 40px;
            height: 40px;
            margin: 20px auto 0;
            border: 3px solid var(--border);
            border-top-color: var(--accent);
            border-radius: 50%;
            animation: spin 1s linear infinite;
        }
        
        @keyframes spin {
            to { transform: rotate(360deg); }
        }
        
        #selectedInfo { 
            color: var(--text-secondary); 
            margin-bottom: 24px;
            font-size: 1.05em;
            font-weight: 500;
            position: relative;
        }
        
        /* Scrollbar Styling */
        ::-webkit-scrollbar {
            width: 10px;
            height: 10px;
        }
        
        ::-webkit-scrollbar-track {
            background: var(--bg-primary);
        }
        
        ::-webkit-scrollbar-thumb {
            background: var(--bg-hover);
            border-radius: 5px;
        }
        
        ::-webkit-scrollbar-thumb:hover {
            background: var(--border-hover);
        }
        
        /* Selection Styling */
        ::selection {
            background: var(--accent);
            color: var(--bg-primary);
        }
        
        /* Responsive adjustments */
        @media (max-width: 768px) {
            .container { padding: 20px; }
            h1 { font-size: 2em; }
            .nav-links { flex-direction: column; gap: 10px; }
            .customer-selector { flex-direction: column; align-items: stretch; }
            .products-grid { grid-template-columns: 1fr; }
        }
    </style>
    </head>

    <body>
        <div class="container">
            <header>
                <h1>🛒 E-Commerce Store</h1>
                <p class="subtitle">Microservices-Based Order Management
                    System</p>
                <div class="nav-links">
                    <button type="button" onclick="goToProfile()">👤 My
                        Profile</button>
                    <button type="button" onclick="goToOrdersHistory()">📋
                        Orders History</button>
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

            HttpResponse<String> customerResponse =
                customerClient.send(customerRequest,
                HttpResponse.BodyHandlers.ofString());

                if (customerResponse.statusCode() == 200) {
                customersJson = customerResponse.body();
                } else {
                customerError = "Failed to load customers. Status: " +
                customerResponse.statusCode();
                }
                } catch (Exception e) {
                customerError = "Error connecting to Customer Service: " +
                e.getMessage();
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

                HttpResponse<String> inventoryResponse =
                    client.send(inventoryRequest,
                    HttpResponse.BodyHandlers.ofString());

                    if (inventoryResponse.statusCode() == 200) {
                    productsJson = inventoryResponse.body();
                    } else {
                    errorMessage = "Failed to load products. Status: " +
                    inventoryResponse.statusCode();
                    }
                    } catch (Exception e) {
                    errorMessage = "Error connecting to Inventory Service: " +
                    e.getMessage();
                    }
                    %>

                    <% if (errorMessage != null) { %>
                    <div class="error-message">
                        <strong>Error:</strong> <%= errorMessage %>
                        <br><small>Make sure the Inventory Service is running on
                            port 5002</small>
                    </div>
                    <% } %>

                    <!-- Main Form - Submits to CheckoutServlet -->
                    <form id="orderForm" action="CheckoutServlet" method="POST">
                        <div class="customer-selector">
                            <label for="customerId">Select Customer:</label>
                            <select id="customerId" name="customerId" required>
                                <option value>-- Please select a customer
                                    --</option>
                            </select>
                            <% if (customerError != null) { %>
                            <small style="color: red;"><%= customerError
                                %></small>
                            <% } %>
                        </div>

                        <div id="productsContainer">
                            <div class="loading">Loading products...</div>
                        </div>

                        <div class="cart-section">
                            <h2>🛍️ Make Order</h2>
                            <p id="selectedInfo">Select products above and click
                                "Proceed to Checkout"</p>
                            <button type="submit" class="checkout-btn"
                                id="checkoutBtn" disabled>
                                Proceed to Checkout →
                            </button>
                        </div>
                    </form>
                </div>

                <!-- Hidden forms for navigation to ProfileServlet and OrdersHistoryServlet -->
                <form id="profileForm" action="ProfileServlet" method="GET">
                    <input type="hidden" id="profileCustomerId"
                        name="customerId" value>
                </form>

                <form id="ordersHistoryForm" action="OrdersHistoryServlet"
                    method="GET">
                    <input type="hidden" id="ordersCustomerId" name="customerId"
                        value>
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

            // Product emoji icons based on product names
            const getProductIcon = (name) => {
                const lowerName = name.toLowerCase();
                if (lowerName.includes('laptop') || lowerName.includes('computer')) return '💻';
                if (lowerName.includes('phone') || lowerName.includes('mobile')) return '📱';
                if (lowerName.includes('headphone') || lowerName.includes('audio')) return '🎧';
                if (lowerName.includes('watch')) return '⌚';
                if (lowerName.includes('camera')) return '📷';
                if (lowerName.includes('tablet') || lowerName.includes('ipad')) return '📱';
                if (lowerName.includes('keyboard')) return '⌨️';
                if (lowerName.includes('mouse')) return '🖱️';
                if (lowerName.includes('monitor') || lowerName.includes('screen')) return '🖥️';
                if (lowerName.includes('speaker')) return '🔊';
                if (lowerName.includes('game') || lowerName.includes('console')) return '🎮';
                if (lowerName.includes('printer')) return '🖨️';
                if (lowerName.includes('usb') || lowerName.includes('cable')) return '🔌';
                if (lowerName.includes('bag') || lowerName.includes('case')) return '👜';
                if (lowerName.includes('charger') || lowerName.includes('power')) return '🔋';
                return '📦';
            };

            let html = '<div class="products-grid">';
            products.forEach(product => {
                let stockClass = '';
                let stockText = '';
                if (product.quantity_available === 0) {
                    stockClass = 'out';
                    stockText = 'Out of Stock';
                } else if (product.quantity_available < 50) {
                    stockClass = 'low';
                    stockText = product.quantity_available + ' left';
                } else {
                    stockText = 'In Stock (' + product.quantity_available + ')';
                }
                const disabled = product.quantity_available === 0 ? 'disabled' : '';
                const icon = getProductIcon(product.product_name);

                html += '<div class="product-card">';
                html += '  <div class="product-header">';
                html += '    <div class="product-icon">' + icon + '</div>';
                html += '    <div class="product-title-section">';
                html += '      <h3>' + product.product_name + '</h3>';
                html += '      <span class="product-id-badge">ID: #' + product.product_id + '</span>';
                html += '    </div>';
                html += '  </div>';
                html += '  <div class="price-stock-row">';
                html += '    <div class="price"><span class="price-currency">$</span>' + parseFloat(product.unit_price).toFixed(2) + '</div>';
                html += '    <div class="stock-badge ' + stockClass + '">' + stockText + '</div>';
                html += '  </div>';
                html += '  <div class="product-actions">';
                html += '    <div class="product-checkbox">';
                html += '      <input type="checkbox" id="select_' + product.product_id + '" onchange="toggleProduct(' + product.product_id + ')" ' + disabled + '>';
                html += '      <label for="select_' + product.product_id + '">Add to Order</label>';
                html += '    </div>';
                html += '    <div class="quantity-control">';
                html += '      <label>Quantity:</label>';
                html += '      <input type="number" id="qty_' + product.product_id + '" value="1" min="1" max="' + product.quantity_available + '" ' + disabled + ' disabled>';
                html += '      <input type="hidden" id="pid_' + product.product_id + '" name="productId" value="' + product.product_id + '" disabled>';
                html += '      <input type="hidden" id="qtyval_' + product.product_id + '" name="quantity" value="1" disabled>';
                html += '    </div>';
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