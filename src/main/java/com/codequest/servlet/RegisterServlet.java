package com.codequest.servlet;

import com.codequest.db.DBConnection;
import com.codequest.util.Html;
import com.codequest.util.PasswordUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.regex.Pattern;

/** Module 2 - Student registration. */
@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {

    private static final Pattern USERNAME = Pattern.compile("^[A-Za-z0-9_]{3,30}$");
    private static final Pattern EMAIL = Pattern.compile("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$");

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.sendRedirect("register.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = Html.param(request, "username");
        String email = Html.param(request, "email").toLowerCase();
        String password = request.getParameter("password") == null ? "" : request.getParameter("password");
        String confirm = request.getParameter("confirmPassword") == null ? "" : request.getParameter("confirmPassword");

        // ---- validation ----
        String error = null;
        if (username.isEmpty() || email.isEmpty() || password.isEmpty() || confirm.isEmpty()) {
            error = "All fields are required.";
        } else if (!USERNAME.matcher(username).matches()) {
            error = "Username must be 3-30 characters (letters, digits and underscore only).";
        } else if (email.length() > 100 || !EMAIL.matcher(email).matches()) {
            error = "Please enter a valid email address.";
        } else if (password.length() < 6) {
            error = "Password must be at least 6 characters long.";
        } else if (!password.equals(confirm)) {
            error = "Password and Confirm Password do not match.";
        }

        if (error == null) {
            try (Connection con = DBConnection.getConnection()) {
                if (exists(con, "SELECT id FROM users WHERE username = ?", username)) {
                    error = "This username is already taken. Please choose another one.";
                } else if (exists(con, "SELECT id FROM users WHERE email = ?", email)) {
                    error = "This email address is already registered.";
                } else {
                    String sql = "INSERT INTO users (username, email, password, xp, level_no) VALUES (?, ?, ?, 0, 1)";
                    try (PreparedStatement ps = con.prepareStatement(sql)) {
                        ps.setString(1, username);
                        ps.setString(2, email);
                        ps.setString(3, PasswordUtil.hash(password));
                        ps.executeUpdate();
                    }
                }
            } catch (SQLException e) {
                if (e.getErrorCode() == 1062) {
                    error = "That username or email is already registered.";
                } else {
                    error = "Database error: " + e.getMessage();
                }
            }
        }

        if (error != null) {
            request.setAttribute("error", error);
            request.getRequestDispatcher("register.jsp").forward(request, response);
        } else {
            response.sendRedirect("login.jsp?registered=1");
        }
    }

    private boolean exists(Connection con, String sql, String value) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, value);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }
}
