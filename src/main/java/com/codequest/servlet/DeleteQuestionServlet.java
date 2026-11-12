package com.codequest.servlet;

import com.codequest.db.DBConnection;
import com.codequest.util.Html;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

/** Extra - Admin can delete a question (its submissions are removed by ON DELETE CASCADE). */
@WebServlet("/DeleteQuestionServlet")
public class DeleteQuestionServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.sendRedirect("ViewQuestionsServlet");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String msg;
        try {
            int id = Integer.parseInt(Html.param(request, "id"));
            try (Connection con = DBConnection.getConnection();
                 PreparedStatement ps = con.prepareStatement("DELETE FROM missions WHERE id = ?")) {
                ps.setInt(1, id);
                msg = ps.executeUpdate() > 0 ? "Question deleted successfully." : "Question not found.";
            }
        } catch (NumberFormatException e) {
            msg = "Invalid question id.";
        } catch (SQLException e) {
            msg = "Database error: " + e.getMessage();
        }
        response.sendRedirect("ViewQuestionsServlet?msg=" + URLEncoder.encode(msg, StandardCharsets.UTF_8));
    }
}
