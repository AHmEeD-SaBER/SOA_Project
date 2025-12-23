<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="org.json.*" %>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Profile - E-Commerce Store</title>
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
                radial-gradient(ellipse at 80% 80%, rgba(0, 255, 136, 0.05) 0%, transparent 50%);
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
                0 0 100px rgba(0, 212, 255, 0.05);
            padding: 50px;
            animation: containerFadeIn 0.8s cubic-bezier(0.16, 1, 0.3, 1);
            backdrop-filter: blur(20px);
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
            letter-spacing: -0.02em;
            background: linear-gradient(135deg, #ffffff 0%, #a0a0a0 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }
        
        .subtitle { 
            color: var(--text-secondary); 
            font-size: 1.1em;
            font-weight: 400;
            letter-spacing: 0.5px;
        }
        
        .profile-icon { 
            text-align: center; 
            margin: 30px 0;
            animation: float 3s ease-in-out infinite;
            filter: drop-shadow(0 10px 30px var(--accent-glow));
        }
        .profile-name{
            font-size: 3.5em;
            color: aqua;
            font-weight: 800;
        }
        
        @keyframes float {
            0%, 100% { transform: translateY(0); }
            50% { transform: translateY(-10px); }
        }
        
        .profile-card {
            background: var(--bg-card);
            border: 1px solid var(--border);
            border-radius: 20px;
            padding: 35px;
            margin-bottom: 30px;
            transition: all 0.4s cubic-bezier(0.16, 1, 0.3, 1);
            animation: slideUp 0.6s cubic-bezier(0.16, 1, 0.3, 1) backwards;
            animation-delay: 0.2s;
        }
        
        .profile-card:hover {
            border-color: var(--border-hover);
            box-shadow: 0 15px 40px rgba(0, 0, 0, 0.3);
            transform: translateY(-5px);
        }
        
        @keyframes slideUp {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }
        
        .profile-card h2 {
            color: var(--text-primary);
            margin-bottom: 25px;
            padding-bottom: 15px;
            border-bottom: 1px solid var(--border);
            font-size: 1.4em;
            font-weight: 700;
            display: flex;
            align-items: center;
            gap: 12px;
        }
        
        .info-row {
            display: flex;
            align-items: center;
            padding: 18px 0;
            border-bottom: 1px solid var(--border);
            transition: all 0.3s ease;
        }
        
        .info-row:hover {
            background: var(--bg-tertiary);
            margin: 0 -20px;
            padding: 18px 20px;
            border-radius: 10px;
        }
        
        .info-row:last-child { border-bottom: none; }
        
        .info-label {
            font-weight: 600;
            color: var(--text-secondary);
            min-width: 160px;
            font-size: 0.95em;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        
        .info-value { 
            color: var(--text-primary); 
            font-size: 1.1em; 
            flex: 1;
            font-weight: 500;
        }
        
        .loyalty-section {
            background: var(--bg-card);
            border: 1px solid var(--border);
            border-radius: 20px;
            padding: 40px;
            text-align: center;
            margin-bottom: 30px;
            position: relative;
            overflow: hidden;
            animation: slideUp 0.6s cubic-bezier(0.16, 1, 0.3, 1) backwards;
            animation-delay: 0.1s;
        }
        
        .loyalty-section::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 4px;
            background: var(--gradient-accent);
        }
        
        .loyalty-section::after {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: radial-gradient(ellipse at 50% 0%, var(--accent-glow) 0%, transparent 60%);
            pointer-events: none;
        }
        
        .loyalty-section h2 { 
            margin-bottom: 20px; 
            font-size: 1.3em;
            color: var(--text-secondary);
            font-weight: 600;
            position: relative;
            z-index: 1;
        }
        
        .loyalty-points { 
            font-size: 5em; 
            font-weight: 800; 
            margin: 20px 0;
            background: var(--gradient-accent);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            text-shadow: 0 0 60px var(--accent-glow);
            position: relative;
            z-index: 1;
            animation: glow 2s ease-in-out infinite alternate;
        }
        
        @keyframes glow {
            from { filter: drop-shadow(0 0 20px var(--accent-glow)); }
            to { filter: drop-shadow(0 0 40px var(--accent-glow)); }
        }
        
        .loyalty-label { 
            font-size: 1.1em; 
            color: var(--text-secondary);
            font-weight: 500;
            position: relative;
            z-index: 1;
        }
        
        .loyalty-badge {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            background: var(--bg-tertiary);
            border: 1px solid var(--border);
            padding: 14px 28px;
            border-radius: 50px;
            margin-top: 25px;
            font-weight: 700;
            font-size: 1.1em;
            color: var(--accent);
            position: relative;
            z-index: 1;
            transition: all 0.3s ease;
        }
        
        .loyalty-badge:hover {
            border-color: var(--accent);
            box-shadow: 0 0 30px var(--accent-glow);
            transform: scale(1.05);
        }
        
        .loyalty-badge::before {
            content: '👑';
            font-size: 1.2em;
        }
        
        .button-group { 
            display: flex; 
            gap: 20px; 
            margin-top: 35px;
            animation: slideUp 0.6s cubic-bezier(0.16, 1, 0.3, 1) backwards;
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
            position: relative;
            overflow: hidden;
            background: var(--bg-tertiary);
            color: var(--text-primary);
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
        
        .btn:hover::before {
            left: 0;
        }
        
        .btn-primary {
            background: var(--bg-tertiary);
        }
        
        .btn-secondary { 
            background: var(--gradient-accent);
            color: var(--bg-primary);
            border-color: transparent;
        }
        
        .btn-secondary::before {
            background: linear-gradient(135deg, #00ff88 0%, #00d4ff 100%);
        }
        
        .btn-secondary:hover { 
            box-shadow: 0 10px 30px rgba(0, 255, 136, 0.3);
            color: var(--bg-primary);
        }
        
        .error-message {
            background: rgba(255, 71, 87, 0.1);
            color: var(--danger);
            padding: 30px;
            border-radius: 16px;
            text-align: center;
            margin: 30px 0;
            border: 1px solid rgba(255, 71, 87, 0.3);
            animation: shake 0.5s ease-in-out;
        }
        
        .error-message h2 {
            margin-bottom: 10px;
            font-size: 1.5em;
        }
        
        .error-message p {
            color: var(--text-secondary);
            font-size: 1.1em;
        }
        
        @keyframes shake {
            0%, 100% { transform: translateX(0); }
            20%, 60% { transform: translateX(-5px); }
            40%, 80% { transform: translateX(5px); }
        }
        
        /* Stats Grid */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 20px;
            margin-bottom: 30px;
            animation: slideUp 0.6s cubic-bezier(0.16, 1, 0.3, 1) backwards;
            animation-delay: 0.15s;
        }
        
        .stat-card {
            background: var(--bg-card);
            border: 1px solid var(--border);
            border-radius: 16px;
            padding: 25px;
            text-align: center;
            transition: all 0.3s ease;
        }
        
        .stat-card:hover {
            border-color: var(--accent);
            transform: translateY(-5px);
            box-shadow: 0 10px 30px rgba(0, 212, 255, 0.1);
        }
        
        .stat-icon {
            font-size: 2em;
            margin-bottom: 12px;
        }
        
        .stat-value {
            font-size: 1.8em;
            font-weight: 700;
            color: var(--text-primary);
            margin-bottom: 5px;
        }
        
        .stat-label {
            font-size: 0.85em;
            color: var(--text-muted);
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        
        /* Scrollbar */
        ::-webkit-scrollbar { width: 10px; }
        ::-webkit-scrollbar-track { background: var(--bg-primary); }
        ::-webkit-scrollbar-thumb { background: var(--bg-hover); border-radius: 5px; }
        ::-webkit-scrollbar-thumb:hover { background: var(--border-hover); }
        
        ::selection { background: var(--accent); color: var(--bg-primary); }
        
        @media (max-width: 768px) {
            .container { padding: 25px; }
            .stats-grid { grid-template-columns: 1fr; }
            .button-group { flex-direction: column; }
            .info-row { flex-direction: column; gap: 8px; }
            .info-label { min-width: auto; }
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
        
        <div class="profile-icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" fill="var(--accent)" viewBox="0 0 24 24"><path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/></svg>
            
        <h2 class ="profile-name"><%= customerData.optString("name", "User") %></h2>
        </div>

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
            <button type="button" class="btn btn-secondary" 
        onclick="window.location.href='NotificationHistoryServlet?customerId=<%= customerId %>'">
    🔔 View Notifications
</button>
        </div>
        
        <% } %>
    </div>
</body>

</html>
