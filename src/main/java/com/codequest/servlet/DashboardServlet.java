package com.codequest.servlet;

import com.codequest.db.DBConnection;
import jakarta.servlet.ServletException;
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

/** Module 8 - Student dashboard. Reads the student id from the session and loads fresh statistics. */
@WebServlet("/DashboardServlet")
public class DashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        int userId = (Integer) session.getAttribute("userId");

        Object xpl = getServletContext().getAttribute("xpPerLevel");
        int xpPerLevel = (xpl instanceof Integer) ? (Integer) xpl : 100;

        try (Connection con = DBConnection.getConnection()) {

            // 1. student details
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT username, email, xp, level_no FROM users WHERE id = ?")) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        // account no longer exists -> end the session
                        session.invalidate();
                        response.sendRedirect("login.jsp?msg=Account+not+found.+Please+log+in+again.");
                        return;
                    }
                    int xp = rs.getInt("xp");
                    int xpIntoLevel = xp % xpPerLevel;
                    request.setAttribute("dbUsername", rs.getString("username"));
                    request.setAttribute("email", rs.getString("email"));
                    request.setAttribute("xp", xp);
                    request.setAttribute("level", rs.getInt("level_no"));
                    request.setAttribute("xpIntoLevel", xpIntoLevel);
                    request.setAttribute("xpPerLevel", xpPerLevel);
                    request.setAttribute("xpToNext", xpPerLevel - xpIntoLevel);
                    request.setAttribute("progressPercent", xpIntoLevel * 100 / xpPerLevel);
                }
            }

            // 2. correctly completed missions
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT COUNT(*) FROM mission_submissions WHERE user_id = ? AND is_correct = 1")) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    rs.next();
                    request.setAttribute("correctCount", rs.getInt(1));
                }
            }

            // 3. all attempts
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT COUNT(*) FROM mission_submissions WHERE user_id = ?")) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    rs.next();
                    request.setAttribute("attemptCount", rs.getInt(1));
                }
            }

            // 4. total missions available
            try (PreparedStatement ps = con.prepareStatement("SELECT COUNT(*) FROM missions");
                 ResultSet rs = ps.executeQuery()) {
                rs.next();
                request.setAttribute("totalMissions", rs.getInt(1));
            }

            // 5. leaderboard rank
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT COUNT(*) + 1 FROM users WHERE xp > (SELECT xp FROM users WHERE id = ?)")) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    rs.next();
                    request.setAttribute("rank", rs.getInt(1));
                }
            }

        } catch (SQLException e) {
            request.setAttribute("error", "Database error: " + e.getMessage());
        }

        request.getRequestDispatcher("dashboard.jsp").forward(request, response);
    }
}
