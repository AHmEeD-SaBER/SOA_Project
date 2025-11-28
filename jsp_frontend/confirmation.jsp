<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <!DOCTYPE html>
    <html lang="en">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Order Confirmation - E-Commerce Store</title>
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
                max-width: 800px;
                margin: 0 auto;
                background: white;
                border-radius: 15px;
                box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
                padding: 40px;
            }

            .success-header {
                text-align: center;
                margin-bottom: 30px;
            }

            .success-icon {
                font-size: 80px;
                margin-bottom: 20px;
                animation: scaleIn 0.5s ease-out;
            }

            @keyframes scaleIn {
                0% {
                    transform: scale(0);
                }

                50% {
                    transform: scale(1.2);
                }

                100% {
                    transform: scale(1);
                }
            }

            h1 {
                color: #28a745;
                font-size: 2.5em;
                margin-bottom: 10px;
            }

            .subtitle {
                color: #666;
                font-size: 1.2em;
            }

            .order-info {
                background: #f8f9fa;
                padding: 25px;
                border-radius: 10px;
                margin: 25px 0;
            }

            .order-number {
                text-align: center;
                font-size: 1.8em;
                color: #667eea;
                font-weight: bold;
                margin-bottom: 20px;
                padding: 15px;
                background: white;
                border-radius: 8px;
                border: 3px dashed #667eea;
            }

            h2 {
                color: #333;
                font-size: 1.5em;
                margin: 25px 0 15px 0;
                padding-bottom: 10px;
                border-bottom: 2px solid #e0e0e0;
            }

            .info-grid {
                display: grid;
                grid-template-columns: repeat(2, 1fr);
                gap: 15px;
                margin-bottom: 20px;
            }

            .info-item {
                background: white;
                padding: 15px;
                border-radius: 5px;
            }

            .info-label {
                font-size: 0.9em;
                color: #666;
                margin-bottom: 5px;
            }

            .info-value {
                font-size: 1.1em;
                color: #333;
                font-weight: bold;
            }

            .order-items {
                background: white;
                padding: 15px;
                border-radius: 5px;
                margin-bottom: 15px;
            }

            .item-row {
                display: flex;
                justify-content: space-between;
                padding: 12px 0;
                border-bottom: 1px solid #e0e0e0;
            }

            .item-row:last-child {
                border-bottom: none;
            }

            .item-name {
                font-weight: bold;
                color: #333;
            }

            .item-details {
                color: #666;
                font-size: 0.9em;
                margin-top: 3px;
            }

            .item-price {
                font-weight: bold;
                color: #667eea;
                text-align: right;
            }

            .pricing-summary {
                background: white;
                padding: 20px;
                border-radius: 5px;
            }

            .price-row {
                display: flex;
                justify-content: space-between;
                padding: 10px 0;
                color: #333;
            }

            .price-row.highlight {
                color: #28a745;
                font-weight: bold;
            }

            .price-row.total {
                font-size: 1.5em;
                font-weight: bold;
                color: #667eea;
                padding-top: 15px;
                margin-top: 15px;
                border-top: 3px solid #e0e0e0;
            }

            .next-steps {
                background: #e7f3ff;
                border-left: 4px solid #2196F3;
                padding: 20px;
                margin: 25px 0;
                border-radius: 5px;
            }

            .next-steps h3 {
                color: #2196F3;
                margin-bottom: 15px;
            }

            .next-steps ul {
                list-style: none;
                padding: 0;
            }

            .next-steps li {
                padding: 8px 0;
                padding-left: 25px;
                position: relative;
                color: #333;
            }

            .next-steps li:before {
                content: "✓";
                position: absolute;
                left: 0;
                color: #28a745;
                font-weight: bold;
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

            .btn-secondary {
                background: #28a745;
                color: white;
            }

            .btn-secondary:hover {
                background: #218838;
            }

            .error-message {
                background: #f8d7da;
                color: #721c24;
                padding: 20px;
                border-radius: 5px;
                text-align: center;
                margin: 20px 0;
            }

            @media print {
                body {
                    background: white;
                }

                .button-group {
                    display: none;
                }

                .container {
                    box-shadow: none;
                }
            }
        </style>
    </head>

    <body>
        <div class="container">
            <div id="confirmationContent">
                <div class="loading">Loading order confirmation...</div>
            </div>
        </div>

        <script>
            document.addEventListener('DOMContentLoaded', function () {
                const orderDataJson = sessionStorage.getItem('orderData');
                const pricingDataJson = sessionStorage.getItem('pricingData');
                const customerDataJson = sessionStorage.getItem('customerData');

                if (!orderDataJson || !pricingDataJson || !customerDataJson) {
                    document.getElementById('confirmationContent').innerHTML =
                        '<div class="error-message">' +
                        '<h2>⚠️ No Order Data Found</h2>' +
                        '<p>We couldn\'t find your order information. Please start over.</p>' +
                        '</div>' +
                        '<div class="button-group">' +
                        '<a href="index.jsp" class="btn btn-primary">← Back to Store</a>' +
                        '</div>';
                    return;
                }

                const orderData = JSON.parse(orderDataJson);
                const pricingData = JSON.parse(pricingDataJson);
                const customerData = JSON.parse(customerDataJson);

                console.log('=== CONFIRMATION PAGE - Data Loaded ===');
                console.log('Order Data:', orderData);
                console.log('Pricing Data:', pricingData);
                console.log('Customer Data:', customerData);

                displayConfirmation(orderData, pricingData, customerData);
            });

            function displayConfirmation(order, pricing, customer) {
                const content = document.getElementById('confirmationContent');

                let html = '<div class="success-header">';
                html += '<div class="success-icon">✅</div>';
                html += '<h1>Order Confirmed!</h1>';
                html += '<p class="subtitle">Thank you for your purchase</p>';
                html += '</div>';

                html += '<div class="order-info">';
                html += '<div class="order-number">';
                html += 'Order #' + order.order_id;
                html += '</div>';

                html += '<div class="info-grid">';
                html += '<div class="info-item">';
                html += '<div class="info-label">Customer Name</div>';
                html += '<div class="info-value">' + customer.name + '</div>';
                html += '</div>';

                html += '<div class="info-item">';
                html += '<div class="info-label">Email</div>';
                html += '<div class="info-value">' + customer.email + '</div>';
                html += '</div>';

                html += '<div class="info-item">';
                html += '<div class="info-label">Order Date</div>';
                html += '<div class="info-value">' + new Date(order.created_at).toLocaleDateString() + '</div>';
                html += '</div>';

                html += '<div class="info-item">';
                html += '<div class="info-label">Order Status</div>';
                html += '<div class="info-value" style="color: #28a745;">' + order.status.toUpperCase() + '</div>';
                html += '</div>';
                html += '</div>';
                html += '</div>';

                html += '<h2>📦 Order Details</h2>';
                html += '<div class="order-items">';

                pricing.itemized_breakdown.forEach(item => {
                    html += '<div class="item-row">';
                    html += '<div>';
                    html += '<div class="item-name">' + item.product_name + '</div>';
                    html += '<div class="item-details">Quantity: ' + item.quantity + ' × $' + item.unit_price.toFixed(2);
                    if (item.discount_percentage > 0) {
                        html += ' <span style="color: #28a745;">(' + item.discount_percentage + '% discount applied)</span>';
                    }
                    html += '</div></div>';
                    html += '<div class="item-price">$' + item.line_total.toFixed(2) + '</div>';
                    html += '</div>';
                });

                html += '</div>';

                html += '<div class="pricing-summary">';
                html += '<div class="price-row"><span>Subtotal:</span><span>$' + pricing.subtotal.toFixed(2) + '</span></div>';

                if (pricing.total_discount > 0) {
                    html += '<div class="price-row highlight"><span>You Saved:</span><span>-$' + pricing.total_discount.toFixed(2) + '</span></div>';
                }

                html += '<div class="price-row"><span>Subtotal After Discount:</span><span>$' + pricing.subtotal_after_discount.toFixed(2) + '</span></div>';
                html += '<div class="price-row"><span>Tax (' + pricing.tax_rate + '%):</span><span>$' + pricing.tax_amount.toFixed(2) + '</span></div>';
                html += '<div class="price-row total"><span>Grand Total:</span><span>$' + pricing.grand_total.toFixed(2) + '</span></div>';
                html += '</div>';

                html += '<div class="next-steps">';
                html += '<h3>📋 What Happens Next?</h3>';
                html += '<ul>';
                html += '<li>A confirmation email has been sent to your registered email address</li>';
                html += '<li>Your order is being processed and will be shipped within 2-3 business days</li>';
                html += '<li>You will receive a tracking number once your order ships</li>';
                html += '<li>Estimated delivery: 3-5 business days</li>';
                html += '<li>Loyalty points earned: ' + Math.floor(pricing.grand_total) + ' points</li>';
                html += '</ul>';
                html += '</div>';

                html += '<div class="button-group">';
                html += '<a href="index.jsp" class="btn btn-primary">← Continue Shopping</a>';
                html += '<button class="btn btn-secondary" onclick="window.print()">🖨️ Print Receipt</button>';
                html += '</div>';

                content.innerHTML = html;

                // Clear session storage after displaying
                setTimeout(() => {
                    sessionStorage.removeItem('orderData');
                    sessionStorage.removeItem('pricingData');
                    sessionStorage.removeItem('customerData');
                }, 1000);
            }
        </script>
    </body>

    </html>