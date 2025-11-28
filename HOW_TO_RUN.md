# 🚀 HOW TO RUN - E-Commerce Order Management System

## Complete Step-by-Step Guide

---

## Prerequisites

Before you start, make sure you have these installed:

1. **Python 3.8 or higher**
   - Check: `python --version`
   - Download: https://www.python.org/downloads/

2. **MySQL 8.0**
   - Check: `mysql --version`
   - Download: https://dev.mysql.com/downloads/mysql/

3. **Git** (if cloning from repository)
   - Check: `git --version`
   - Download: https://git-scm.com/downloads/

---

## Step 1: Get the Project Files

### Option A: Clone from GitHub
```powershell
git clone https://github.com/AHmEeD-SaBER/SOA_Project.git
cd SOA_Project
```

### Option B: Already have the files?
Just navigate to the project folder:
```powershell
cd f:\COURSES\SOA\Projects\E_Commerce
```

---

## Step 2: Setup MySQL Database

### 2.1 Start MySQL Service
```powershell
# Check if MySQL is running
Get-Service -Name MySQL*

# If not running, start it
Start-Service -Name MySQL80
```

### 2.2 Run the Database Setup Script
```powershell
# Method 1: Using PowerShell (Recommended)
Get-Content database_setup.sql | mysql -u root -p
# Enter your MySQL root password when prompted
```

Or:

```powershell
# Method 2: Using MySQL Workbench
# 1. Open MySQL Workbench
# 2. Connect to your MySQL server
# 3. File -> Open SQL Script -> Select database_setup.sql
# 4. Click Execute (⚡ icon)
```

Or:

```powershell
# Method 3: MySQL Command Line
mysql -u root -p
# Then inside MySQL prompt:
source f:/COURSES/SOA/Projects/E_Commerce/database_setup.sql
```

### 2.3 Verify Database Setup
```sql
-- Login to MySQL
mysql -u root -p

-- Check database
USE ecommerce_system;
SHOW TABLES;

-- Should show:
-- customers
-- inventory
-- notification_log
-- order_items
-- orders
-- pricing_rules
-- tax_rates

-- Check sample data
SELECT COUNT(*) FROM inventory;    -- Should be 10
SELECT COUNT(*) FROM customers;    -- Should be 10

-- Exit MySQL
EXIT;
```

**✅ Database is ready!**

---

## Step 3: Install Python Dependencies

```powershell
# Make sure you're in the project directory
cd f:\COURSES\SOA\Projects\E_Commerce

# Install all required packages
pip install Flask Flask-CORS mysql-connector-python requests

# Or use requirements.txt if available
pip install -r requirements.txt

# Verify installation
pip list | Select-String "Flask|mysql|requests"
```

**Expected output:**
```
Flask                    3.0.0
Flask-Cors               4.0.0
mysql-connector-python   8.2.0
requests                 2.31.0
```

**✅ Python packages installed!**

---

## Step 4: Start All Microservices

You need to start **5 services**. Each runs in a separate terminal.

### Method A: Start All at Once (Recommended)

```powershell
# Run this command - it will open 5 terminals automatically
.\start_all.ps1
```

### Method B: Start Services Manually

**Open 5 separate PowerShell terminals and run:**

#### Terminal 1 - Order Service
```powershell
cd f:\COURSES\SOA\Projects\E_Commerce\order_service
python app.py
```
✅ **Expected**: `Starting Order Service on port 5001...`

#### Terminal 2 - Inventory Service
```powershell
cd f:\COURSES\SOA\Projects\E_Commerce\inventory_service
python app.py
```
✅ **Expected**: `Starting Inventory Service on port 5002...`

#### Terminal 3 - Pricing Service
```powershell
cd f:\COURSES\SOA\Projects\E_Commerce\pricing_service
python app.py
```
✅ **Expected**: `Starting Pricing Service on port 5003...`

#### Terminal 4 - Customer Service
```powershell
cd f:\COURSES\SOA\Projects\E_Commerce\customer_service
python app.py
```
✅ **Expected**: `Starting Customer Service on port 5004...`

