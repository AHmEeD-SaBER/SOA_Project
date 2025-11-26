# E-Commerce Order Management System

A microservices-based e-commerce order management system built with **Flask** (Python) backend and **JSP** (Java) frontend.

## 🏗️ Architecture

This project implements a Service-Oriented Architecture (SOA) with:
- **5 Independent Flask Microservices** (Backend)
- **1 Java JSP Application** (Frontend/API Gateway)
- **MySQL Database** for data persistence

## 📦 Services

| Service              | Port | Description                          | Database |
| -------------------- | ---- | ------------------------------------ | -------- |
| Order Service        | 5001 | Handles order creation and retrieval | No       |
| Inventory Service    | 5002 | Manages product inventory and stock  | Yes      |
| Pricing Service      | 5003 | Calculates pricing and discounts     | Yes      |
| Customer Service     | 5004 | Manages customer profiles and data   | Yes      |
| Notification Service | 5005 | Sends order notifications            | Yes      |
| JSP Frontend         | 8080 | Web interface and API gateway        | No       |

## 🚀 Quick Start

### Prerequisites
- Python 3.8+
- MySQL 8.0
- Java JDK 11+
- Apache Tomcat 10.x

### Installation

1. Clone the repository:
```bash
git clone https://github.com/AHmEeD-SaBER/SOA_Project.git
cd SOA_Project
```

2. Set up MySQL database:
```sql
CREATE DATABASE ecommerce_system;
CREATE USER 'ecommerce_user'@'localhost' IDENTIFIED BY 'secure_password';
GRANT SELECT, INSERT, UPDATE ON ecommerce_system.* TO 'ecommerce_user'@'localhost';
FLUSH PRIVILEGES;
```

3. Run the database setup script (import tables and sample data)

### Running the Services

**Option 1: All services at once (PowerShell)**
```powershell
.\start_all.ps1
```

**Option 2: Individual services**
```powershell
cd order_service
.\venv\Scripts\Activate.ps1
python app.py
```

Repeat for each service (inventory_service, pricing_service, customer_service, notification_service)

### Testing

Run the connectivity test:
```powershell
python test_connectivity.py
```

## 📁 Project Structure

```
E_Commerce/
├── order_service/          # Order management microservice
├── inventory_service/      # Inventory management microservice
├── pricing_service/        # Pricing calculation microservice
├── customer_service/       # Customer management microservice
├── notification_service/   # Notification microservice
├── jsp_frontend/           # Java JSP web application
├── test_connectivity.py    # Service connectivity test script
├── start_all.ps1          # Script to start all services
└── README.md
```

## 🛠️ Technologies

- **Backend**: Python Flask, Flask-CORS
- **Frontend**: Java JSP, Jakarta EE
- **Database**: MySQL 8.0
- **Communication**: REST APIs with JSON
- **Tools**: mysql-connector-python, requests

## 📝 Assignment Context

This project is part of a Service-Oriented Architecture (SOA) course assignment, implementing:
- Microservices design patterns
- RESTful API development
- Inter-service communication
- Database integration
- Service orchestration

## 👥 Author

Ahmed Saber - [GitHub](https://github.com/AHmEeD-SaBER)

## 📄 License

This project is for educational purposes as part of an SOA course assignment.
