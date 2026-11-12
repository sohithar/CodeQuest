<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.codequest.util.Html" %>
<%
    if (session.getAttribute("adminId") == null) {
        response.sendRedirect("admin-login.jsp?msg=Please+log+in+as+Admin+to+continue.");
        return;
    }
    String error = (String) request.getAttribute("error");
    boolean success = request.getParameter("success") != null;

    // keep entered values when validation fails
    String title = Html.esc(request.getParameter("title"));
    String description = Html.esc(request.getParameter("description"));
    String category = request.getParameter("category") == null ? "" : request.getParameter("category");
    String difficulty = request.getParameter("difficulty") == null ? "" : request.getParameter("difficulty");
    String optA = Html.esc(request.getParameter("optionA"));
    String optB = Html.esc(request.getParameter("optionB"));
    String optC = Html.esc(request.getParameter("optionC"));
    String optD = Html.esc(request.getParameter("optionD"));
    String correct = request.getParameter("correctAnswer") == null ? "" : request.getParameter("correctAnswer");
    String xp = request.getParameter("xpReward") == null ? "10" : request.getParameter("xpReward");
    String[] categories = {"Java", "SQL", "DSA"};
    String[] difficulties = {"Easy", "Medium", "Hard"};
    String[] letters = {"A", "B", "C", "D"};
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Add Question - CodeQuest</title>
  <link rel="stylesheet" href="css/style.css">
</head>
<body>
<%@ include file="includes/navbar.jsp" %>

<div class="container medium">
  <div class="card">
    <h1 class="page-title">Add New Question</h1>
    <p class="subtitle">The question is stored in the database and shown to students automatically.</p>

    <% if (success) { %>
      <div class="msg msg-success">Question added successfully! <a href="ViewQuestionsServlet">View all questions</a></div>
    <% } %>
    <% if (error != null) { %>
      <div class="msg msg-error"><%= Html.esc(error) %></div>
    <% } %>

    <form action="AddQuestionServlet" method="post">
      <div class="form-group">
        <label for="title">Question title</label>
        <input type="text" id="title" name="title" maxlength="150" value="<%= title %>" required>
      </div>
      <div class="form-group">
        <label for="description">Description / question text</label>
        <textarea id="description" name="description" required><%= description %></textarea>
      </div>

      <div class="form-row">
        <div class="form-group">
          <label for="category">Category</label>
          <select id="category" name="category" required>
            <option value="">-- Select --</option>
            <% for (String c : categories) { %>
              <option value="<%= c %>" <%= c.equals(category) ? "selected" : "" %>><%= c %></option>
            <% } %>
          </select>
        </div>
        <div class="form-group">
          <label for="difficulty">Difficulty</label>
          <select id="difficulty" name="difficulty" required>
            <option value="">-- Select --</option>
            <% for (String d : difficulties) { %>
              <option value="<%= d %>" <%= d.equals(difficulty) ? "selected" : "" %>><%= d %></option>
            <% } %>
          </select>
        </div>
      </div>

      <div class="form-row">
        <div class="form-group"><label for="optionA">Choice A</label><input type="text" id="optionA" name="optionA" maxlength="255" value="<%= optA %>" required></div>
        <div class="form-group"><label for="optionB">Choice B</label><input type="text" id="optionB" name="optionB" maxlength="255" value="<%= optB %>" required></div>
        <div class="form-group"><label for="optionC">Choice C</label><input type="text" id="optionC" name="optionC" maxlength="255" value="<%= optC %>" required></div>
        <div class="form-group"><label for="optionD">Choice D</label><input type="text" id="optionD" name="optionD" maxlength="255" value="<%= optD %>" required></div>
      </div>

      <div class="form-row">
        <div class="form-group">
          <label for="correctAnswer">Correct answer</label>
          <select id="correctAnswer" name="correctAnswer" required>
            <option value="">-- Select --</option>
            <% for (String l : letters) { %>
              <option value="<%= l %>" <%= l.equals(correct) ? "selected" : "" %>>Choice <%= l %></option>
            <% } %>
          </select>
        </div>
        <div class="form-group">
          <label for="xpReward">XP reward</label>
          <input type="number" id="xpReward" name="xpReward" min="1" max="1000" value="<%= Html.esc(xp) %>" required>
        </div>
      </div>

      <button type="submit" class="btn btn-block">Save Question</button>
    </form>
  </div>
</div>
</body>
</html>
