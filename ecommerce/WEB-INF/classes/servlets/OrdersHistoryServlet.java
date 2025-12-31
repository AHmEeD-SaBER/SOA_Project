package servlets;

import java.io.*;
import java.net.URI;
import java.net.http.*;
import java.net.http.HttpResponse.BodyHandlers;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import org.json.JSONObject;
import org.json.JSONArray;

public class OrdersHistoryServlet extends HttpServlet {

    private static final String CUSTOMER_SERVICE_URL = "http://localhost:5004";
    private static final String ORDER_SERVICE_URL = "http://localhost:5001";
    private static final String INVENTORY_SERVICE_URL = "http://localhost:5002";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        System.out.println("=== OrdersHistoryServlet: Processing orders history request ===");

        try {
            String customerId = request.getParameter("customerId");
            System.out.println("Customer ID: " + customerId);

            if (customerId == null || customerId.isEmpty()) {
                request.setAttribute("error", "Please select a customer first");
                request.getRequestDispatcher("index.jsp").forward(request, response);
                return;
            }

            HttpClient client = HttpClient.newHttpClient();

            System.out.println("=== Fetching customer orders ===");
            
            HttpRequest ordersRequest = HttpRequest.newBuilder()
                    .uri(URI.create(CUSTOMER_SERVICE_URL + "/api/customers/" + customerId + "/orders"))
                    .GET()
                    .build();

            HttpResponse<String> ordersResponse = client.send(ordersRequest, BodyHandlers.ofString());
            System.out.println("Customer Orders response: " + ordersResponse.statusCode());

            if (ordersResponse.statusCode() != 200) {
                request.setAttribute("error", "Failed to load orders history. Customer not found.");
                request.getRequestDispatcher("index.jsp").forward(request, response);
                return;
            }

            JSONObject ordersResult = new JSONObject(ordersResponse.body());

            if (!ordersResult.getString("status").equals("success")) {
                request.setAttribute("error",
                        "Failed to load orders: " + ordersResult.optString("message", "Unknown error"));
                request.getRequestDispatcher("index.jsp").forward(request, response);
                return;
            }

            JSONObject customerData = ordersResult.getJSONObject("customer");
            JSONArray orders = ordersResult.getJSONArray("orders"); 
            int orderCount = ordersResult.getInt("order_count");

            System.out.println("Found " + orderCount + " orders for customer " + customerData.getString("name"));

            // Set attributes for View_orders_history.jsp
            request.setAttribute("customerId", customerId);
            request.setAttribute("customerData", customerData.toString());
            request.setAttribute("orders", orders.toString());  
            request.setAttribute("orderCount", orderCount);

            System.out.println("=== OrdersHistoryServlet: Forwarding to View_orders_history.jsp ===");

            // Forward to View_orders_history.jsp
            request.getRequestDispatcher("View_orders_history.jsp").forward(request, response);

        } catch (Exception e) {
            System.err.println("OrdersHistoryServlet Error: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "An error occurred: " + e.getMessage());
            request.getRequestDispatcher("index.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Handle POST same as GET
        doGet(request, response);
    }
}