#### Terminal 5 - Notification Service
```powershell
cd f:\COURSES\SOA\Projects\E_Commerce\notification_service
python app.py
```
✅ **Expected**: `Starting Notification Service on port 5005...`

**✅ All services running!**

---

## Step 5: Verify Services are Running

Open a **NEW PowerShell terminal** and run:

```powershell
cd f:\COURSES\SOA\Projects\E_Commerce
python test_connectivity.py
```

**Expected Output:**
```
Testing connectivity to all services...

Order Service (5001): ✓ OK (Status: 200)
Inventory Service (5002): ✓ OK (Status: 200)
Pricing Service (5003): ✓ OK (Status: 200)
Customer Service (5004): ✓ OK (Status: 200)
Notification Service (5005): ✓ OK (Status: 200)

All services are running successfully!
```

**✅ Services verified!**

---

## Step 6: Test Backend APIs (Optional but Recommended)

### Test Inventory Service
```powershell
# Get all products
Invoke-RestMethod -Uri "http://localhost:5002/api/inventory/products" -Method GET | ConvertTo-Json
```

### Test Customer Service
```powershell
# Get customer details
Invoke-RestMethod -Uri "http://localhost:5004/api/customers/1" -Method GET | ConvertTo-Json
```

### Test Create Order
```powershell
$orderData = @{
    customer_id = 1
    products = @(
        @{ product_id = 1; quantity = 2 }
    )
    total_amount = 1999.98
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:5001/api/orders/create" -Method POST -Body $orderData -ContentType "application/json" | ConvertTo-Json
```

**✅ APIs working!**

---

## Step 7: Access the Web Application (JSP Frontend)

### Option A: Direct Access (If already deployed)
Open your browser and go to:
```
http://localhost:8080/jsp_frontend/index.jsp
```

### Option B: Deploy to Tomcat First

If you haven't deployed yet:

1. **Make sure Tomcat is installed and running**
   ```powershell
   # Start Tomcat (adjust path to your Tomcat installation)
   C:\apache-tomcat-10.x\bin\startup.bat
   ```

2. **Deploy the JSP application**
   - Copy the `jsp_frontend` folder to Tomcat's webapps directory
   ```powershell
   Copy-Item -Path "f:\COURSES\SOA\Projects\E_Commerce\jsp_frontend" -Destination "C:\apache-tomcat-10.x\webapps\" -Recurse -Force
   ```

3. **Access the application**
   - Wait a few seconds for Tomcat to deploy
   - Open browser: http://localhost:8080/jsp_frontend/index.jsp

**✅ Web application is running!**

---

## Step 8: Use the Application

### 8.1 Browse Products (index.jsp)
1. Open: http://localhost:8080/jsp_frontend/index.jsp
2. You'll see 10 products displayed from the database
3. Select a customer from the dropdown (e.g., "Ahmed Hassan")

### 8.2 Add Products to Cart
1. Choose quantity for any product
2. Click **"Add to Cart"**
3. Repeat for multiple products
4. View your cart at the bottom

### 8.3 Checkout
1. Click **"Proceed to Checkout"**
2. Review your order details
3. See pricing breakdown with discounts and taxes
4. Click **"Place Order"**

### 8.4 View Confirmation
1. See your order confirmation with order number
2. Check the terminal running Notification Service - you'll see the email simulation!
3. Print receipt or continue shopping

---

## 🎉 Complete! Your System is Running!

### What's Happening Behind the Scenes:

```
When you place an order:
1. JSP → Order Service → Stores order in MySQL database
2. JSP → Inventory Service → Updates stock in MySQL
3. JSP → Notification Service → 
   - Calls Order Service (gets order from MySQL)
   - Calls Customer Service (gets customer from MySQL)
   - Calls Inventory Service (gets products from MySQL)
   - Logs notification to MySQL
   - Prints email to console
```

---

## 📊 Database Tables Being Used

All services now use MySQL database:

| Service              | Database Tables Used                      |
| -------------------- | ----------------------------------------- |
| Order Service        | `orders`, `order_items`, `inventory`      |
| Inventory Service    | `inventory`                               |
| Pricing Service      | `pricing_rules`, `tax_rates`, `inventory` |
| Customer Service     | `customers`                               |
| Notification Service | `notification_log`                        |

