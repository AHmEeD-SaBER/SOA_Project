<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="org.json.*" %>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Order Confirmation - E-Commerce Store</title>
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
            --success-glow: rgba(0, 255, 136, 0.3);
            --warning: #ffaa00;
            --danger: #ff4757;
            --border: #2a2a2a;
            --border-hover: #404040;
            --gradient-accent: linear-gradient(135deg, #00d4ff 0%, #00ff88 100%);
            --gradient-success: linear-gradient(135deg, #00ff88 0%, #00d4ff 100%);
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
                radial-gradient(ellipse at 50% 30%, rgba(0, 255, 136, 0.1) 0%, transparent 50%),
                radial-gradient(ellipse at 20% 80%, rgba(0, 212, 255, 0.08) 0%, transparent 50%);
            pointer-events: none;
            z-index: -1;
        }
        
        .container {
            max-width: 900px;
            margin: 0 auto;
            background: var(--bg-secondary);
            border-radius: 24px;
            box-shadow: 
                0 0 0 1px var(--border),
                0 25px 50px -12px rgba(0, 0, 0, 0.8),
                0 0 120px rgba(0, 255, 136, 0.08);
            padding: 50px;
            animation: containerFadeIn 0.8s cubic-bezier(0.16, 1, 0.3, 1);
        }
        
        @keyframes containerFadeIn {
            from { opacity: 0; transform: translateY(30px) scale(0.98); }
            to { opacity: 1; transform: translateY(0) scale(1); }
        }
        
        .success-header { 
            text-align: center; 
            margin-bottom: 40px;
            animation: slideDown 0.6s ease backwards;
        }
        
        @keyframes slideDown {
            from { opacity: 0; transform: translateY(-20px); }
            to { opacity: 1; transform: translateY(0); }
        }
        
        .success-icon {
            font-size: 100px;
            margin-bottom: 25px;
            animation: successPop 0.6s cubic-bezier(0.16, 1, 0.3, 1) 0.2s backwards;
            filter: drop-shadow(0 0 40px var(--success-glow));
        }
        
        @keyframes successPop {
            0% { transform: scale(0); opacity: 0; }
            50% { transform: scale(1.2); }
            100% { transform: scale(1); opacity: 1; }
        }
        
        h1 { 
            color: var(--success); 
            font-size: 2.8em; 
            margin-bottom: 12px;
            font-weight: 800;
            text-shadow: 0 0 40px var(--success-glow);
        }
        
        .subtitle { color: var(--text-secondary); font-size: 1.2em; }
        
        .order-info {
            background: var(--bg-card);
            border: 1px solid var(--border);
            padding: 35px;
            border-radius: 20px;
            margin: 30px 0;
            animation: slideUp 0.5s ease backwards;
            animation-delay: 0.1s;
        }
        
        @keyframes slideUp {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }
        
        .order-number {
            text-align: center;
            font-size: 2em;
            color: var(--accent);
            font-weight: 800;
            margin-bottom: 30px;
            padding: 25px;
            background: var(--bg-tertiary);
            border-radius: 16px;
            border: 2px dashed var(--accent);
            text-shadow: 0 0 30px var(--accent-glow);
            animation: glow 2s ease-in-out infinite alternate;
        }
        
        @keyframes glow {
            from { box-shadow: 0 0 20px var(--accent-glow); }
            to { box-shadow: 0 0 40px var(--accent-glow); }
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
        
        .info-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 18px;
        }
        
        .info-item {
            background: var(--bg-tertiary);
            border: 1px solid var(--border);
            padding: 20px;
            border-radius: 12px;
            transition: all 0.3s ease;
        }
        
        .info-item:hover {
            border-color: var(--border-hover);
            transform: translateY(-2px);
        }
        
        .info-label { 
            font-size: 0.8em; 
            color: var(--text-muted); 
            margin-bottom: 8px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        
        .info-value { font-size: 1.15em; color: var(--text-primary); font-weight: 600; }
        
        .order-items {
            background: var(--bg-card);
            border: 1px solid var(--border);
            padding: 25px;
            border-radius: 16px;
            margin-bottom: 20px;
            animation: slideUp 0.5s ease backwards;
            animation-delay: 0.15s;
        }
        
        .item-row {
            display: flex;
            justify-content: space-between;
            padding: 16px 0;
            border-bottom: 1px solid var(--border);
            transition: all 0.3s ease;
        }
        
        .item-row:last-child { border-bottom: none; }
        
        .item-row:hover {
            background: var(--bg-tertiary);
            margin: 0 -15px;
            padding: 16px 15px;
            border-radius: 8px;
        }
        
        .item-name { font-weight: 600; color: var(--text-primary); }
        .item-details { color: var(--text-secondary); font-size: 0.9em; margin-top: 4px; }
        .item-price { font-weight: 700; color: var(--accent); text-align: right; font-size: 1.1em; }
        
        .pricing-summary {
            background: var(--bg-card);
            border: 1px solid var(--border);
            padding: 28px;
            border-radius: 16px;
            animation: slideUp 0.5s ease backwards;
            animation-delay: 0.2s;
        }
        
        .price-row {
            display: flex;
            justify-content: space-between;
            padding: 12px 0;
            color: var(--text-secondary);
        }
        
        .price-row span:last-child { color: var(--text-primary); font-weight: 500; }
        
        .price-row.highlight { 
            color: var(--success); 
            font-weight: 700;
        }
        
        .price-row.highlight span:last-child { color: var(--success); }
        
        .price-row.total {
            font-size: 1.6em;
            font-weight: 800;
            padding-top: 20px;
            margin-top: 15px;
            border-top: 2px solid var(--border);
        }
        
        .price-row.total span {
            background: var(--gradient-accent);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }
        
        .next-steps {
            background: rgba(0, 212, 255, 0.08);
            border-left: 4px solid var(--accent);
            padding: 28px;
            margin: 30px 0;
            border-radius: 0 16px 16px 0;
            animation: slideUp 0.5s ease backwards;
            animation-delay: 0.25s;
        }
        
        .next-steps h3 { 
            color: var(--accent); 
            margin-bottom: 18px;
            font-size: 1.2em;
        }
        
        .next-steps ul { list-style: none; }
        
        .next-steps li {
            padding: 10px 0;
            padding-left: 30px;
            position: relative;
            color: var(--text-secondary);
            font-size: 0.95em;
        }
        
        .next-steps li:before {
            content: "✓";
            position: absolute;
            left: 0;
            color: var(--success);
            font-weight: bold;
            font-size: 1.1em;
        }
        
        .loyalty-earned {
            background: var(--bg-card);
            border: 1px solid var(--border);
            padding: 35px;
            border-radius: 20px;
            text-align: center;
            margin: 30px 0;
            position: relative;
            overflow: hidden;
            animation: slideUp 0.5s ease backwards;
            animation-delay: 0.3s;
        }
        
        .loyalty-earned::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 4px;
            background: var(--gradient-success);
        }
        
        .loyalty-earned::after {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: radial-gradient(ellipse at 50% 0%, var(--success-glow) 0%, transparent 60%);
            pointer-events: none;
        }
        
        .loyalty-earned h3 { 
            margin-bottom: 15px;
            color: var(--text-secondary);
            position: relative;
            z-index: 1;
        }
        
        .loyalty-points { 
            font-size: 3.5em; 
            font-weight: 800;
            background: var(--gradient-success);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            position: relative;
            z-index: 1;
        }
        
        .loyalty-earned p {
            color: var(--text-secondary);
            margin-top: 10px;
            position: relative;
            z-index: 1;
        }
        
        .button-group {
            display: flex;
            gap: 20px;
            margin-top: 35px;
            animation: slideUp 0.5s ease backwards;
            animation-delay: 0.35s;
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
            text-align: center;
            text-decoration: none;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
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
            box-shadow: 0 15px 40px var(--accent-glow);
        }
        
        .btn-secondary { 
            background: var(--gradient-success);
            color: var(--bg-primary);
            border: none;
        }
        
        .btn-secondary:hover { 
            box-shadow: 0 15px 40px var(--success-glow);
        }
        
        .error-message {
            background: rgba(255, 71, 87, 0.1);
            color: var(--danger);
            padding: 30px;
            border-radius: 16px;
            text-align: center;
            margin: 20px 0;
            border: 1px solid rgba(255, 71, 87, 0.3);
        }
        
        .error-message h2 { border: none; justify-content: center; }
        
        @media print {
            body { background: white; color: black; }
            .button-group { display: none; }
            .container { box-shadow: none; background: white; }
            :root { --text-primary: #000; --text-secondary: #333; }
        }
        
        @media (max-width: 768px) {
            .container { padding: 25px; }
            .info-grid { grid-template-columns: 1fr; }
            .button-group { flex-direction: column; }
            h1 { font-size: 2em; }
        }
    </style>
</head>

<body>
    <div class="container">
        <%
            // Get data passed from ConfirmOrderServlet
            String orderDataJson = (String) request.getAttribute("orderData");
            String pricingDataJson = (String) request.getAttribute("pricingData");
            String customerDataJson = (String) request.getAttribute("customerData");
            String productsJson = (String) request.getAttribute("products");
            String error = (String) request.getAttribute("error");
            
            if (error != null) {
        %>
            <div class="error-message">
                <h2>⚠️ Error</h2>
                <p><%= error %></p>
            </div>
            <div class="button-group">
                <a href="index.jsp" class="btn btn-primary">← Back to Store</a>
            </div>
        <%
            } else if (orderDataJson == null || pricingDataJson == null || customerDataJson == null) {
        %>
            <div class="error-message">
                <h2>⚠️ No Order Data Found</h2>
                <p>We couldn't find your order information. Please start over.</p>
            </div>
            <div class="button-group">
                <a href="index.jsp" class="btn btn-primary">← Back to Store</a>
            </div>
        <%
            } else {
                // Parse JSON data
                JSONObject orderData = new JSONObject(orderDataJson);
                JSONObject pricingData = new JSONObject(pricingDataJson);
                JSONObject customerData = new JSONObject(customerDataJson);
                JSONArray itemizedBreakdown = pricingData.getJSONArray("itemized_breakdown");
        %>
        
        <!-- Success Header -->
        <div class="success-header">
            <div class="success-icon">✅</div>
            <h1>Order Confirmed!</h1>
            <p class="subtitle">Thank you for your purchase</p>
        </div>

        <!-- Order Info -->
        <div class="order-info">
            <div class="order-number">
                Order #<%= orderData.getInt("order_id") %>
            </div>

            <div class="info-grid">
                <div class="info-item">
                    <div class="info-label">Customer Name</div>
                    <div class="info-value"><%= customerData.optString("name", "N/A") %></div>
                </div>
                <div class="info-item">
                    <div class="info-label">Email</div>
                    <div class="info-value"><%= customerData.optString("email", "N/A") %></div>
                </div>
                <div class="info-item">
                    <div class="info-label">Order Date</div>
                    <div class="info-value"><%= orderData.optString("created_at", "N/A") %></div>
                </div>
                <div class="info-item">
                    <div class="info-label">Order Status</div>
                    <div class="info-value" style="color: #28a745;"><%= orderData.optString("status", "confirmed").toUpperCase() %></div>
                </div>
            </div>
        </div>

        <!-- Order Details -->
        <h2>📦 Order Details</h2>
        <div class="order-items">
            <% for (int i = 0; i < itemizedBreakdown.length(); i++) { 
                JSONObject item = itemizedBreakdown.getJSONObject(i);
            %>
            <div class="item-row">
                <div>
                    <div class="item-name"><%= item.getString("product_name") %></div>
                    <div class="item-details">
                        Quantity: <%= item.getInt("quantity") %> × $<%= String.format("%.2f", item.getDouble("unit_price")) %>
                        <% if (item.getDouble("discount_percentage") > 0) { %>
                            <span style="color: #28a745;">(<%= String.format("%.0f", item.getDouble("discount_percentage")) %>% discount applied)</span>
                        <% } %>
                    </div>
                </div>
                <div class="item-price">$<%= String.format("%.2f", item.getDouble("line_total")) %></div>
            </div>
            <% } %>
        </div>

        <!-- Pricing Summary -->
        <div class="pricing-summary">
            <div class="price-row">
                <span>Subtotal:</span>
                <span>$<%= String.format("%.2f", pricingData.getDouble("subtotal")) %></span>
            </div>
            <% if (pricingData.getDouble("total_discount") > 0) { %>
            <div class="price-row highlight">
                <span>You Saved:</span>
                <span>-$<%= String.format("%.2f", pricingData.getDouble("total_discount")) %></span>
            </div>
            <% } %>
            <div class="price-row">
                <span>Subtotal After Discount:</span>
                <span>$<%= String.format("%.2f", pricingData.getDouble("subtotal_after_discount")) %></span>
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

        <!-- Loyalty Points Earned -->
        <div class="loyalty-earned">
            <h3>⭐ Loyalty Points Earned</h3>
            <div class="loyalty-points">+<%= orderData.optInt("loyalty_points_earned", 0) %> points</div>
            <p>New Balance: <%= orderData.optInt("new_loyalty_balance", 0) %> points</p>
        </div>

        <!-- Next Steps -->
        <div class="next-steps">
            <h3>📋 What Happens Next?</h3>
            <ul>
                <li>A confirmation email has been sent to your registered email address</li>
                <li>Your order is being processed and will be shipped within 2-3 business days</li>
                <li>You will receive a tracking number once your order ships</li>
                <li>Estimated delivery: 3-5 business days</li>
            </ul>
        </div>

        <!-- Navigation Buttons -->
        <div class="button-group">
            <a href="index.jsp" class="btn btn-primary">← Continue Shopping</a>
            <button class="btn btn-secondary" onclick="window.print()">🖨️ Print Receipt</button>
        </div>
        
        <% } %>
    </div>
</body>

</html>
