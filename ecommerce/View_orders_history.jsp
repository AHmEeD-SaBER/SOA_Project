<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="org.json.*" %>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Orders History - E-Commerce Store</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }
        .container {
            max-width: 1000px;
            margin: 0 auto;
            background: white;
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
            padding: 40px;
        }
        header {
            text-align: center;
            margin-bottom: 30px;
            padding-bottom: 20px;
            border-bottom: 3px solid #667eea;
        }
        h1 { color: #333; font-size: 2.2em; margin-bottom: 10px; }
        .subtitle { color: #666; font-size: 1.1em; }
        .customer-info {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 10px;
            margin-bottom: 25px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .customer-name { font-size: 1.3em; font-weight: bold; color: #333; }
        .customer-email { color: #666; font-size: 0.95em; }
        .order-count {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 10px 20px;
            border-radius: 20px;
            font-weight: bold;
        }
        .orders-list { margin-bottom: 30px; }
        .order-card {
            background: #f8f9fa;
            border-radius: 10px;
            margin-bottom: 20px;
            overflow: hidden;
            border: 2px solid #e0e0e0;
            transition: all 0.3s ease;
        }
        .order-card:hover {
            border-color: #667eea;
            box-shadow: 0 5px 15px rgba(102, 126, 234, 0.2);
        }
        .order-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 15px 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            cursor: pointer;
        }
        .order-id { font-size: 1.2em; font-weight: bold; }
        .order-date { font-size: 0.95em; opacity: 0.9; }
        .order-status {
            padding: 5px 15px;
            border-radius: 15px;
            font-size: 0.9em;
            font-weight: bold;
            text-transform: uppercase;
        }
        .status-confirmed { background: #28a745; color: white; }
        .status-pending { background: #ffc107; color: #333; }
        .status-cancelled { background: #dc3545; color: white; }
        .order-body { padding: 20px; }
        .order-items { margin-bottom: 15px; }
        .order-items h4 { color: #333; margin-bottom: 10px; font-size: 1.1em; }
        .item-row {
            display: flex;
            justify-content: space-between;
            padding: 10px 15px;
            background: white;
            border-radius: 5px;
            margin-bottom: 8px;
        }
        .item-name { font-weight: bold; color: #333; }
        .item-details { color: #666; font-size: 0.9em; }
        .item-price { font-weight: bold; color: #667eea; }
        .order-total {
            display: flex;
            justify-content: space-between;
            padding: 15px;
            background: white;
            border-radius: 5px;
            font-size: 1.2em;
            font-weight: bold;
        }
        .order-total span:last-child { color: #667eea; }
        .empty-orders { text-align: center; padding: 60px 20px; color: #666; }
        .empty-orders .icon { font-size: 80px; margin-bottom: 20px; }
        .empty-orders h2 { color: #333; margin-bottom: 15px; }
        .button-group { display: flex; gap: 15px; margin-top: 30px; }
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
            border: 1px solid #f5c6cb;
        }
    </style>
</head>

<body>
    <div class="container">
        <header>
            <h1>📋 Orders History</h1>
            <p class="subtitle">View Your Past Orders</p>
        </header>

        <%
            // Get data passed from OrdersHistoryServlet
            String customerId = (String) request.getAttribute("customerId");
            String customerDataJson = (String) request.getAttribute("customerData");
            String ordersJson = (String) request.getAttribute("orders");
            Integer orderCount = (Integer) request.getAttribute("orderCount");
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
            } else if (customerId == null || customerDataJson == null || ordersJson == null) {
        %>
            <div class="error-message">
                <h2>⚠️ No Customer Selected</h2>
                <p>Please select a customer from the main page first.</p>
            </div>
            <div class="button-group">
                <a href="index.jsp" class="btn btn-primary">← Back to Store</a>
            </div>
        <%
            } else {
                // Parse data
                JSONObject customerData = new JSONObject(customerDataJson);
                JSONArray orders = new JSONArray(ordersJson);
        %>
        
        <!-- Customer Info Section -->
        <div class="customer-info">
            <div>
                <div class="customer-name">👤 <%= customerData.optString("name", "N/A") %></div>
                <div class="customer-email"><%= customerData.optString("email", "N/A") %></div>
            </div>
            <div class="order-count"><%= orders.length() %> Order(s)</div>
        </div>

        <% if (orders.length() == 0) { %>
            <!-- Empty Orders -->
            <div class="empty-orders">
                <div class="icon">📦</div>
                <h2>No Orders Yet</h2>
                <p>You haven't placed any orders yet. Start shopping!</p>
            </div>
        <% } else { %>
            <!-- Orders List -->
            <div class="orders-list">
                <% for (int i = 0; i < orders.length(); i++) { 
                    JSONObject order = orders.getJSONObject(i);
                    String status = order.optString("status", "confirmed").toLowerCase();
                    String statusClass = "status-" + status;
                %>
                <div class="order-card">
                    <div class="order-header" onclick="toggleOrder(<%= i %>)">
                        <div>
                            <div class="order-id">Order #<%= order.getInt("order_id") %></div>
                            <div class="order-date">📅 <%= order.optString("created_at", "N/A") %></div>
                        </div>
                        <div style="display: flex; align-items: center; gap: 15px;">
                            <span class="order-status <%= statusClass %>"><%= status %></span>
                            <span id="icon-<%= i %>">▼</span>
                        </div>
                    </div>

                    <div class="order-body" id="order-body-<%= i %>" style="display: none;">
                        <div class="order-items">
                            <h4>📦 Order Items</h4>
                            <%
                                // Try to get items from different possible keys
                                JSONArray items = null;
                                if (order.has("products")) {
                                    items = order.getJSONArray("products");
                                } else if (order.has("items")) {
                                    items = order.getJSONArray("items");
                                }
                                
                                if (items != null && items.length() > 0) {
                                    for (int j = 0; j < items.length(); j++) {
                                        JSONObject item = items.getJSONObject(j);
                                        double unitPrice = item.optDouble("unit_price", 0);
                                        int quantity = item.optInt("quantity", 0);
                                        double itemTotal = unitPrice * quantity;
                            %>
                            <div class="item-row">
                                <div>
                                    <div class="item-name"><%= item.optString("product_name", "Product #" + item.optInt("product_id", 0)) %></div>
                                    <div class="item-details">Quantity: <%= quantity %> × $<%= String.format("%.2f", unitPrice) %></div>
                                </div>
                                <div class="item-price">$<%= String.format("%.2f", itemTotal) %></div>
                            </div>
                            <%
                                    }
                                } else {
                            %>
                            <div class="item-row">
                                <div class="item-name">Order details not available</div>
                            </div>
                            <%
                                }
                            %>
                        </div>

                        <div class="order-total">
                            <span>Total Amount:</span>
                            <span>$<%= String.format("%.2f", order.optDouble("total_amount", 0)) %></span>
                        </div>
                    </div>
                </div>
                <% } %>
            </div>
        <% } %>

        <!-- Navigation Buttons -->
        <form id="profileForm" action="ProfileServlet" method="GET">
            <input type="hidden" name="customerId" value="<%= customerId %>">
        </form>
        
        <div class="button-group">
            <a href="index.jsp" class="btn btn-primary">← Back to Store</a>
            <button type="button" class="btn btn-secondary" onclick="document.getElementById('profileForm').submit()">👤 View Profile</button>
        </div>
        
        <% } %>
    </div>

    <script>
        function toggleOrder(index) {
            const orderBody = document.getElementById('order-body-' + index);
            const icon = document.getElementById('icon-' + index);

            if (orderBody.style.display === 'none' || orderBody.style.display === '') {
                orderBody.style.display = 'block';
                icon.textContent = '▲';
            } else {
                orderBody.style.display = 'none';
                icon.textContent = '▼';
            }
        }
    </script>
</body>

</html>
