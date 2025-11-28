-- Drop database if exists (for clean setup)
DROP DATABASE IF EXISTS ecommerce_system;

-- Create database
CREATE DATABASE ecommerce_system;
USE ecommerce_system;

CREATE TABLE inventory (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(100) NOT NULL,
    quantity_available INT NOT NULL DEFAULT 0,
    unit_price DECIMAL(10,2) NOT NULL,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_product_name (product_name),
    INDEX idx_quantity (quantity_available)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE pricing_rules (
    rule_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    min_quantity INT NOT NULL,
    discount_percentage DECIMAL(5,2) NOT NULL,
    description VARCHAR(200),
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES inventory(product_id) ON DELETE CASCADE,
    INDEX idx_product_quantity (product_id, min_quantity)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE tax_rates (
    region VARCHAR(50) PRIMARY KEY,
    tax_rate DECIMAL(5,2) NOT NULL,
    description VARCHAR(200),
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    address VARCHAR(255),
    loyalty_points INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_loyalty (loyalty_points)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- Orders table
CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    status VARCHAR(50) DEFAULT 'confirmed',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    INDEX idx_customer (customer_id),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Order items table (products in each order)
CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES inventory(product_id),
    INDEX idx_order (order_id),
    INDEX idx_product (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE notification_log (
    notification_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    customer_id INT NOT NULL,
    notification_type VARCHAR(50) NOT NULL,
    message TEXT,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'sent',
    INDEX idx_order (order_id),
    INDEX idx_customer (customer_id),
    INDEX idx_sent_at (sent_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


INSERT INTO inventory (product_name, quantity_available, unit_price) VALUES
('Laptop - Dell XPS 15', 50, 999.99),
('Wireless Mouse - Logitech MX', 200, 29.99),
('Mechanical Keyboard - Corsair K95', 150, 79.99),
('4K Monitor - LG 27"', 75, 299.99),
('Noise-Cancelling Headphones - Sony WH-1000XM4', 100, 149.99),
('USB-C Hub - Anker 7-in-1', 250, 39.99),
('Webcam - Logitech C920', 120, 69.99),
('External SSD - Samsung T7 1TB', 180, 119.99),
('Gaming Mouse Pad - Razer Goliathus', 300, 19.99),
('Laptop Stand - Rain Design mStand', 90, 49.99);


INSERT INTO pricing_rules (product_id, min_quantity, discount_percentage, description) VALUES
(1, 5, 10.00, 'Buy 5 or more laptops, get 10% off'),
(1, 10, 15.00, 'Buy 10 or more laptops, get 15% off'),
(2, 10, 15.00, 'Buy 10 or more mice, get 15% off'),
(2, 20, 20.00, 'Buy 20 or more mice, get 20% off'),
(3, 10, 12.00, 'Buy 10 or more keyboards, get 12% off'),
(3, 20, 18.00, 'Buy 20 or more keyboards, get 18% off'),
(4, 5, 8.00, 'Buy 5 or more monitors, get 8% off'),
(4, 10, 12.00, 'Buy 10 or more monitors, get 12% off'),
(5, 5, 10.00, 'Buy 5 or more headphones, get 10% off'),
(6, 15, 15.00, 'Buy 15 or more hubs, get 15% off'),
(7, 10, 10.00, 'Buy 10 or more webcams, get 10% off'),
(8, 5, 8.00, 'Buy 5 or more SSDs, get 8% off'),
(8, 10, 15.00, 'Buy 10 or more SSDs, get 15% off'),
(9, 20, 20.00, 'Buy 20 or more mouse pads, get 20% off'),
(9, 50, 25.00, 'Buy 50 or more mouse pads, get 25% off'),
(10, 10, 10.00, 'Buy 10 or more stands, get 10% off');


INSERT INTO tax_rates (region, tax_rate, description) VALUES
('default', 14.00, 'Default tax rate'),
('Cairo', 14.00, 'Cairo governorate tax rate'),
('Alexandria', 14.00, 'Alexandria governorate tax rate'),
('Giza', 14.00, 'Giza governorate tax rate'),
('Luxor', 14.00, 'Luxor governorate tax rate'),
('Aswan', 14.00, 'Aswan governorate tax rate'),
('North_America', 8.50, 'North America average tax rate'),
('Europe', 20.00, 'European Union average VAT rate'),
('Asia', 10.00, 'Asia average tax rate');



INSERT INTO customers (name, email, phone, address, loyalty_points) VALUES
('Ahmed Hassan', 'ahmed.hassan@example.com', '01012345678', '123 Tahrir Square, Cairo', 100),
('Sara Mohamed', 'sara.mohamed@example.com', '01098765432', '456 Corniche, Alexandria', 250),
('Omar Ali', 'omar.ali@example.com', '01055555555', '789 Pyramids Road, Giza', 50),
('Fatma Ibrahim', 'fatma.ibrahim@example.com', '01123456789', '321 University Street, Cairo', 180),
('Mahmoud Khalil', 'mahmoud.khalil@example.com', '01087654321', '654 Port Said Street, Alexandria', 420),
('Nour Abdel Rahman', 'nour.abdel@example.com', '01156789012', '987 Nile Corniche, Luxor', 75),
('Yasmin Saeed', 'yasmin.saeed@example.com', '01034567890', '111 Mohandessin, Cairo', 310),
('Karim Mostafa', 'karim.mostafa@example.com', '01145678901', '222 Maadi, Cairo', 150),
('Laila Fathy', 'laila.fathy@example.com', '01178901234', '333 Heliopolis, Cairo', 90),
('Tarek Nabil', 'tarek.nabil@example.com', '01067890123', '444 Nasr City, Cairo', 200);


INSERT INTO notification_log (order_id, customer_id, notification_type, message, sent_at) VALUES
(100001, 1, 'order_confirmation', 'Your order has been confirmed and is being processed.', '2025-11-20 10:30:00'),
(100002, 2, 'order_confirmation', 'Your order has been confirmed and is being processed.', '2025-11-21 14:15:00'),
(100003, 3, 'order_shipped', 'Your order has been shipped and will arrive soon.', '2025-11-22 09:45:00'),
(100004, 1, 'order_delivered', 'Your order has been delivered successfully.', '2025-11-23 16:20:00'),
(100005, 4, 'order_confirmation', 'Your order has been confirmed and is being processed.', '2025-11-24 11:00:00');


DROP USER IF EXISTS 'ecommerce_user'@'localhost';

CREATE USER 'ecommerce_user'@'localhost' IDENTIFIED BY 'secure_password';

GRANT SELECT, INSERT, UPDATE ON ecommerce_system.* TO 'ecommerce_user'@'localhost';
FLUSH PRIVILEGES;


-- Verify table creation
SELECT 'Tables Created:' AS Status;
SHOW TABLES;

-- Verify inventory data
SELECT 'Inventory Products:' AS Status;
SELECT product_id, product_name, quantity_available, unit_price FROM inventory;

-- Verify customers
SELECT 'Customers:' AS Status;
SELECT customer_id, name, email, loyalty_points FROM customers;

-- Verify pricing rules
SELECT 'Pricing Rules:' AS Status;
SELECT r.rule_id, i.product_name, r.min_quantity, r.discount_percentage 
FROM pricing_rules r
JOIN inventory i ON r.product_id = i.product_id;

-- Verify tax rates
SELECT 'Tax Rates:' AS Status;
SELECT region, tax_rate FROM tax_rates;