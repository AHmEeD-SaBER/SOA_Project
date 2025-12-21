<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="org.json.*" %>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Orders History - E-Commerce Store</title>
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
            max-width: 1100px;
            margin: 0 auto;
            background: var(--bg-secondary);
            border-radius: 24px;
            box-shadow: 
                0 0 0 1px var(--border),
                0 25px 50px -12px rgba(0, 0, 0, 0.8),
                0 0 100px rgba(0, 212, 255, 0.05);
            padding: 50px;
            animation: containerFadeIn 0.8s cubic-bezier(0.16, 1, 0.3, 1);
        }
        
        @keyframes containerFadeIn {
            from { opacity: 0; transform: translateY(30px) scale(0.98); }
            to { opacity: 1; transform: translateY(0) scale(1); }
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
            width: 150px;
            height: 2px;
            background: var(--gradient-accent);
            border-radius: 2px;
            box-shadow: 0 0 20px var(--accent-glow);
        }
        
        h1 { 
            color: var(--text-primary); 
            font-size: 2.5em; 
            margin-bottom: 12px;
            font-weight: 800;
            background: linear-gradient(135deg, #ffffff 0%, #a0a0a0 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }
        
        .subtitle { color: var(--text-secondary); font-size: 1.1em; }
        
        .customer-info {
            background: var(--bg-card);
            border: 1px solid var(--border);
            padding: 25px 30px;
            border-radius: 16px;
            margin-bottom: 30px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            animation: slideUp 0.5s ease backwards;
            animation-delay: 0.1s;
        }
        
        @keyframes slideUp {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }
        
        .customer-name { 
            font-size: 1.4em; 
            font-weight: 700; 
            color: var(--text-primary);
            margin-bottom: 5px;
        }
        
        .customer-email { color: var(--text-secondary); font-size: 0.95em; }
        
        .order-count {
            background: var(--gradient-accent);
            color: var(--bg-primary);
            padding: 12px 24px;
            border-radius: 50px;
            font-weight: 700;
            font-size: 1em;
        }
        
        .orders-list { margin-bottom: 30px; }
        
        .order-card {
            background: var(--bg-card);
            border: 1px solid var(--border);
            border-radius: 16px;
            margin-bottom: 20px;
            overflow: hidden;
            transition: all 0.4s cubic-bezier(0.16, 1, 0.3, 1);
            animation: slideUp 0.5s ease backwards;
        }
        
        .order-card:nth-child(1) { animation-delay: 0.15s; }
        .order-card:nth-child(2) { animation-delay: 0.2s; }
        .order-card:nth-child(3) { animation-delay: 0.25s; }
        .order-card:nth-child(4) { animation-delay: 0.3s; }
        .order-card:nth-child(5) { animation-delay: 0.35s; }
        
        .order-card:hover {
            border-color: var(--accent);
            box-shadow: 0 10px 40px rgba(0, 212, 255, 0.15);
            transform: translateY(-3px);
        }
        
        .order-header {
            background: var(--bg-tertiary);
            color: var(--text-primary);
            padding: 20px 25px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            cursor: pointer;
            border-bottom: 1px solid var(--border);
            transition: all 0.3s ease;
        }
        
        .order-header:hover {
            background: var(--bg-hover);
        }
        
        .order-id { 
            font-size: 1.2em; 
            font-weight: 700;
            color: var(--accent);
        }
        
        .order-date { 
            font-size: 0.9em; 
            color: var(--text-secondary);
            margin-top: 5px;
        }
        
        .order-status {
            padding: 8px 18px;
            border-radius: 50px;
            font-size: 0.8em;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        
        .status-confirmed { 
            background: rgba(0, 255, 136, 0.15); 
            color: var(--success);
            border: 1px solid rgba(0, 255, 136, 0.3);
        }
        
        .status-pending { 
            background: rgba(255, 170, 0, 0.15); 
            color: var(--warning);
            border: 1px solid rgba(255, 170, 0, 0.3);
        }
        
        .status-cancelled { 
            background: rgba(255, 71, 87, 0.15); 
            color: var(--danger);
            border: 1px solid rgba(255, 71, 87, 0.3);
        }
        
        .order-body { 
            padding: 25px;
            background: var(--bg-card);
        }
        
        .order-items { margin-bottom: 20px; }
        
        .order-items h4 { 
            color: var(--text-secondary); 
            margin-bottom: 15px; 
            font-size: 1em;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        
        .item-row {
            display: flex;
            justify-content: space-between;
            padding: 15px 18px;
            background: var(--bg-tertiary);
            border: 1px solid var(--border);
            border-radius: 10px;
            margin-bottom: 10px;
            transition: all 0.3s ease;
        }
        
        .item-row:hover {
            border-color: var(--border-hover);
            background: var(--bg-hover);
        }
        
        .item-name { font-weight: 600; color: var(--text-primary); }
        .item-details { color: var(--text-secondary); font-size: 0.9em; margin-top: 4px; }
        .item-price { font-weight: 700; color: var(--accent); font-size: 1.1em; }
        
        .order-total {
            display: flex;
            justify-content: space-between;
            padding: 18px 20px;
            background: var(--bg-tertiary);
            border: 1px solid var(--border);
            border-radius: 10px;
            font-size: 1.2em;
            font-weight: 700;
        }
        
        .order-total span:first-child { color: var(--text-secondary); }
        .order-total span:last-child { 
            color: var(--accent);
            text-shadow: 0 0 20px var(--accent-glow);
        }
        
        .empty-orders { 
            text-align: center; 
            padding: 80px 20px; 
            color: var(--text-secondary);
            animation: slideUp 0.5s ease backwards;
            animation-delay: 0.15s;
        }
        
        .empty-orders .icon { 
            font-size: 100px; 
            margin-bottom: 25px;
            filter: drop-shadow(0 0 30px var(--accent-glow));
        }
        
        .empty-orders h2 { color: var(--text-primary); margin-bottom: 15px; font-size: 1.8em; }
        .empty-orders p { font-size: 1.1em; }
        
        .button-group { 
            display: flex; 
            gap: 20px; 
            margin-top: 35px;
            animation: slideUp 0.5s ease backwards;
            animation-delay: 0.3s;
        }
        
        .btn {
            flex: 1;
            padding: 18px 24px;
            border: 1px solid var(--border);
            border-radius: 14px;
            font-size: 1em;
            font-weight: 600;
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
            position: relative;
            overflow: hidden;
        }
        
        .btn::before {
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
        
        .btn:hover {
            border-color: var(--accent);
            transform: translateY(-3px);
            box-shadow: 0 10px 30px rgba(0, 212, 255, 0.2);
            color: var(--bg-primary);
        }
        
        .btn:hover::before { left: 0; }
        
        .btn-secondary { 
            background: var(--gradient-accent);
            color: var(--bg-primary);
            border-color: transparent;
        }
        
        .btn-secondary::before {
            background: linear-gradient(135deg, #00ff88 0%, #00d4ff 100%);
        }
        
        .error-message {
            background: rgba(255, 71, 87, 0.1);
            color: var(--danger);
            padding: 30px;
            border-radius: 16px;
            text-align: center;
            margin: 30px 0;
            border: 1px solid rgba(255, 71, 87, 0.3);
        }
        
        .error-message h2 { margin-bottom: 10px; }
        .error-message p { color: var(--text-secondary); }
        
        .toggle-icon {
            color: var(--accent);
            font-size: 1.2em;
            transition: transform 0.3s ease;
        }
        
        .toggle-icon.open {
            transform: rotate(180deg);
        }
        
        ::-webkit-scrollbar { width: 10px; }
        ::-webkit-scrollbar-track { background: var(--bg-primary); }
        ::-webkit-scrollbar-thumb { background: var(--bg-hover); border-radius: 5px; }
        
        @media (max-width: 768px) {
            .container { padding: 25px; }
            .customer-info { flex-direction: column; gap: 15px; text-align: center; }
            .button-group { flex-direction: column; }
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
                                        String itemname = item.optString("name", "Product #" + item.optInt("product_id", 0));
                            %>
                            <div class="item-row">
                                <div>
                                    <div class="item-name"><%= item.optString("name", "Product #" + item.optInt("product_id", 0)) %></div>
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
