<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.codequest.util.Html" %>
<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp?msg=Please+log+in+to+continue.");
        return;
    }
    String status = (String) request.getAttribute("resultStatus");
    if (status == null) {                         // opened directly
        response.sendRedirect("MissionServlet");
        return;
    }
    String message = (String) request.getAttribute("resultMessage");
    String title = (String) request.getAttribute("missionTitle");
    String selected = (String) request.getAttribute("selected");
    String correctLetter = (String) request.getAttribute("correctLetter");
    String correctText = (String) request.getAttribute("correctText");
    Integer xpAwarded = (Integer) request.getAttribute("xpAwarded");
    Integer totalXp = (Integer) request.getAttribute("totalXp");
    Integer level = (Integer) request.getAttribute("level");
    Boolean leveledUp = (Boolean) request.getAttribute("leveledUp");
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Mission Result - CodeQuest</title>
  <link rel="stylesheet" href="css/style.css">
</head>
<body>
<%@ include file="includes/navbar.jsp" %>

<div class="container medium">
  <div class="card result-box <%= "correct".equals(status) ? "result-correct" : "result-wrong" %>">

  <% if ("correct".equals(status)) { %>
    <div class="big">&#127881;</div>
    <h2>Correct Answer!</h2>
    <p class="subtitle">Mission: <b><%= Html.esc(title) %></b></p>
    <p><span class="badge badge-xp" style="font-size:1.1rem">+<%= xpAwarded %> XP</span></p>
    <p class="subtitle">Total XP: <b><%= totalXp %></b> &middot; Level: <b><%= level %></b></p>
    <% if (leveledUp != null && leveledUp) { %>
      <div class="msg msg-success">&#11088; LEVEL UP! You reached Level <%= level %>!</div>
    <% } %>

  <% } else if ("wrong".equals(status)) { %>
    <div class="big">&#128546;</div>
    <h2>Wrong Answer</h2>
    <p class="subtitle">Mission: <b><%= Html.esc(title) %></b></p>
    <p>You selected <b><%= Html.esc(selected) %></b>. No XP awarded this time.</p>
    <p class="subtitle">The correct answer was <b><%= Html.esc(correctLetter) %>. <%= Html.esc(correctText) %></b></p>
    <p class="subtitle">Total XP: <b><%= totalXp %></b> &middot; Level: <b><%= level %></b></p>

  <% } else if ("duplicate".equals(status)) { %>
    <div class="big">&#9888;</div>
    <h2>Already Attempted</h2>
    <div class="msg msg-info"><%= Html.esc(message) %></div>

  <% } else { %>
    <div class="big">&#10060;</div>
    <h2>Could not evaluate</h2>
    <div class="msg msg-error"><%= Html.esc(message) %></div>
  <% } %>

    <br>
    <a class="btn" href="MissionServlet">Back to Missions</a>
    <a class="btn btn-purple" href="DashboardServlet">My Dashboard</a>
    <a class="btn btn-outline" href="leaderboard.jsp">Leaderboard</a>
  </div>
</div>
</body>
</html>
