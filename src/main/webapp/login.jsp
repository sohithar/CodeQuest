<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.codequest.util.Html" %>
<%
    String error = (String) request.getAttribute("error");
    String msg = request.getParameter("msg");
    boolean registered = request.getParameter("registered") != null;
    boolean loggedOut = request.getParameter("loggedout") != null;

    // Cookie demonstration: pre-fill the username remembered at the last login
    String identifier = request.getParameter("identifier");
    boolean rememberChecked = false;
    if (identifier == null) {
        identifier = "";
        Cookie[] cookies = request.getCookies();
        if (cookies != null) {
            for (Cookie c : cookies) {
                if ("cq_username".equals(c.getName())) {
                    identifier = c.getValue();
                    rememberChecked = true;
                }
            }
        }
    } else {
        rememberChecked = request.getParameter("remember") != null;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Student Login - CodeQuest</title>
  <link rel="stylesheet" href="css/style.css">
</head>
<body>
<%@ include file="includes/navbar.jsp" %>

<div class="container narrow">
  <div class="card">
    <h1 class="page-title">Student Login</h1>
    <p class="subtitle">Welcome back, adventurer!</p>

    <% if (registered) { %>
      <div class="msg msg-success">Registration successful! Please log in.</div>
    <% } %>
    <% if (loggedOut) { %>
      <div class="msg msg-info">You have been logged out successfully.</div>
    <% } %>
    <% if (msg != null && !msg.trim().isEmpty()) { %>
      <div class="msg msg-info"><%= Html.esc(msg) %></div>
    <% } %>
    <% if (error != null) { %>
      <div class="msg msg-error"><%= Html.esc(error) %></div>
    <% } %>

    <form action="LoginServlet" method="post">
      <div class="form-group">
        <label for="identifier">Username or Email</label>
        <input type="text" id="identifier" name="identifier" value="<%= Html.esc(identifier) %>" required>
      </div>
      <div class="form-group">
        <label for="password">Password</label>
        <input type="password" id="password" name="password" required>
      </div>
      <div class="checkbox-row">
        <input type="checkbox" id="remember" name="remember" <%= rememberChecked ? "checked" : "" %>>
        <label for="remember" style="margin:0">Remember my username (cookie)</label>
      </div>
      <button type="submit" class="btn btn-block">Log In</button>
    </form>
    <p class="form-footer">New here? <a href="register.jsp">Create an account</a></p>
  </div>
</div>
</body>
</html>
