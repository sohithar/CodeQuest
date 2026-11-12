<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.codequest.util.Html" %>
<%
    String error = (String) request.getAttribute("error");
    String msg = request.getParameter("msg");
    boolean loggedOut = request.getParameter("loggedout") != null;
    String username = request.getParameter("username") == null ? "" : request.getParameter("username");
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Admin Login - CodeQuest</title>
  <link rel="stylesheet" href="css/style.css">
</head>
<body>
<%@ include file="includes/navbar.jsp" %>

<div class="container narrow">
  <div class="card">
    <h1 class="page-title">Admin Login</h1>
    <p class="subtitle">Authorised administrators only.</p>

    <% if (loggedOut) { %>
      <div class="msg msg-info">Admin logged out successfully.</div>
    <% } %>
    <% if (msg != null && !msg.trim().isEmpty()) { %>
      <div class="msg msg-info"><%= Html.esc(msg) %></div>
    <% } %>
    <% if (error != null) { %>
      <div class="msg msg-error"><%= Html.esc(error) %></div>
    <% } %>

    <form action="AdminLoginServlet" method="post">
      <div class="form-group">
        <label for="username">Admin username</label>
        <input type="text" id="username" name="username" value="<%= Html.esc(username) %>" required>
      </div>
      <div class="form-group">
        <label for="password">Password</label>
        <input type="password" id="password" name="password" required>
      </div>
      <button type="submit" class="btn btn-purple btn-block">Log In as Admin</button>
    </form>
  </div>
</div>
</body>
</html>
