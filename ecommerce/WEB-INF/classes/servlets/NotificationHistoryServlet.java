package servlets;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.json.JSONArray;
import org.json.JSONObject;

import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;

public class NotificationHistoryServlet extends HttpServlet {

    private static final String NOTIFICATION_SERVICE_URL = "http://localhost:5005";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String customerIdStr = request.getParameter("customerId");

        if (customerIdStr == null || customerIdStr.trim().isEmpty()) {
            request.setAttribute("error", "Customer ID is required");
            request.getRequestDispatcher("index.jsp").forward(request, response);
            return;
        }

        int customerId;
        try {
            customerId = Integer.parseInt(customerIdStr);
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid customer ID");
            request.getRequestDispatcher("index.jsp").forward(request, response);
            return;
        }

        try {
            HttpClient client = HttpClient.newHttpClient();
            HttpRequest req = HttpRequest.newBuilder()
                    .uri(URI.create(NOTIFICATION_SERVICE_URL + "/api/notifications/customer/" + customerId))
                    .GET()
                    .build();

            HttpResponse<String> httpResponse = client.send(req, HttpResponse.BodyHandlers.ofString());

            if (httpResponse.statusCode() != 200) {
                request.setAttribute("error",
                        "Failed to load notifications (Service responded: " + httpResponse.statusCode() + ")");
                request.getRequestDispatcher("profile.jsp").forward(request, response);
                return;
            }

            JSONObject result = new JSONObject(httpResponse.body());

            if (!result.optString("status").equals("success")) {
                request.setAttribute("error", result.optString("message", "Unknown error"));
                request.getRequestDispatcher("profile.jsp").forward(request, response);
                return;
            }

            // Pass data to JSP
            request.setAttribute("customerId", customerIdStr);
            request.setAttribute("notifications", result.getJSONArray("notifications").toString());
            request.setAttribute("notificationCount", result.optInt("count", 0));

            request.setAttribute("customerName", getCustomerName(client, customerId));

            request.getRequestDispatcher("notifications.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error: " + e.getMessage());
            request.getRequestDispatcher("profile.jsp").forward(request, response);
        }
    }

    private String getCustomerName(HttpClient client, int customerId) {
        try {
            HttpRequest req = HttpRequest.newBuilder()
                    .uri(URI.create("http://localhost:5004/api/customers/" + customerId))
                    .GET()
                    .build();
            HttpResponse<String> resp = client.send(req, HttpResponse.BodyHandlers.ofString());
            if (resp.statusCode() == 200) {
                JSONObject data = new JSONObject(resp.body());
                if (data.optString("status").equals("success")) {
                    return data.getJSONObject("customer").optString("name", "Customer");
                }
            }
        } catch (Exception ignored) {
        }
        return "Customer";
    }
}