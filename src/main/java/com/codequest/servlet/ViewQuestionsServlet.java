package com.codequest.servlet;

import com.codequest.db.DBConnection;
import com.codequest.model.Mission;
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
import java.util.ArrayList;
import java.util.List;

/** Module 7 - loads all questions with JDBC and forwards them to view-questions.jsp. */
@WebServlet("/ViewQuestionsServlet")
public class ViewQuestionsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<Mission> missions = new ArrayList<>();
        String sql = "SELECT id, title, category, difficulty, xp_reward FROM missions "
                + "ORDER BY FIELD(category,'Java','SQL','DSA'), FIELD(difficulty,'Easy','Medium','Hard'), id";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Mission m = new Mission();
                m.setId(rs.getInt("id"));
                m.setTitle(rs.getString("title"));
                m.setCategory(rs.getString("category"));
                m.setDifficulty(rs.getString("difficulty"));
                m.setXpReward(rs.getInt("xp_reward"));
                missions.add(m);
            }
        } catch (SQLException e) {
            request.setAttribute("error", "Database error: " + e.getMessage());
        }

        request.setAttribute("missions", missions);
        request.getRequestDispatcher("view-questions.jsp").forward(request, response);
    }
}
