<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.codequest.util.Html" %>
<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp?msg=Please+log+in+to+continue.");
        return;
    }
    if (request.getAttribute("xp") == null && request.getAttribute("error") == null) {
        response.sendRedirect("DashboardServlet");   // opened directly -> load data through the Servlet
        return;
    }
    String error = (String) request.getAttribute("error");
    String name = (String) request.getAttribute("dbUsername");
    if (name == null) name = (String) session.getAttribute("username");
    Integer xp = (Integer) request.getAttribute("xp");
    Integer level = (Integer) request.getAttribute("level");
    Integer correctCount = (Integer) request.getAttribute("correctCount");
    Integer attemptCount = (Integer) request.getAttribute("attemptCount");
    Integer totalMissions = (Integer) request.getAttribute("totalMissions");
    Integer rank = (Integer) request.getAttribute("rank");
    Integer xpIntoLevel = (Integer) request.getAttribute("xpIntoLevel");
    Integer xpPerLevel = (Integer) request.getAttribute("xpPerLevel");
    Integer xpToNext = (Integer) request.getAttribute("xpToNext");
    Integer percent = (Integer) request.getAttribute("progressPercent");
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>My Dashboard - CodeQuest</title>
  <link rel="stylesheet" href="css/style.css">
</head>
<body>
<%@ include file="includes/navbar.jsp" %>

<div class="container">
  <h1 class="page-title">Welcome, <%= Html.esc(name) %>!</h1>
  <p class="subtitle">Here is your learning progress.</p>

  <% if (error != null) { %>
    <div class="msg msg-error"><%= Html.esc(error) %></div>
  <% } %>

  <% if (xp != null) { %>
  <div class="stats">
    <div class="stat"><div class="num"><%= xp %></div><div class="lbl">Total XP</div></div>
    <div class="stat"><div class="num"><%= level %></div><div class="lbl">Current Level</div></div>
    <div class="stat"><div class="num"><%= correctCount %> / <%= totalMissions %></div><div class="lbl">Missions Completed Correctly</div></div>
    <div class="stat"><div class="num">#<%= rank %></div><div class="lbl">Leaderboard Rank</div></div>
  </div>

  <div class="card">
    <h3>Progress to Level <%= level + 1 %></h3>
    <div class="progress">
      <div class="progress-bar" style="width: <%= percent %>%"><%= percent %>%</div>
    </div>
    <p class="subtitle" style="margin:0"><%= xpIntoLevel %> / <%= xpPerLevel %> XP in this level &middot; <b><%= xpToNext %> XP</b> to go</p>
    <p class="subtitle" style="margin:8px 0 0">Attempted missions: <%= attemptCount %> (each mission can be attempted only once)</p>
  </div>

  <br>
  <a class="btn" href="MissionServlet">Play Missions</a>
  <a class="btn btn-purple" href="leaderboard.jsp">View Leaderboard</a>
  <% } %>
</div>
</body>
</html>
