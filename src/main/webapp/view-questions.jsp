<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List, com.codequest.model.Mission, com.codequest.util.Html" %>
<%
    if (session.getAttribute("adminId") == null) {
        response.sendRedirect("admin-login.jsp?msg=Please+log+in+as+Admin+to+continue.");
        return;
    }
    @SuppressWarnings("unchecked")
    List<Mission> missions = (List<Mission>) request.getAttribute("missions");
    if (missions == null) {                       // opened directly -> go through the Servlet
        response.sendRedirect("ViewQuestionsServlet");
        return;
    }
    String error = (String) request.getAttribute("error");
    String msg = request.getParameter("msg");
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Manage Questions - CodeQuest</title>
  <link rel="stylesheet" href="css/style.css">
</head>
<body>
<%@ include file="includes/navbar.jsp" %>

<div class="container">
  <h1 class="page-title">Manage Questions</h1>
  <p class="subtitle">Total questions: <b><%= missions.size() %></b> &nbsp;|&nbsp; <a href="add-question.jsp">+ Add a new question</a></p>

  <% if (msg != null && !msg.trim().isEmpty()) { %>
    <div class="msg msg-info"><%= Html.esc(msg) %></div>
  <% } %>
  <% if (error != null) { %>
    <div class="msg msg-error"><%= Html.esc(error) %></div>
  <% } %>

  <div class="table-wrap">
    <table>
      <tr>
        <th>#</th><th>Title</th><th>Category</th><th>Difficulty</th><th>XP Reward</th><th>Action</th>
      </tr>
      <% if (missions.isEmpty()) { %>
        <tr><td colspan="6" class="empty">No questions found. Add your first question!</td></tr>
      <% } else {
           for (Mission m : missions) { %>
      <tr>
        <td><%= m.getId() %></td>
        <td><%= Html.esc(m.getTitle()) %></td>
        <td><span class="badge badge-<%= m.getCategory() %>"><%= m.getCategory() %></span></td>
        <td><span class="badge badge-<%= m.getDifficulty() %>"><%= m.getDifficulty() %></span></td>
        <td><span class="badge badge-xp">+<%= m.getXpReward() %> XP</span></td>
        <td>
          <form action="DeleteQuestionServlet" method="post" onsubmit="return confirm('Delete this question and all its submissions?');">
            <input type="hidden" name="id" value="<%= m.getId() %>">
            <button type="submit" class="btn btn-danger">Delete</button>
          </form>
        </td>
      </tr>
      <%   }
         } %>
    </table>
  </div>
</div>
</body>
</html>