---

## 🔍 View Your Data

Check what's stored in the database:

```sql
-- View all orders
SELECT * FROM orders ORDER BY created_at DESC;

-- View order details with items
SELECT o.order_id, o.customer_id, c.name, o.total_amount, o.status, o.created_at
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
ORDER BY o.created_at DESC;

-- View order items
SELECT oi.order_id, i.product_name, oi.quantity, oi.unit_price
FROM order_items oi
JOIN inventory i ON oi.product_id = i.product_id;

-- View inventory levels
SELECT product_name, quantity_available, unit_price 
FROM inventory 
ORDER BY quantity_available ASC;

-- View customers
SELECT name, email, loyalty_points FROM customers;

-- View notifications sent
SELECT * FROM notification_log ORDER BY sent_at DESC;
```

---

## 🛑 How to Stop Everything

### Stop Services
- Press `Ctrl+C` in each terminal window running a service

### Stop Tomcat
```powershell
C:\apache-tomcat-10.x\bin\shutdown.bat
```

### Stop MySQL (Optional)
```powershell
Stop-Service -Name MySQL80
```

---

## ⚠️ Troubleshooting

### Problem: "Port already in use"
```powershell
# Check what's using the port
netstat -ano | findstr ":5001"

# Kill the process (replace PID with actual process ID)
taskkill /PID <PID> /F
```

### Problem: "Database connection failed"
1. Check MySQL is running: `Get-Service -Name MySQL*`
2. Start MySQL: `Start-Service -Name MySQL80`
3. Verify credentials in service files (user: `ecommerce_user`, password: `secure_password`)

### Problem: "Module not found"
```powershell
# Reinstall Python packages
pip install Flask Flask-CORS mysql-connector-python requests --force-reinstall
```

### Problem: "Can't access JSP pages"
1. Check Tomcat is running: http://localhost:8080
2. Check Tomcat logs: `C:\apache-tomcat-10.x\logs\catalina.out`
3. Redeploy the jsp_frontend folder

### Problem: "Products not loading"
1. Check Inventory Service is running (port 5002)
2. Test: `Invoke-RestMethod -Uri "http://localhost:5002/api/inventory/products" -Method GET`
3. Check database has data: `SELECT * FROM inventory;`

---

## 📝 Quick Command Reference

```powershell
# Start all services
.\start_all.ps1

# Test connectivity
python test_connectivity.py

# Check MySQL
Get-Service -Name MySQL*

# View running services
netstat -ano | findstr "5001 5002 5003 5004 5005"

# Access web application
# Browser: http://localhost:8080/jsp_frontend/index.jsp
```

---

## 🎯 What Each Service Does

1. **Order Service (5001)** - Stores orders in database (orders & order_items tables)
2. **Inventory Service (5002)** - Manages products and stock (inventory table)
3. **Pricing Service (5003)** - Calculates prices with discounts (pricing_rules & tax_rates tables)
4. **Customer Service (5004)** - Manages customers (customers table)
5. **Notification Service (5005)** - Sends notifications (notification_log table)
6. **JSP Frontend (8080)** - Web interface that calls all services

---

## ✅ Success Checklist

- [ ] MySQL database created and populated
- [ ] Python packages installed
- [ ] 5 Flask services running (ports 5001-5005)
- [ ] Connectivity test passed
- [ ] Tomcat running (port 8080)
- [ ] JSP application deployed
- [ ] Can browse products on web page
- [ ] Can place test order
- [ ] Order stored in database
- [ ] Notification printed to console

---

## 🎓 You're All Set!

Your complete microservices E-Commerce system is now running with:
- ✅ 5 Python Flask microservices
- ✅ MySQL database integration (ALL services use database)
- ✅ Java JSP frontend
- ✅ RESTful APIs with JSON
- ✅ Inter-service communication
- ✅ Complete order management workflow

**Enjoy testing your SOA project!** 🚀

---

**Need Help?** Run `python test_connectivity.py` to diagnose issues.

**Last Updated**: November 2025
