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
import java.util.Arrays;
import java.util.List;

/**
 * Module 9 - loads missions from MySQL and forwards them to missions.jsp.
 * NOTE: the correct_answer column is NOT selected, so students never receive it.
 */
@WebServlet("/MissionServlet")
public class MissionServlet extends HttpServlet {

    private static final List<String> CATEGORIES = Arrays.asList("Java", "SQL", "DSA");
    private static final List<String> DIFFICULTIES = Arrays.asList("Easy", "Medium", "Hard");

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int userId = (Integer) request.getSession(false).getAttribute("userId");

        String category = request.getParameter("category");
        String difficulty = request.getParameter("difficulty");
        if (category == null || !CATEGORIES.contains(category)) category = "";
        if (difficulty == null || !DIFFICULTIES.contains(difficulty)) difficulty = "";

        StringBuilder sql = new StringBuilder(
                "SELECT m.id, m.title, m.description, m.category, m.difficulty, "
                + "m.option_a, m.option_b, m.option_c, m.option_d, m.xp_reward, s.is_correct "
                + "FROM missions m "
                + "LEFT JOIN mission_submissions s ON s.mission_id = m.id AND s.user_id = ? "
                + "WHERE 1 = 1 ");
        if (!category.isEmpty()) sql.append("AND m.category = ? ");
        if (!difficulty.isEmpty()) sql.append("AND m.difficulty = ? ");
        sql.append("ORDER BY FIELD(m.category,'Java','SQL','DSA'), "
                + "FIELD(m.difficulty,'Easy','Medium','Hard'), m.id");

        List<Mission> missions = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {

            int i = 1;
            ps.setInt(i++, userId);
            if (!category.isEmpty()) ps.setString(i++, category);
            if (!difficulty.isEmpty()) ps.setString(i++, difficulty);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Mission m = new Mission();
                    m.setId(rs.getInt("id"));
                    m.setTitle(rs.getString("title"));
                    m.setDescription(rs.getString("description"));
                    m.setCategory(rs.getString("category"));
                    m.setDifficulty(rs.getString("difficulty"));
                    m.setOptionA(rs.getString("option_a"));
                    m.setOptionB(rs.getString("option_b"));
                    m.setOptionC(rs.getString("option_c"));
                    m.setOptionD(rs.getString("option_d"));
                    m.setXpReward(rs.getInt("xp_reward"));
                    int isCorrect = rs.getInt("is_correct");
                    boolean attempted = !rs.wasNull();
                    m.setAttempted(attempted);
                    m.setCorrect(attempted && isCorrect == 1);
                    missions.add(m);
                }
            }
        } catch (SQLException e) {
            request.setAttribute("error", "Database error: " + e.getMessage());
        }

        request.setAttribute("missions", missions);
        request.setAttribute("selCategory", category);
        request.setAttribute("selDifficulty", difficulty);
        request.getRequestDispatcher("missions.jsp").forward(request, response);
    }
}
