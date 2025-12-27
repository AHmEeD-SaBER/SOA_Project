package servlets;

import java.io.*;
import java.net.URI;
import java.net.http.*;
import java.net.http.HttpRequest.BodyPublishers;
import java.net.http.HttpResponse.BodyHandlers;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import org.json.JSONObject;
import org.json.JSONArray;

public class ConfirmOrderServlet extends HttpServlet {

    private static final String ORDER_SERVICE_URL = "http://localhost:5001";
    private static final String INVENTORY_SERVICE_URL = "http://localhost:5002";
    private static final String CUSTOMER_SERVICE_URL = "http://localhost:5004";
    private static final String NOTIFICATION_SERVICE_URL = "http://localhost:5005";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        System.out.println("=== ConfirmOrderServlet: Processing order confirmation ===");

        try {
            // Read parameters from request
            String customerId = request.getParameter("customerId");
            String productsJson = request.getParameter("products");
            String totalAmount = request.getParameter("totalAmount");
            String pricingDataJson = request.getParameter("pricingData");
            String customerDataJson = request.getParameter("customerData");

            System.out.println("Customer ID: " + customerId);
            System.out.println("Total Amount: " + totalAmount);
            System.out.println("Products: " + productsJson);

            if (customerId == null || productsJson == null || totalAmount == null) {
                request.setAttribute("error", "Missing required order information");
                request.getRequestDispatcher("checkout.jsp").forward(request, response);
                return;
            }

            HttpClient client = HttpClient.newHttpClient();
            JSONArray products = new JSONArray(productsJson);
            double grandTotal = Double.parseDouble(totalAmount);

            // Step 1: Create order using Order Service
            System.out.println("=== Step 1: Creating order ===");

            JSONObject orderPayload = new JSONObject();
            orderPayload.put("customer_id", Integer.parseInt(customerId));
            orderPayload.put("total_amount", grandTotal);

            JSONArray orderProducts = new JSONArray();
            for (int i = 0; i < products.length(); i++) {
                JSONObject p = products.getJSONObject(i);
                JSONObject op = new JSONObject();
                op.put("product_id", p.getInt("product_id"));
                op.put("quantity", p.getInt("quantity"));
                orderProducts.put(op);
            }
            orderPayload.put("products", orderProducts);

            // Call Order Service: POST /api/orders/create
            HttpRequest orderRequest = HttpRequest.newBuilder()
                    .uri(URI.create(ORDER_SERVICE_URL + "/api/orders/create"))
                    .header("Content-Type", "application/json")
                    .POST(BodyPublishers.ofString(orderPayload.toString()))
                    .build();

            HttpResponse<String> orderResponse = client.send(orderRequest, BodyHandlers.ofString());
            System.out.println("Order Service response: " + orderResponse.statusCode());
            System.out.println("Order Service body: " + orderResponse.body());

            if (orderResponse.statusCode() != 201 && orderResponse.statusCode() != 200) {
                request.setAttribute("error", "Failed to create order. Please try again.");
                request.getRequestDispatcher("checkout.jsp").forward(request, response);
                return;
            }

            JSONObject orderResult = new JSONObject(orderResponse.body());

            if (!orderResult.getString("status").equals("success")) {
                request.setAttribute("error",
                        "Order creation failed: " + orderResult.optString("message", "Unknown error"));
                request.getRequestDispatcher("checkout.jsp").forward(request, response);
                return;
            }

            JSONObject order = orderResult.getJSONObject("order");
            int orderId = order.getInt("order_id");
            System.out.println("Order created successfully! Order ID: " + orderId);

            // Step 2: Update inventory
            System.out.println("=== Step 2: Updating inventory ===");

            JSONObject inventoryPayload = new JSONObject();
            inventoryPayload.put("products", orderProducts);

            HttpRequest inventoryRequest = HttpRequest.newBuilder()
                    .uri(URI.create(INVENTORY_SERVICE_URL + "/api/inventory/update"))
                    .header("Content-Type", "application/json")
                    .PUT(BodyPublishers.ofString(inventoryPayload.toString()))
                    .build();

            HttpResponse<String> inventoryResponse = client.send(inventoryRequest, BodyHandlers.ofString());
            System.out.println("Inventory update response: " + inventoryResponse.statusCode());

            // Step 3: Update loyalty points using Customer Service
            System.out.println("=== Step 3: Updating loyalty points ===");

            int loyaltyPoints = (int) Math.floor(grandTotal);
            JSONObject loyaltyPayload = new JSONObject();
            loyaltyPayload.put("points", loyaltyPoints);
            loyaltyPayload.put("operation", "add");

            // Call Customer Service: PUT /api/customers/{customer_id}/loyalty
            HttpRequest loyaltyRequest = HttpRequest.newBuilder()
                    .uri(URI.create(CUSTOMER_SERVICE_URL + "/api/customers/" + customerId + "/loyalty"))
                    .header("Content-Type", "application/json")
                    .PUT(BodyPublishers.ofString(loyaltyPayload.toString()))
                    .build();

            HttpResponse<String> loyaltyResponse = client.send(loyaltyRequest, BodyHandlers.ofString());
            System.out.println("Loyalty update response: " + loyaltyResponse.statusCode());
            System.out.println("Loyalty response body: " + loyaltyResponse.body());

            int newLoyaltyPoints = 0;

            if (loyaltyResponse.statusCode() == 200) {
                JSONObject loyaltyResult = new JSONObject(loyaltyResponse.body());

                if ("success".equals(loyaltyResult.optString("status"))) {
                    // The Customer Service returns "new_points", not "loyalty_points"
                    newLoyaltyPoints = loyaltyResult.optInt("new_points", 0);
                    System.out.println("Loyalty points updated successfully. New balance: " + newLoyaltyPoints);
                } else {
                    System.err.println("Loyalty update failed: " + loyaltyResult.optString("message"));
                }
            } else {
                System.err.println("Loyalty update request failed with status: " + loyaltyResponse.statusCode());
            }

            // Step 4: Send notification using Notification Service
            System.out.println("=== Step 4: Sending notification ===");

            JSONObject notifPayload = new JSONObject();
            notifPayload.put("order_id", orderId);
            notifPayload.put("notification_type", "order_confirmation");

            // Call Notification Service: POST /api/notifications/send
            HttpRequest notifRequest = HttpRequest.newBuilder()
                    .uri(URI.create(NOTIFICATION_SERVICE_URL + "/api/notifications/send"))
                    .header("Content-Type", "application/json")
                    .POST(BodyPublishers.ofString(notifPayload.toString()))
                    .build();

            HttpResponse<String> notifResponse = client.send(notifRequest, BodyHandlers.ofString());
            System.out.println("Notification response: " + notifResponse.statusCode());

            // Prepare data for confirmation page
            JSONObject orderDetails = new JSONObject();
            orderDetails.put("order_id", orderId);
            orderDetails.put("customer_id", customerId);
            orderDetails.put("status", order.optString("status", "confirmed"));
            orderDetails.put("created_at", order.optString("created_at", ""));
            orderDetails.put("total_amount", grandTotal);
            orderDetails.put("loyalty_points_earned", loyaltyPoints);
            orderDetails.put("new_loyalty_balance", newLoyaltyPoints);

            // Set attributes for confirmation.jsp
            request.setAttribute("orderData", orderDetails.toString());
            request.setAttribute("pricingData", pricingDataJson);
            request.setAttribute("customerData", customerDataJson);
            request.setAttribute("products", productsJson);

            System.out.println("=== ConfirmOrderServlet: Forwarding to confirmation.jsp ===");

            // Forward to confirmation.jsp
            request.getRequestDispatcher("confirmation.jsp").forward(request, response);

        } catch (Exception e) {
            System.err.println("ConfirmOrderServlet Error: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "An error occurred: " + e.getMessage());
            request.getRequestDispatcher("checkout.jsp").forward(request, response);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Redirect GET requests to index.jsp
        response.sendRedirect("index.jsp");
    }
}