<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="org.json.*" %>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Profile - E-Commerce Store</title>
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
        header {
            text-align: center;
            margin-bottom: 30px;
            padding-bottom: 20px;
            border-bottom: 3px solid #667eea;
        }
        h1 { color: #333; font-size: 2.2em; margin-bottom: 10px; }
        .subtitle { color: #666; font-size: 1.1em; }
        .profile-icon { font-size: 80px; text-align: center; margin-bottom: 20px; }
        .profile-card {
            background: #f8f9fa;
            border-radius: 10px;
            padding: 30px;
            margin-bottom: 25px;
        }
        .profile-card h2 {
            color: #333;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 2px solid #e0e0e0;
        }
        .info-row {
            display: flex;
            padding: 15px 0;
            border-bottom: 1px solid #e0e0e0;
        }
        .info-row:last-child { border-bottom: none; }
        .info-label {
            font-weight: bold;
            color: #333;
            min-width: 150px;
            font-size: 1.1em;
        }
        .info-value { color: #666; font-size: 1.1em; flex: 1; }
        .loyalty-section {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-radius: 10px;
            padding: 30px;
            text-align: center;
            margin-bottom: 25px;
        }
        .loyalty-section h2 { margin-bottom: 15px; font-size: 1.5em; }
        .loyalty-points { font-size: 3em; font-weight: bold; margin: 15px 0; }
        .loyalty-label { font-size: 1.1em; opacity: 0.9; }
        .loyalty-badge {
            display: inline-block;
            background: rgba(255, 255, 255, 0.2);
            padding: 10px 20px;
            border-radius: 20px;
            margin-top: 15px;
            font-weight: bold;
        }
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
            <h1>👤 My Profile</h1>
            <p class="subtitle">View Your Account Details</p>
        </header>

        <%
            // Get data passed from ProfileServlet
            String customerId = (String) request.getAttribute("customerId");
            String customerDataJson = (String) request.getAttribute("customerData");
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
            } else if (customerId == null || customerDataJson == null) {
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
                // Parse customer data
                JSONObject customerData = new JSONObject(customerDataJson);
                int loyaltyPoints = customerData.optInt("loyalty_points", 0);
                
                // Determine loyalty tier
                String loyaltyTier = "Bronze";
                if (loyaltyPoints >= 1000) {
                    loyaltyTier = "Gold";
                } else if (loyaltyPoints >= 500) {
                    loyaltyTier = "Silver";
                }
        %>
        
        <div class="profile-icon">👤</div>

        <!-- Loyalty Points Section -->
        <div class="loyalty-section">
            <h2>⭐ Loyalty Program</h2>
            <div class="loyalty-points"><%= loyaltyPoints %></div>
            <div class="loyalty-label">Loyalty Points</div>
            <div class="loyalty-badge"><%= loyaltyTier %> Member</div>
        </div>

        <!-- Profile Information -->
        <div class="profile-card">
            <h2>📋 Account Information</h2>

            <div class="info-row">
                <span class="info-label">Customer ID:</span>
                <span class="info-value">#<%= customerData.getInt("customer_id") %></span>
            </div>

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
                <span class="info-value"><%= customerData.optString("phone", "Not provided") %></span>
            </div>

            <div class="info-row">
                <span class="info-label">Address:</span>
                <span class="info-value"><%= customerData.optString("address", "Not provided") %></span>
            </div>
        </div>

        <!-- Navigation Buttons -->
        <form id="ordersForm" action="OrdersHistoryServlet" method="GET">
            <input type="hidden" name="customerId" value="<%= customerId %>">
        </form>
        
        <div class="button-group">
            <a href="index.jsp" class="btn btn-primary">← Back to Store</a>
            <button type="button" class="btn btn-secondary" onclick="document.getElementById('ordersForm').submit()">📋 View Orders History</button>
        </div>
        
        <% } %>
    </div>
</body>

</html>
