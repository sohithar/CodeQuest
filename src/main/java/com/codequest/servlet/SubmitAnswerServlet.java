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
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * Module 10 - evaluates an answer.
 * Saving the submission and updating the student's XP/level happen in ONE database transaction.
 * One attempt per mission is enforced by a check AND by the UNIQUE(user_id, mission_id) constraint.
 */
@WebServlet("/SubmitAnswerServlet")
public class SubmitAnswerServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.sendRedirect("MissionServlet");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int userId = (Integer) request.getSession(false).getAttribute("userId");
        Object xpl = getServletContext().getAttribute("xpPerLevel");
        int xpPerLevel = (xpl instanceof Integer) ? (Integer) xpl : 100;

        String answer = Html.param(request, "answer").toUpperCase();
        int missionId;
        try {
            missionId = Integer.parseInt(Html.param(request, "missionId"));
        } catch (NumberFormatException e) {
            missionId = -1;
        }

        if (missionId < 0 || !answer.matches("[ABCD]")) {
            show(request, response, "error",
                    "Please select one answer choice before submitting.");
            return;
        }

        Connection con = null;
        try {
            con = DBConnection.getConnection();
            con.setAutoCommit(false);

            // lock the student row so two quick submissions cannot corrupt XP
            int oldXp;
            int oldLevel;
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT xp, level_no FROM users WHERE id = ? FOR UPDATE")) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        con.rollback();
                        show(request, response, "error", "Student account not found.");
                        return;
                    }
                    oldXp = rs.getInt("xp");
                    oldLevel = rs.getInt("level_no");
                }
            }

            // one attempt per mission
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT id FROM mission_submissions WHERE user_id = ? AND mission_id = ?")) {
                ps.setInt(1, userId);
                ps.setInt(2, missionId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        con.rollback();
                        show(request, response, "duplicate",
                                "You have already attempted this mission. Only one attempt is allowed.");
                        return;
                    }
                }
            }

            // read the correct answer from the database
            String title;
            String correctAnswer;
            String correctText;
            int xpReward;
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT title, correct_answer, xp_reward, option_a, option_b, option_c, option_d "
                            + "FROM missions WHERE id = ?")) {
                ps.setInt(1, missionId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        con.rollback();
                        show(request, response, "error", "This mission does not exist any more.");
                        return;
                    }
                    title = rs.getString("title");
                    correctAnswer = rs.getString("correct_answer");
                    xpReward = rs.getInt("xp_reward");
                    correctText = rs.getString("option_" + correctAnswer.toLowerCase());
                }
            }

            boolean correct = answer.equals(correctAnswer);
            int xpAwarded = correct ? xpReward : 0;

            // save the submission
            try (PreparedStatement ps = con.prepareStatement(
                    "INSERT INTO mission_submissions (user_id, mission_id, selected_answer, is_correct, xp_awarded) "
                            + "VALUES (?, ?, ?, ?, ?)")) {
                ps.setInt(1, userId);
                ps.setInt(2, missionId);
                ps.setString(3, answer);
                ps.setInt(4, correct ? 1 : 0);
                ps.setInt(5, xpAwarded);
                ps.executeUpdate();
            }

            // award XP and update the level
            int newXp = oldXp + xpAwarded;
            int newLevel = newXp / xpPerLevel + 1;
            if (correct) {
                try (PreparedStatement ps = con.prepareStatement(
                        "UPDATE users SET xp = ?, level_no = ? WHERE id = ?")) {
                    ps.setInt(1, newXp);
                    ps.setInt(2, newLevel);
                    ps.setInt(3, userId);
                    ps.executeUpdate();
                }
            }

            con.commit();

            request.setAttribute("missionTitle", title);
            request.setAttribute("selected", answer);
            request.setAttribute("correctLetter", correctAnswer);
            request.setAttribute("correctText", correctText);
            request.setAttribute("xpAwarded", xpAwarded);
            request.setAttribute("totalXp", newXp);
            request.setAttribute("level", newLevel);
            request.setAttribute("leveledUp", correct && newLevel > oldLevel);
            show(request, response, correct ? "correct" : "wrong", null);

        } catch (SQLException e) {
            rollbackQuietly(con);
            if (e.getErrorCode() == 1062) {
                show(request, response, "duplicate",
                        "You have already attempted this mission. Only one attempt is allowed.");
            } else {
                show(request, response, "error", "Database error: " + e.getMessage());
            }
        } finally {
            if (con != null) {
                try {
                    con.setAutoCommit(true);
                    con.close();
                } catch (SQLException ignored) {
                    // nothing more to do
                }
            }
        }
    }

    private void rollbackQuietly(Connection con) {
        if (con != null) {
            try {
                con.rollback();
            } catch (SQLException ignored) {
                // nothing more to do
            }
        }
    }

    private void show(HttpServletRequest request, HttpServletResponse response, String status, String message)
            throws ServletException, IOException {
        request.setAttribute("resultStatus", status);
        if (message != null) request.setAttribute("resultMessage", message);
        request.getRequestDispatcher("mission-result.jsp").forward(request, response);
    }
}
