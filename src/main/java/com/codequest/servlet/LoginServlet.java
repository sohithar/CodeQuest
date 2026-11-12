package com.codequest.servlet;

import com.codequest.db.DBConnection;
import com.codequest.util.Html;
import com.codequest.util.PasswordUtil;
import jakarta.servlet.ServletContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.concurrent.atomic.AtomicInteger;

/** Module 3 - Student login (username OR email). Uses a session and a cookie. */
@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.sendRedirect("login.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String identifier = Html.param(request, "identifier");
        String password = request.getParameter("password") == null ? "" : request.getParameter("password");
        boolean remember = request.getParameter("remember") != null;

        if (identifier.isEmpty() || password.isEmpty()) {
            request.setAttribute("error", "Please enter your username/email and password.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }

        String sql = "SELECT id, username FROM users WHERE (username = ? OR email = ?) AND password = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, identifier);
            ps.setString(2, identifier);
            ps.setString(3, PasswordUtil.hash(password));

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int userId = rs.getInt("id");
                    String username = rs.getString("username");

                    // new session after login (prevents session fixation)
                    HttpSession old = request.getSession(false);
                    if (old != null) old.invalidate();
                    HttpSession session = request.getSession(true);
                    session.setAttribute("userId", userId);
                    session.setAttribute("username", username);
                    session.setMaxInactiveInterval(30 * 60);

                    // Cookie demonstration: remember the username on the login form
                    Cookie cookie = new Cookie("cq_username", username);
                    cookie.setPath(request.getContextPath().isEmpty() ? "/" : request.getContextPath());
                    cookie.setMaxAge(remember ? 7 * 24 * 60 * 60 : 0);
                    response.addCookie(cookie);

                    // ServletContext demonstration: application-wide login counter
                    ServletContext ctx = getServletContext();
                    Object counter = ctx.getAttribute("studentLoginCount");
                    if (counter instanceof AtomicInteger) {
                        ((AtomicInteger) counter).incrementAndGet();
                    }

                    response.sendRedirect("DashboardServlet");
                } else {
                    request.setAttribute("error", "Invalid username/email or password.");
                    request.getRequestDispatcher("login.jsp").forward(request, response);
                }
            }
        } catch (SQLException e) {
            request.setAttribute("error", "Database error: " + e.getMessage());
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }
}
