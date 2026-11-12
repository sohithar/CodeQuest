<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List, com.codequest.model.Mission, com.codequest.util.Html" %>
<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp?msg=Please+log+in+to+continue.");
        return;
    }
    @SuppressWarnings("unchecked")
    List<Mission> missions = (List<Mission>) request.getAttribute("missions");
    if (missions == null) {                       // opened directly -> go through the Servlet
        response.sendRedirect("MissionServlet");
        return;
    }
    String error = (String) request.getAttribute("error");
    String selCategory = (String) request.getAttribute("selCategory");
    String selDifficulty = (String) request.getAttribute("selDifficulty");
    if (selCategory == null) selCategory = "";
    if (selDifficulty == null) selDifficulty = "";
    String[] categories = {"Java", "SQL", "DSA"};
    String[] difficulties = {"Easy", "Medium", "Hard"};
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Missions - CodeQuest</title>
  <link rel="stylesheet" href="css/style.css">
</head>
<body>
<%@ include file="includes/navbar.jsp" %>

<div class="container">
  <h1 class="page-title">Programming Missions</h1>
  <p class="subtitle">Choose the correct answer. You get <b>one attempt</b> per mission.</p>

  <% if (error != null) { %>
    <div class="msg msg-error"><%= Html.esc(error) %></div>
  <% } %>

  <form class="card filter-bar" action="MissionServlet" method="get">
    <div class="form-group">
      <label for="category">Category</label>
      <select id="category" name="category">
        <option value="">All</option>
        <% for (String c : categories) { %>
          <option value="<%= c %>" <%= c.equals(selCategory) ? "selected" : "" %>><%= c %></option>
        <% } %>
      </select>
    </div>
    <div class="form-group">
      <label for="difficulty">Difficulty</label>
      <select id="difficulty" name="difficulty">
        <option value="">All</option>
        <% for (String d : difficulties) { %>
          <option value="<%= d %>" <%= d.equals(selDifficulty) ? "selected" : "" %>><%= d %></option>
        <% } %>
      </select>
    </div>
    <button type="submit" class="btn">Filter</button>
    <a class="btn btn-outline" href="MissionServlet">Reset</a>
  </form>

  <% if (missions.isEmpty()) { %>
    <div class="card" style="margin-top:20px"><p class="empty">No missions available yet. Please check back later.</p></div>
  <% } %>

  <%
     for (String cat : categories) {
         boolean hasAny = false;
         for (Mission m : missions) {
             if (m.getCategory().equals(cat)) { hasAny = true; break; }
         }
         if (!hasAny) continue;
  %>
  <h2 class="section-title"><%= cat %> Missions</h2>
  <div class="mission-grid">
    <%
        for (Mission m : missions) {
            if (!m.getCategory().equals(cat)) continue;
            String[] letters = {"A", "B", "C", "D"};
            String[] texts = {m.getOptionA(), m.getOptionB(), m.getOptionC(), m.getOptionD()};
    %>
    <div class="card mission-card">
      <span class="badge badge-<%= m.getCategory() %>"><%= m.getCategory() %></span>
      <span class="badge badge-<%= m.getDifficulty() %>"><%= m.getDifficulty() %></span>
      <span class="badge badge-xp">+<%= m.getXpReward() %> XP</span>
      <h3><%= Html.esc(m.getTitle()) %></h3>
      <p class="desc"><%= Html.escBr(m.getDescription()) %></p>

      <% if (m.isAttempted()) { %>
        <p class="<%= m.isCorrect() ? "done" : "failed" %>">
          <%= m.isCorrect() ? "&#10004; Completed - XP earned" : "&#10008; Attempted - no more attempts allowed" %>
        </p>
      <% } else { %>
        <form action="SubmitAnswerServlet" method="post">
          <input type="hidden" name="missionId" value="<%= m.getId() %>">
          <% for (int i = 0; i < 4; i++) { %>
            <label class="option">
              <input type="radio" name="answer" value="<%= letters[i] %>" required>
              <b><%= letters[i] %>.</b> <%= Html.esc(texts[i]) %>
            </label>
          <% } %>
          <button type="submit" class="btn btn-block">Submit Answer</button>
        </form>
      <% } %>
    </div>
    <% } %>
  </div>
  <% } %>
</div>
</body>
</html>
