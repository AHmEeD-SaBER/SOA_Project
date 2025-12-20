<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="org.json.*" %>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Order Confirmation - E-Commerce Store</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }
        .container {
            max-width: 800px;
            margin: 0 auto;
            background: white;
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
            padding: 40px;
        }
        .success-header { text-align: center; margin-bottom: 30px; }
        .success-icon {
            font-size: 80px;
            margin-bottom: 20px;
            animation: scaleIn 0.5s ease-out;
        }
        @keyframes scaleIn {
            0% { transform: scale(0); }
            50% { transform: scale(1.2); }
            100% { transform: scale(1); }
        }
        h1 { color: #28a745; font-size: 2.5em; margin-bottom: 10px; }
        .subtitle { color: #666; font-size: 1.2em; }
        .order-info {
            background: #f8f9fa;
            padding: 25px;
            border-radius: 10px;
            margin: 25px 0;
        }
        .order-number {
            text-align: center;
            font-size: 1.8em;
            color: #667eea;
            font-weight: bold;
            margin-bottom: 20px;
            padding: 15px;
            background: white;
            border-radius: 8px;
            border: 3px dashed #667eea;
        }
        h2 {
            color: #333;
            font-size: 1.5em;
            margin: 25px 0 15px 0;
            padding-bottom: 10px;
            border-bottom: 2px solid #e0e0e0;
        }
        .info-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 15px;
            margin-bottom: 20px;
        }
        .info-item {
            background: white;
            padding: 15px;
            border-radius: 5px;
        }
        .info-label { font-size: 0.9em; color: #666; margin-bottom: 5px; }
        .info-value { font-size: 1.1em; color: #333; font-weight: bold; }
        .order-items {
            background: white;
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 15px;
        }
        .item-row {
            display: flex;
            justify-content: space-between;
            padding: 12px 0;
            border-bottom: 1px solid #e0e0e0;
        }
        .item-row:last-child { border-bottom: none; }
        .item-name { font-weight: bold; color: #333; }
        .item-details { color: #666; font-size: 0.9em; margin-top: 3px; }
        .item-price { font-weight: bold; color: #667eea; text-align: right; }
        .pricing-summary {
            background: white;
            padding: 20px;
            border-radius: 5px;
        }
        .price-row {
            display: flex;
            justify-content: space-between;
            padding: 10px 0;
            color: #333;
        }
        .price-row.highlight { color: #28a745; font-weight: bold; }
        .price-row.total {
            font-size: 1.5em;
            font-weight: bold;
            color: #667eea;
            padding-top: 15px;
            margin-top: 15px;
            border-top: 3px solid #e0e0e0;
        }
        .next-steps {
            background: #e7f3ff;
            border-left: 4px solid #2196F3;
            padding: 20px;
            margin: 25px 0;
            border-radius: 5px;
        }
        .next-steps h3 { color: #2196F3; margin-bottom: 15px; }
        .next-steps ul { list-style: none; padding: 0; }
        .next-steps li {
            padding: 8px 0;
            padding-left: 25px;
            position: relative;
            color: #333;
        }
        .next-steps li:before {
            content: "✓";
            position: absolute;
            left: 0;
            color: #28a745;
            font-weight: bold;
        }
        .loyalty-earned {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 20px;
            border-radius: 10px;
            text-align: center;
            margin: 20px 0;
        }
        .loyalty-earned h3 { margin-bottom: 10px; }
        .loyalty-points { font-size: 2em; font-weight: bold; }
        .button-group {
            display: flex;
            gap: 15px;
            margin-top: 30px;
        }
        .btn {
            flex: 1;
            padding: 15px;
            border: none;
            border-radius: 5px;
            font-size: 1.1em;
            font-weight: bold;
            cursor: pointer;
            transition: all 0.3s ease;
            text-align: center;
            text-decoration: none;
            display: block;
        }
        .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        .btn-primary:hover {
            transform: scale(1.02);
            box-shadow: 0 5px 15px rgba(102, 126, 234, 0.4);
        }
        .btn-secondary { background: #28a745; color: white; }
        .btn-secondary:hover { background: #218838; }
        .error-message {
            background: #f8d7da;
            color: #721c24;
            padding: 20px;
            border-radius: 5px;
            text-align: center;
            margin: 20px 0;
        }
        @media print {
            body { background: white; }
            .button-group { display: none; }
            .container { box-shadow: none; }
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
