<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="org.json.*" %>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Checkout - E-Commerce Store</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }
        .container {
            max-width: 900px;
            margin: 0 auto;
            background: white;
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
            padding: 30px;
        }
        header {
            text-align: center;
            margin-bottom: 30px;
            padding-bottom: 20px;
            border-bottom: 3px solid #667eea;
        }
        h1 { color: #333; font-size: 2.2em; margin-bottom: 10px; }
        h2 {
            color: #333;
            font-size: 1.5em;
            margin: 25px 0 15px 0;
            padding-bottom: 10px;
            border-bottom: 2px solid #e0e0e0;
        }
        .order-summary {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 10px;
            margin-bottom: 20px;
        }
        .order-item {
            background: white;
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 10px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .item-name { font-weight: bold; color: #333; }
        .item-details { color: #666; font-size: 0.9em; margin-top: 5px; }
        .pricing-breakdown {
            background: #fff;
            padding: 20px;
            border-radius: 5px;
            margin-top: 15px;
        }
        .price-row {
            display: flex;
            justify-content: space-between;
            padding: 8px 0;
            color: #333;
        }
        .price-row.total {
            font-size: 1.3em;
            font-weight: bold;
            color: #667eea;
            padding-top: 15px;
            margin-top: 15px;
            border-top: 2px solid #e0e0e0;
        }
        .customer-info {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 10px;
            margin-bottom: 20px;
        }
        .info-row {
            padding: 8px 0;
            display: flex;
            gap: 10px;
        }
        .info-label { font-weight: bold; color: #333; min-width: 120px; }
        .info-value { color: #666; }
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
        }
        .btn-primary {
            background: linear-gradient(135deg, #28a745 0%, #20c997 100%);
            color: white;
        }
        .btn-primary:hover {
            transform: scale(1.02);
            box-shadow: 0 5px 15px rgba(40, 167, 69, 0.4);
        }
        .btn-secondary { background: #6c757d; color: white; }
        .btn-secondary:hover { background: #5a6268; }
        .error-message {
            background: #f8d7da;
            color: #721c24;
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 20px;
            border: 1px solid #f5c6cb;
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
