package com.codequest.servlet;

import com.codequest.db.DBConnection;
import com.codequest.util.Html;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.Arrays;
import java.util.List;

/** Module 6 - Admin adds a question (protected by AdminAuthFilter). */
@WebServlet("/AddQuestionServlet")
public class AddQuestionServlet extends HttpServlet {

    private static final List<String> CATEGORIES = Arrays.asList("Java", "SQL", "DSA");
    private static final List<String> DIFFICULTIES = Arrays.asList("Easy", "Medium", "Hard");
    private static final List<String> ANSWERS = Arrays.asList("A", "B", "C", "D");

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.sendRedirect("add-question.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String title = Html.param(request, "title");
        String description = Html.param(request, "description");
        String category = Html.param(request, "category");
        String difficulty = Html.param(request, "difficulty");
        String optA = Html.param(request, "optionA");
        String optB = Html.param(request, "optionB");
        String optC = Html.param(request, "optionC");
        String optD = Html.param(request, "optionD");
        String correct = Html.param(request, "correctAnswer").toUpperCase();
        String xpText = Html.param(request, "xpReward");

        String error = null;
        int xp = 0;

        if (title.isEmpty() || description.isEmpty() || optA.isEmpty() || optB.isEmpty()
                || optC.isEmpty() || optD.isEmpty() || xpText.isEmpty()) {
            error = "Please fill in all the fields.";
        } else if (title.length() > 150) {
            error = "Title must not be longer than 150 characters.";
        } else if (optA.length() > 255 || optB.length() > 255 || optC.length() > 255 || optD.length() > 255) {
            error = "Each answer choice must not be longer than 255 characters.";
        } else if (!CATEGORIES.contains(category)) {
            error = "Please select a valid category (Java, SQL or DSA).";
        } else if (!DIFFICULTIES.contains(difficulty)) {
            error = "Please select a valid difficulty level.";
        } else if (!ANSWERS.contains(correct)) {
            error = "Please select the correct answer (A, B, C or D).";
        } else {
            try {
                xp = Integer.parseInt(xpText);
                if (xp < 1 || xp > 1000) {
                    error = "XP reward must be between 1 and 1000.";
                }
            } catch (NumberFormatException e) {
                error = "XP reward must be a whole number.";
            }
        }

        if (error == null) {
            Integer adminId = (Integer) request.getSession().getAttribute("adminId");
            String sql = "INSERT INTO missions (title, description, category, difficulty, option_a, option_b, "
                    + "option_c, option_d, correct_answer, xp_reward, created_by) VALUES (?,?,?,?,?,?,?,?,?,?,?)";
            try (Connection con = DBConnection.getConnection();
                 PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setString(1, title);
                ps.setString(2, description);
                ps.setString(3, category);
                ps.setString(4, difficulty);
                ps.setString(5, optA);
                ps.setString(6, optB);
                ps.setString(7, optC);
                ps.setString(8, optD);
                ps.setString(9, correct);
                ps.setInt(10, xp);
                ps.setInt(11, adminId);
                ps.executeUpdate();
            } catch (SQLException e) {
                error = "Database error: " + e.getMessage();
            }
        }

        if (error != null) {
            request.setAttribute("error", error);
            request.getRequestDispatcher("add-question.jsp").forward(request, response);
        } else {
            response.sendRedirect("add-question.jsp?success=1");
        }
    }
}
