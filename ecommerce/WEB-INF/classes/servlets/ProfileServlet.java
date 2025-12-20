package servlets;

import java.io.*;
import java.net.URI;
import java.net.http.*;
import java.net.http.HttpResponse.BodyHandlers;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import org.json.JSONObject;
import org.json.JSONArray;

public class ProfileServlet extends HttpServlet {

    private static final String CUSTOMER_SERVICE_URL = "http://localhost:5004";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        System.out.println("=== ProfileServlet: Processing profile request ===");

        try {
            // Read customer ID from request
            String customerId = request.getParameter("customerId");

            System.out.println("Customer ID: " + customerId);

            if (customerId == null || customerId.isEmpty()) {
                request.setAttribute("error", "Please select a customer first");
                request.getRequestDispatcher("index.jsp").forward(request, response);
                return;
            }

            HttpClient client = HttpClient.newHttpClient();

            // Get customer details using Customer Service
            System.out.println("=== Fetching customer details ===");

            // Call Customer Service: GET /api/customers/{customer_id}
            HttpRequest customerRequest = HttpRequest.newBuilder()
                    .uri(URI.create(CUSTOMER_SERVICE_URL + "/api/customers/" + customerId))
                    .GET()
                    .build();

            HttpResponse<String> customerResponse = client.send(customerRequest, BodyHandlers.ofString());
            System.out.println("Customer Service response: " + customerResponse.statusCode());

            if (customerResponse.statusCode() != 200) {
                request.setAttribute("error", "Failed to load customer profile. Customer not found.");
                request.getRequestDispatcher("index.jsp").forward(request, response);
                return;
            }

            JSONObject customerResult = new JSONObject(customerResponse.body());

            if (!customerResult.getString("status").equals("success")) {
                request.setAttribute("error",
                        "Failed to load profile: " + customerResult.optString("message", "Unknown error"));
                request.getRequestDispatcher("index.jsp").forward(request, response);
                return;
            }

            JSONObject customerData = customerResult.getJSONObject("customer");
            System.out.println("Customer data loaded: " + customerData.getString("name"));

            // Set attributes for profile.jsp
            request.setAttribute("customerId", customerId);
            request.setAttribute("customerData", customerData.toString());

            System.out.println("=== ProfileServlet: Forwarding to profile.jsp ===");

            // Forward to profile.jsp
            request.getRequestDispatcher("profile.jsp").forward(request, response);

        } catch (Exception e) {
            System.err.println("ProfileServlet Error: " + e.getMessage());
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
