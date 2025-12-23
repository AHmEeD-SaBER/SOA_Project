<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="org.json.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Notifications - E-Commerce Store</title>
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
            --accent: #00d4ff;
            --accent-glow: rgba(0, 212, 255, 0.3);
            --border: #2a2a2a;
            --gradient-accent: linear-gradient(135deg, #00d4ff 0%, #00ff88 100%);
        }

        body {
            font-family: 'Inter', sans-serif;
            background: var(--bg-primary);
            color: var(--text-primary);
            min-height: 100vh;
            padding: 20px;
            overflow-x: hidden;
        }

        body::before {
            content: '';
            position: fixed;
            top: 0; left: 0; right: 0; bottom: 0;
            background: 
                radial-gradient(ellipse at 20% 20%, rgba(0, 212, 255, 0.08) 0%, transparent 50%),
                radial-gradient(ellipse at 80% 80%, rgba(0, 255, 136, 0.05) 0%, transparent 50%);
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
                0 25px 50px -12px rgba(0,0,0,0.8),
                0 0 100px rgba(0,212,255,0.05);
            padding: 40px;
            backdrop-filter: blur(20px);
            animation: containerFadeIn 0.8s cubic-bezier(0.16, 1, 0.3, 1);
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
            animation: titleGlow 3s ease-in-out infinite alternate;
        }

        @keyframes titleGlow {
            from { filter: drop-shadow(0 0 20px rgba(0,212,255,0.2)); }
            to { filter: drop-shadow(0 0 30px rgba(0,212,255,0.4)); }
        }

        .subtitle {
            color: var(--text-secondary);
            font-size: 1.1em;
            font-weight: 400;
            letter-spacing: 0.5px;
        }

        .notification-card {
            background: var(--bg-card);
            border: 1px solid var(--border);
            border-radius: 16px;
            padding: 24px;
            margin-bottom: 20px;
            transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1);
        }

        .notification-card:hover {
            border-color: var(--accent);
            box-shadow: 
                0 20px 40px rgba(0,0,0,0.4),
                0 0 40px var(--accent-glow);
            transform: translateY(-5px) scale(1.01);
        }

        .notification-date {
            color: var(--text-secondary);
            font-size: 0.9em;
            margin-bottom: 8px;
        }

        .notification-type {
            font-weight: 600;
            color: var(--accent);
            margin-bottom: 12px;
        }

        .notification-message {
            white-space: pre-wrap;
            line-height: 1.6;
            color: var(--text-primary);
        }

        .order-link {
            margin-top: 12px;
            font-size: 0.95em;
            color: var(--text-secondary);
        }

        .error-message {
            background: rgba(255, 71, 87, 0.1);
            color: #ff4757;
            padding: 18px 24px;
            border-radius: 12px;
            margin-bottom: 24px;
            border: 1px solid rgba(255,71,87,0.3);
            backdrop-filter: blur(10px);
            animation: shake 0.5s ease-in-out;
        }

        @keyframes shake {
            0%, 100% { transform: translateX(0); }
            20%, 60% { transform: translateX(-5px); }
            40%, 80% { transform: translateX(5px); }
        }

        .button-group {
            display: flex;
            gap: 20px;
            margin-top: 30px;
        }

        .button-group a {
            display: inline-block;
            padding: 14px 28px;
            border-radius: 12px;
            text-decoration: none;
            font-weight: 600;
            background: var(--bg-tertiary);
            border: 1px solid var(--border);
            color: var(--text-primary);
            transition: all 0.3s ease;
        }

        .button-group a:hover {
            border-color: var(--accent);
            box-shadow: 0 8px 32px rgba(0,212,255,0.2);
            transform: translateY(-2px);
        }

        .empty-state {
            text-align: center;
            padding: 60px 20px;
            color: var(--text-secondary);
        }

        .customer-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
            flex-wrap: wrap;
        }

        .customer-header h2 {
            font-size: 1.5em;
            color: var(--text-primary);
        }

        .badge {
            background: var(--bg-tertiary);
            color: var(--accent);
            font-weight: 600;
            padding: 6px 14px;
            border-radius: 12px;
            border: 1px solid var(--border);
        }

        @media (max-width: 768px) {
            .container { padding: 20px; }
            h1 { font-size: 2em; }
            .customer-header { flex-direction: column; align-items: flex-start; gap: 12px; }
            .button-group { flex-direction: column; gap: 12px; }
        }
    </style>
</head>
<body>
<div class="container">
    <header>
        <h1>🔔 Notifications</h1>
        <p class="subtitle">Your recent updates and order confirmations</p>
    </header>

    <%
        String customerId = (String) request.getAttribute("customerId");
        String notificationsJson = (String) request.getAttribute("notifications");
        String customerName = (String) request.getAttribute("customerName");
        int count = (Integer) request.getAttribute("notificationCount");
        String error = (String) request.getAttribute("error");

        if (error != null) {
    %>
        <div class="error-message">
            <strong>Error:</strong> <%= error %>
        </div>
    <%
        } else if (notificationsJson == null || count == 0) {
    %>
        <div class="empty-state">
            <h2>No notifications yet</h2>
            <p>You'll see order confirmations and updates here.</p>
        </div>
    <%
        } else {
            JSONArray notifications = new JSONArray(notificationsJson);
    %>
        <div class="customer-header">
            <h2>👤 <%= customerName %> (ID: #<%= customerId %>)</h2>
            <span class="badge"><%= count %> notification<%= count != 1 ? "s" : "" %></span>
        </div>

        <% for (int i = 0; i < notifications.length(); i++) { 
            JSONObject n = notifications.getJSONObject(i);
            String sentAt = n.optString("sent_at", "N/A");
        %>
        <div class="notification-card">
            <div class="notification-date"><%= sentAt %></div>
            <div class="notification-type"><%= n.optString("notification_type").replace("_", " ").toUpperCase() %></div>
            <div class="notification-message"><%= n.optString("message") %></div>
            <div class="order-link">
                Order #<%= n.optInt("order_id") %>
            </div>
        </div>
        <% } %>
    <% } %>

    <div class="button-group">
        <a href="index.jsp">← Back to Store</a>
        <a href="profile.jsp">Back to Profile</a>
    </div>
</div>
</body>
</html>
