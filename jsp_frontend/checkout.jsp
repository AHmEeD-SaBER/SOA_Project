<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ page import="java.net.http.*" %>
        <%@ page import="java.net.URI" %>
            <%@ page import="org.json.*" %>
                <!DOCTYPE html>
                <html lang="en">

                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>Checkout - E-Commerce Store</title>
                    <style>
                        * {
                            margin: 0;
                            padding: 0;
                            box-sizing: border-box;
                        }

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

                        h1 {
                            color: #333;
                            font-size: 2.2em;
                            margin-bottom: 10px;
                        }

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

                        .item-name {
                            font-weight: bold;
                            color: #333;
                        }

                        .item-details {
                            color: #666;
                            font-size: 0.9em;
                            margin-top: 5px;
                        }

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

                        .info-label {
                            font-weight: bold;
                            color: #333;
                            min-width: 120px;
                        }

                        .info-value {
                            color: #666;
                        }

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

                        .btn-secondary {
                            background: #6c757d;
                            color: white;
                        }

                        .btn-secondary:hover {
                            background: #5a6268;
                        }

                        .loading {
                            text-align: center;
                            padding: 40px;
                            font-size: 1.2em;
                            color: #667eea;
                        }

                        .error-message {
                            background: #f8d7da;
                            color: #721c24;
                            padding: 15px;
                            border-radius: 5px;
                            margin-bottom: 20px;
                            border: 1px solid #f5c6cb;
                        }

                        .success-message {
                            background: #d4edda;
                            color: #155724;
                            padding: 15px;
                            border-radius: 5px;
                            margin-bottom: 20px;
                            border: 1px solid #c3e6cb;
                        }

                        .processing {
                            text-align: center;
                            padding: 40px;
                        }

                        .spinner {
                            border: 4px solid #f3f3f3;
                            border-top: 4px solid #667eea;
                            border-radius: 50%;
                            width: 50px;
                            height: 50px;
                            animation: spin 1s linear infinite;
                            margin: 0 auto 20px;
                        }

                        @keyframes spin {
                            0% {
                                transform: rotate(0deg);
                            }

                            100% {
                                transform: rotate(360deg);
                            }
                        }
                    </style>
                </head>

                <body>
                    <div class="container">
                        <header>
                            <h1>🛒 Checkout</h1>
                            <p class="subtitle">Review Your Order</p>
                        </header>

                        <div id="checkoutContent">
                            <div class="loading">Loading order details...</div>
                        </div>
                    </div>

                    <script>
                        let cart = [];
                        let customerId = null;
                        let pricingData = null;
                        let customerData = null;

                        // Load cart from session storage
                        document.addEventListener('DOMContentLoaded', function () {
                            console.log('=== CHECKOUT PAGE - Loading ===');
                            const cartJson = sessionStorage.getItem('cart');
                            customerId = sessionStorage.getItem('customerId');

                            console.log('Cart JSON from sessionStorage:', cartJson);
                            console.log('Customer ID from sessionStorage:', customerId);

                            if (!cartJson || !customerId) {
                                console.error('Missing cart or customer ID!');
                                document.getElementById('checkoutContent').innerHTML =
                                    '<div class="error-message">No order data found. Please go back and add items to cart.</div>' +
                                    '<button class="btn btn-secondary" onclick="goBack()">← Back to Store</button>';
                                return;
                            }

                            cart = JSON.parse(cartJson);
                            console.log('Parsed cart:', cart);
                            loadCheckoutData();
                        });

                        async function loadCheckoutData() {
                            try {
                                console.log('=== CHECKOUT - Loading Customer Data ===');
                                console.log('Fetching customer:', customerId);
                                // Load customer data
                                const customerResponse = await fetch('http://localhost:5004/api/customers/' + customerId);
                                const customerResult = await customerResponse.json();

                                console.log('Customer API Response:', customerResult);

                                if (customerResult.status !== 'success') {
                                    throw new Error('Failed to load customer data');
                                }

                                customerData = customerResult.customer;
                                console.log('Customer Data:', customerData);

                                // Calculate pricing
                                const products = cart.map(item => ({
                                    product_id: item.product_id,
                                    quantity: item.quantity
                                }));

                                console.log('=== CHECKOUT - Calculating Pricing ===');
                                console.log('Pricing Request:', { products: products, region: 'default' });

                                const pricingResponse = await fetch('http://localhost:5003/api/pricing/calculate', {
                                    method: 'POST',
                                    headers: {
                                        'Content-Type': 'application/json'
                                    },
                                    body: JSON.stringify({ products: products, region: 'default' })
                                });

                                const pricingResult = await pricingResponse.json();

                                console.log('Pricing API Response:', pricingResult);

                                if (pricingResult.status !== 'success') {
                                    throw new Error('Failed to calculate pricing');
                                }

                                pricingData = pricingResult.pricing;
                                console.log('Pricing Data:', pricingData);

                                displayCheckout();

                            } catch (error) {
                                document.getElementById('checkoutContent').innerHTML =
                                    '<div class="error-message">Error loading checkout data: ' + error.message + '<br>' +
                                    '<small>Make sure all services are running.</small></div>' +
                                    '<button class="btn btn-secondary" onclick="goBack()">← Back to Store</button>';
                            }
                        }

                        function displayCheckout() {
                            const content = document.getElementById('checkoutContent');

                            let html = '<h2>👤 Customer Information</h2>';
                            html += '<div class="customer-info">';
                            html += '<div class="info-row"><span class="info-label">Name:</span><span class="info-value">' + customerData.name + '</span></div>';
                            html += '<div class="info-row"><span class="info-label">Email:</span><span class="info-value">' + customerData.email + '</span></div>';
                            html += '<div class="info-row"><span class="info-label">Phone:</span><span class="info-value">' + (customerData.phone || 'N/A') + '</span></div>';
                            html += '<div class="info-row"><span class="info-label">Loyalty Points:</span><span class="info-value">' + customerData.loyalty_points + ' points</span></div>';
                            html += '</div>';

                            html += '<h2>📦 Order Summary</h2>';
                            html += '<div class="order-summary">';

                            pricingData.itemized_breakdown.forEach(item => {
                                html += '<div class="order-item">';
                                html += '<div>';
                                html += '<div class="item-name">' + item.product_name + '</div>';
                                html += '<div class="item-details">$' + item.unit_price.toFixed(2) + ' × ' + item.quantity;
                                if (item.discount_percentage > 0) {
                                    html += ' (' + item.discount_percentage + '% discount)';
                                }
                                html += '</div></div>';
                                html += '<div class="item-name">$' + item.line_total.toFixed(2) + '</div>';
                                html += '</div>';
                            });

                            html += '<div class="pricing-breakdown">';
                            html += '<div class="price-row"><span>Subtotal:</span><span>$' + pricingData.subtotal.toFixed(2) + '</span></div>';
                            html += '<div class="price-row"><span>Discount:</span><span>-$' + pricingData.total_discount.toFixed(2) + '</span></div>';
                            html += '<div class="price-row"><span>Tax (' + pricingData.tax_rate + '%):</span><span>$' + pricingData.tax_amount.toFixed(2) + '</span></div>';
                            html += '<div class="price-row total"><span>Grand Total:</span><span>$' + pricingData.grand_total.toFixed(2) + '</span></div>';
                            html += '</div>';
                            html += '</div>';

                            html += '<div class="button-group">';
                            html += '<button class="btn btn-secondary" onclick="goBack()">← Back to Store</button>';
                            html += '<button class="btn btn-primary" onclick="placeOrder()">Place Order ✓</button>';
                            html += '</div>';

                            content.innerHTML = html;
                        }

                        async function placeOrder() {
                            const content = document.getElementById('checkoutContent');

                            console.log('=== CHECKOUT - Placing Order ===');

                            content.innerHTML =
                                '<div class="processing">' +
                                '<div class="spinner"></div>' +
                                '<h2>Processing Your Order...</h2>' +
                                '<p>Please wait while we confirm your order.</p>' +
                                '</div>';

                            try {
                                // Create order
                                const products = cart.map(item => ({
                                    product_id: item.product_id,
                                    quantity: item.quantity
                                }));

                                const orderData = {
                                    customer_id: parseInt(customerId),
                                    products: products,
                                    total_amount: pricingData.grand_total
                                };

                                console.log('Order Data:', orderData);

                                console.log('Calling Order Service at http://localhost:5001/api/orders/create');
                                const orderResponse = await fetch('http://localhost:5001/api/orders/create', {
                                    method: 'POST',
                                    headers: {
                                        'Content-Type': 'application/json'
                                    },
                                    body: JSON.stringify(orderData)
                                });

                                const orderResult = await orderResponse.json();
                                console.log('Order Service Response:', orderResult);

                                if (orderResult.status !== 'success') {
                                    throw new Error(orderResult.message || 'Failed to create order');
                                }

                                const order = orderResult.order;
                                console.log('Order created successfully! Order ID:', order.order_id);

                                // Update inventory
                                console.log('=== CHECKOUT - Updating Inventory ===');
                                console.log('Inventory update payload:', { products: products });
                                const invResponse = await fetch('http://localhost:5002/api/inventory/update', {
                                    method: 'PUT',
                                    headers: {
                                        'Content-Type': 'application/json'
                                    },
                                    body: JSON.stringify({ products: products })
                                });
                                const invResult = await invResponse.json();
                                console.log('Inventory Service Response:', invResult);

                                // Send notification
                                console.log('=== CHECKOUT - Sending Notification ===');
                                const notifPayload = {
                                    order_id: order.order_id,
                                    notification_type: 'order_confirmation'
                                };
                                console.log('Notification payload:', notifPayload);
                                const notifResponse = await fetch('http://localhost:5005/api/notifications/send', {
                                    method: 'POST',
                                    headers: {
                                        'Content-Type': 'application/json'
                                    },
                                    body: JSON.stringify(notifPayload)
                                });
                                const notifResult = await notifResponse.json();
                                console.log('Notification Service Response:', notifResult);

                                // Clear cart
                                sessionStorage.removeItem('cart');
                                sessionStorage.removeItem('customerId');

                                // Redirect to confirmation
                                console.log('=== CHECKOUT - Saving to sessionStorage for Confirmation ===');
                                console.log('Order data:', order);
                                console.log('Pricing data:', pricingData);
                                console.log('Customer data:', customerData);
                                sessionStorage.setItem('orderData', JSON.stringify(order));
                                sessionStorage.setItem('pricingData', JSON.stringify(pricingData));
                                sessionStorage.setItem('customerData', JSON.stringify(customerData));
                                console.log('Redirecting to confirmation.jsp...');
                                window.location.href = 'confirmation.jsp';

                            } catch (error) {
                                content.innerHTML =
                                    '<div class="error-message">Error placing order: ' + error.message + '<br>' +
                                    '<small>Please try again or contact support.</small></div>' +
                                    '<div class="button-group">' +
                                    '<button class="btn btn-secondary" onclick="goBack()">← Back to Store</button>' +
                                    '<button class="btn btn-primary" onclick="loadCheckoutData()">Retry</button>' +
                                    '</div>';
                            }
                        }

                        function goBack() {
                            window.location.href = 'index.jsp';
                        }
                    </script>
                </body>

                </html>