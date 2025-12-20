<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="org.json.*" %>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Checkout - E-Commerce Store</title>
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
        }
        
        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            background: var(--bg-primary);
            min-height: 100vh;
            padding: 20px;
            color: var(--text-primary);
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
                radial-gradient(ellipse at 80% 80%, rgba(0, 255, 136, 0.05) 0%, transparent 50%);
            pointer-events: none;
            z-index: -1;
        }
        
        .container {
            max-width: 950px;
            margin: 0 auto;
            background: var(--bg-secondary);
            border-radius: 24px;
            box-shadow: 
                0 0 0 1px var(--border),
                0 25px 50px -12px rgba(0, 0, 0, 0.8);
            padding: 45px;
            animation: containerFadeIn 0.8s cubic-bezier(0.16, 1, 0.3, 1);
        }
        
        @keyframes containerFadeIn {
            from { opacity: 0; transform: translateY(30px); }
            to { opacity: 1; transform: translateY(0); }
        }
        
        header {
            text-align: center;
            margin-bottom: 40px;
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
            width: 120px;
            height: 2px;
            background: var(--gradient-accent);
            box-shadow: 0 0 20px var(--accent-glow);
        }
        
        h1 { 
            color: var(--text-primary); 
            font-size: 2.5em; 
            margin-bottom: 10px;
            font-weight: 800;
            background: linear-gradient(135deg, #ffffff 0%, #a0a0a0 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }
        
        h2 {
            color: var(--text-primary);
            font-size: 1.4em;
            margin: 35px 0 20px 0;
            padding-bottom: 12px;
            border-bottom: 1px solid var(--border);
            font-weight: 700;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .order-summary {
            background: var(--bg-card);
            border: 1px solid var(--border);
            padding: 25px;
            border-radius: 16px;
            margin-bottom: 25px;
            animation: slideUp 0.5s ease backwards;
            animation-delay: 0.1s;
        }
        
        @keyframes slideUp {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }
        
        .order-item {
            background: var(--bg-tertiary);
            border: 1px solid var(--border);
            padding: 18px 20px;
            border-radius: 12px;
            margin-bottom: 12px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            transition: all 0.3s ease;
        }
        
        .order-item:hover {
            border-color: var(--border-hover);
            background: var(--bg-hover);
        }
        
        .item-name { font-weight: 600; color: var(--text-primary); font-size: 1.05em; }
        .item-details { color: var(--text-secondary); font-size: 0.9em; margin-top: 5px; }
        
        .pricing-breakdown {
            background: var(--bg-tertiary);
            border: 1px solid var(--border);
            padding: 25px;
            border-radius: 12px;
            margin-top: 20px;
        }
        
        .price-row {
            display: flex;
            justify-content: space-between;
            padding: 12px 0;
            color: var(--text-secondary);
            font-size: 1em;
        }
        
        .price-row span:last-child { color: var(--text-primary); font-weight: 500; }
        
        .price-row.total {
            font-size: 1.5em;
            font-weight: 800;
            color: var(--accent);
            padding-top: 20px;
            margin-top: 15px;
            border-top: 2px solid var(--border);
        }
        
        .price-row.total span:last-child {
            color: var(--accent);
            text-shadow: 0 0 30px var(--accent-glow);
        }
        
        .customer-info {
            background: var(--bg-card);
            border: 1px solid var(--border);
            padding: 25px;
            border-radius: 16px;
            margin-bottom: 25px;
            animation: slideUp 0.5s ease backwards;
        }
        
        .info-row {
            padding: 12px 0;
            display: flex;
            gap: 15px;
            border-bottom: 1px solid var(--border);
        }
        
        .info-row:last-child { border-bottom: none; }
        
        .info-label { 
            font-weight: 600; 
            color: var(--text-secondary); 
            min-width: 140px;
            text-transform: uppercase;
            font-size: 0.85em;
            letter-spacing: 0.5px;
        }
        
        .info-value { color: var(--text-primary); font-weight: 500; }
        
        .button-group {
            display: flex;
            gap: 20px;
            margin-top: 35px;
            animation: slideUp 0.5s ease backwards;
            animation-delay: 0.2s;
        }
        
        .btn {
            flex: 1;
            padding: 18px;
            border: 1px solid var(--border);
            border-radius: 14px;
            font-size: 1.05em;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.4s cubic-bezier(0.16, 1, 0.3, 1);
            text-decoration: none;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            background: var(--bg-tertiary);
            color: var(--text-primary);
        }
        
        .btn:hover {
            transform: translateY(-3px);
            border-color: var(--accent);
            box-shadow: 0 10px 30px rgba(0, 212, 255, 0.2);
        }
        
        .btn-primary {
            background: var(--gradient-accent);
            color: var(--bg-primary);
            border: none;
        }
        
        .btn-primary:hover {
            box-shadow: 0 15px 40px rgba(0, 255, 136, 0.3);
        }
        
        .btn-secondary { 
            background: var(--bg-tertiary);
            color: var(--text-secondary);
        }
        
        .error-message {
            background: rgba(255, 71, 87, 0.1);
            color: var(--danger);
            padding: 20px;
            border-radius: 12px;
            margin-bottom: 20px;
            border: 1px solid rgba(255, 71, 87, 0.3);
        }
        
        .subtitle { color: var(--text-secondary); }
        
        @media (max-width: 768px) {
            .container { padding: 25px; }
            .button-group { flex-direction: column; }
            .info-row { flex-direction: column; gap: 5px; }
        }
    </style>
</head>

<body>
    <div class="container">
        <header>
            <h1>🛒 Checkout</h1>
            <p class="subtitle">Review Your Order</p>
        </header>

        <%
            // Get data passed from CheckoutServlet
            String customerId = (String) request.getAttribute("customerId");
            String customerDataJson = (String) request.getAttribute("customerData");
            String productsJson = (String) request.getAttribute("products");
            String pricingDataJson = (String) request.getAttribute("pricingData");
            String error = (String) request.getAttribute("error");
            
            if (error != null) {
        %>
            <div class="error-message">
                <strong>Error:</strong> <%= error %>
            </div>
            <div class="button-group">
                <a href="index.jsp" class="btn btn-secondary">← Back to Store</a>
            </div>
        <%
            } else if (customerId == null || productsJson == null || pricingDataJson == null) {
        %>
            <div class="error-message">
                <strong>Error:</strong> No order data found. Please go back and select products.
            </div>
            <div class="button-group">
                <a href="index.jsp" class="btn btn-secondary">← Back to Store</a>
            </div>
        <%
            } else {
                // Parse JSON data
                JSONObject customerData = new JSONObject(customerDataJson);
                JSONArray products = new JSONArray(productsJson);
                JSONObject pricingData = new JSONObject(pricingDataJson);
                JSONArray itemizedBreakdown = pricingData.getJSONArray("itemized_breakdown");
        %>
        
        <!-- Customer Information Section -->
        <h2>👤 Customer Information</h2>
        <div class="customer-info">
            <div class="info-row">
                <span class="info-label">Name:</span>
                <span class="info-value"><%= customerData.optString("name", "N/A") %></span>
            </div>
            <div class="info-row">
                <span class="info-label">Email:</span>
                <span class="info-value"><%= customerData.optString("email", "N/A") %></span>
            </div>
            <div class="info-row">
                <span class="info-label">Phone:</span>
                <span class="info-value"><%= customerData.optString("phone", "N/A") %></span>
            </div>
            <div class="info-row">
                <span class="info-label">Loyalty Points:</span>
                <span class="info-value"><%= customerData.optInt("loyalty_points", 0) %> points</span>
            </div>
        </div>

        <!-- Order Summary Section -->
        <h2>📦 Order Summary</h2>
        <div class="order-summary">
            <% for (int i = 0; i < itemizedBreakdown.length(); i++) { 
                JSONObject item = itemizedBreakdown.getJSONObject(i);
            %>
            <div class="order-item">
                <div>
                    <div class="item-name"><%= item.getString("product_name") %></div>
                    <div class="item-details">
                        $<%= String.format("%.2f", item.getDouble("unit_price")) %> × <%= item.getInt("quantity") %>
                        <% if (item.getDouble("discount_percentage") > 0) { %>
                            (<%= String.format("%.0f", item.getDouble("discount_percentage")) %>% discount)
                        <% } %>
                    </div>
                </div>
                <div class="item-name">$<%= String.format("%.2f", item.getDouble("line_total")) %></div>
            </div>
            <% } %>

            <!-- Pricing Breakdown -->
            <div class="pricing-breakdown">
                <div class="price-row">
                    <span>Subtotal:</span>
                    <span>$<%= String.format("%.2f", pricingData.getDouble("subtotal")) %></span>
                </div>
                <div class="price-row">
                    <span>Discount:</span>
                    <span>-$<%= String.format("%.2f", pricingData.getDouble("total_discount")) %></span>
                </div>
                <div class="price-row">
                    <span>Tax (<%= String.format("%.0f", pricingData.getDouble("tax_rate")) %>%):</span>
                    <span>$<%= String.format("%.2f", pricingData.getDouble("tax_amount")) %></span>
                </div>
                <div class="price-row total">
                    <span>Grand Total:</span>
                    <span>$<%= String.format("%.2f", pricingData.getDouble("grand_total")) %></span>
                </div>
            </div>
        </div>

        <!-- Form to submit to ConfirmOrderServlet -->
        <form action="ConfirmOrderServlet" method="POST">
            <input type="hidden" name="customerId" value="<%= customerId %>">
            <input type="hidden" name="products" value='<%= productsJson %>'>
            <input type="hidden" name="totalAmount" value="<%= pricingData.getDouble("grand_total") %>">
            <input type="hidden" name="pricingData" value='<%= pricingDataJson %>'>
            <input type="hidden" name="customerData" value='<%= customerDataJson %>'>
            
            <div class="button-group">
                <a href="index.jsp" class="btn btn-secondary">← Cancel</a>
                <button type="submit" class="btn btn-primary">Confirm Order ✓</button>
            </div>
        </form>
        
        <% } %>
    </div>
</body>

</html>
