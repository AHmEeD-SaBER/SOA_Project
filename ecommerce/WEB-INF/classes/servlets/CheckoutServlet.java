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

public class CheckoutServlet extends HttpServlet {

    private static final String INVENTORY_SERVICE_URL = "http://localhost:5002";
    private static final String PRICING_SERVICE_URL = "http://localhost:5003";
    private static final String CUSTOMER_SERVICE_URL = "http://localhost:5004";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        System.out.println("=== CheckoutServlet: Processing checkout request ===");

        try {
            // Read parameters from request
            String customerId = request.getParameter("customerId");
            String[] productIds = request.getParameterValues("productId");
            String[] quantities = request.getParameterValues("quantity");

            System.out.println("Customer ID: " + customerId);
            System.out.println("Products count: " + (productIds != null ? productIds.length : 0));

            if (customerId == null || customerId.isEmpty()) {
                request.setAttribute("error", "Please select a customer");
                request.getRequestDispatcher("index.jsp").forward(request, response);
                return;
            }

            if (productIds == null || productIds.length == 0) {
                request.setAttribute("error", "No products selected");
                request.getRequestDispatcher("index.jsp").forward(request, response);
                return;
            }

            HttpClient client = HttpClient.newHttpClient();
            JSONArray validProducts = new JSONArray();
            StringBuilder stockErrors = new StringBuilder();

            // Step 1: Check stock availability for each product using Inventory Service
            System.out.println("=== Step 1: Checking stock availability ===");

            for (int i = 0; i < productIds.length; i++) {
                String productId = productIds[i];
                int requestedQty = Integer.parseInt(quantities[i]);

                if (requestedQty <= 0)
                    continue;

                // Call Inventory Service: GET /api/inventory/check/{product_id}
                HttpRequest inventoryRequest = HttpRequest.newBuilder()
                        .uri(URI.create(INVENTORY_SERVICE_URL + "/api/inventory/check/" + productId))
                        .GET()
                        .build();

                HttpResponse<String> inventoryResponse = client.send(inventoryRequest, BodyHandlers.ofString());
                System.out.println("Inventory check for product " + productId + ": " + inventoryResponse.statusCode());

                if (inventoryResponse.statusCode() == 200) {
                    JSONObject invData = new JSONObject(inventoryResponse.body());

                    if (invData.getString("status").equals("success")) {
                        int availableQty = invData.getInt("available_quantity");
                        JSONObject product = invData.getJSONObject("product");

                        // Check if requested quantity <= available quantity
                        if (requestedQty <= availableQty) {
                            JSONObject validProduct = new JSONObject();
                            validProduct.put("product_id", Integer.parseInt(productId));
                            validProduct.put("quantity", requestedQty);
                            validProduct.put("product_name", product.getString("product_name"));
                            validProduct.put("unit_price", product.getDouble("unit_price"));
                            validProduct.put("available_quantity", availableQty);
                            validProducts.put(validProduct);
                            System.out.println("Product " + productId + ": Requested " + requestedQty + ", Available "
                                    + availableQty + " - OK");
                        } else {
                            stockErrors.append("Product '" + product.getString("product_name") +
                                    "': Requested " + requestedQty + " but only " + availableQty + " available.\n");
                            System.out.println("Product " + productId + ": Requested " + requestedQty + ", Available "
                                    + availableQty + " - INSUFFICIENT");
                        }
                    }
                } else {
                    stockErrors.append("Product ID " + productId + " not found.\n");
                }
            }

            // If there are stock errors, return to index with error message
            if (stockErrors.length() > 0) {
                request.setAttribute("error", "Stock availability issues:\n" + stockErrors.toString());
                request.getRequestDispatcher("index.jsp").forward(request, response);
                return;
            }

            if (validProducts.length() == 0) {
                request.setAttribute("error", "No valid products to checkout");
                request.getRequestDispatcher("index.jsp").forward(request, response);
                return;
            }

            // Step 2: Calculate total amount using Pricing Service
            System.out.println("=== Step 2: Calculating pricing ===");

            // Build pricing request payload
            JSONObject pricingPayload = new JSONObject();
            JSONArray pricingProducts = new JSONArray();
            for (int i = 0; i < validProducts.length(); i++) {
                JSONObject p = validProducts.getJSONObject(i);
                JSONObject pp = new JSONObject();
                pp.put("product_id", p.getInt("product_id"));
                pp.put("quantity", p.getInt("quantity"));
                pricingProducts.put(pp);
            }
            pricingPayload.put("products", pricingProducts);
            pricingPayload.put("region", "default");

            // Call Pricing Service: POST /api/pricing/calculate
            HttpRequest pricingRequest = HttpRequest.newBuilder()
                    .uri(URI.create(PRICING_SERVICE_URL + "/api/pricing/calculate"))
                    .header("Content-Type", "application/json")
                    .POST(BodyPublishers.ofString(pricingPayload.toString()))
                    .build();

            HttpResponse<String> pricingResponse = client.send(pricingRequest, BodyHandlers.ofString());
            System.out.println("Pricing Service response: " + pricingResponse.statusCode());

            if (pricingResponse.statusCode() != 200) {
                request.setAttribute("error", "Failed to calculate pricing. Please try again.");
                request.getRequestDispatcher("index.jsp").forward(request, response);
                return;
            }

            JSONObject pricingData = new JSONObject(pricingResponse.body());

            if (!pricingData.getString("status").equals("success")) {
                request.setAttribute("error",
                        "Pricing calculation failed: " + pricingData.optString("message", "Unknown error"));
                request.getRequestDispatcher("index.jsp").forward(request, response);
                return;
            }

            JSONObject pricing = pricingData.getJSONObject("pricing");
            System.out.println("Pricing calculated - Grand Total: $" + pricing.getDouble("grand_total"));

            // Step 3: Get customer details
            System.out.println("=== Step 3: Getting customer details ===");

            HttpRequest customerRequest = HttpRequest.newBuilder()
                    .uri(URI.create(CUSTOMER_SERVICE_URL + "/api/customers/" + customerId))
                    .GET()
                    .build();

            HttpResponse<String> customerResponse = client.send(customerRequest, BodyHandlers.ofString());
            JSONObject customerData = null;

            if (customerResponse.statusCode() == 200) {
                JSONObject custResult = new JSONObject(customerResponse.body());
                if (custResult.getString("status").equals("success")) {
                    customerData = custResult.getJSONObject("customer");
                }
            }

            // Set attributes for checkout.jsp
            request.setAttribute("customerId", customerId);
            request.setAttribute("customerData", customerData != null ? customerData.toString() : "{}");
            request.setAttribute("products", validProducts.toString());
            request.setAttribute("pricingData", pricing.toString());

            System.out.println("=== CheckoutServlet: Forwarding to checkout.jsp ===");

            // Forward to checkout.jsp
            request.getRequestDispatcher("checkout.jsp").forward(request, response);

        } catch (Exception e) {
            System.err.println("CheckoutServlet Error: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "An error occurred: " + e.getMessage());
            request.getRequestDispatcher("index.jsp").forward(request, response);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Redirect GET requests to index.jsp
        response.sendRedirect("index.jsp");
    }
}
