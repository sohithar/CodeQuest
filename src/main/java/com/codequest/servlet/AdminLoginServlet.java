package com.codequest.servlet;

import com.codequest.db.DBConnection;
import com.codequest.util.Html;
import com.codequest.util.PasswordUtil;
import jakarta.servlet.ServletConfig;
import jakarta.servlet.ServletContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebInitParam;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * Module 4 - Admin login.
 * ServletConfig demonstration: the admin session timeout comes from this servlet's init-param.
 * ServletContext demonstration: the application name is read from the context.
 */
@WebServlet(urlPatterns = "/AdminLoginServlet",
        initParams = {@WebInitParam(name = "adminSessionTimeoutMinutes", value = "20")})
public class AdminLoginServlet extends HttpServlet {

    private int timeoutMinutes = 20;

    @Override
    public void init() throws ServletException {
        ServletConfig config = getServletConfig();
        try {
            timeoutMinutes = Integer.parseInt(config.getInitParameter("adminSessionTimeoutMinutes"));
        } catch (Exception e) {
            timeoutMinutes = 20;
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.sendRedirect("admin-login.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = Html.param(request, "username");
        String password = request.getParameter("password") == null ? "" : request.getParameter("password");

        if (username.isEmpty() || password.isEmpty()) {
            request.setAttribute("error", "Please enter the admin username and password.");
            request.getRequestDispatcher("admin-login.jsp").forward(request, response);
            return;
        }

        String sql = "SELECT id, username FROM admins WHERE username = ? AND password = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, username);
            ps.setString(2, PasswordUtil.hash(password));

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    HttpSession old = request.getSession(false);
                    if (old != null) old.invalidate();
                    HttpSession session = request.getSession(true);
                    session.setAttribute("adminId", rs.getInt("id"));
                    session.setAttribute("adminName", rs.getString("username"));
                    session.setMaxInactiveInterval(timeoutMinutes * 60);

                    ServletContext ctx = getServletContext();
                    ctx.log(ctx.getAttribute("appName") + ": admin '" + username + "' logged in");

                    response.sendRedirect("admin-dashboard.jsp");
                } else {
                    request.setAttribute("error", "Invalid admin username or password.");
                    request.getRequestDispatcher("admin-login.jsp").forward(request, response);
                }
            }
        } catch (SQLException e) {
            request.setAttribute("error", "Database error: " + e.getMessage());
            request.getRequestDispatcher("admin-login.jsp").forward(request, response);
        }
    }
}
