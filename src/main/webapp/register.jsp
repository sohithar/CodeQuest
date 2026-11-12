<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.codequest.util.Html" %>
<%
    String error = (String) request.getAttribute("error");
    String username = request.getParameter("username") == null ? "" : request.getParameter("username");
    String email = request.getParameter("email") == null ? "" : request.getParameter("email");
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Register - CodeQuest</title>
  <link rel="stylesheet" href="css/style.css">
  <script>
    function checkForm() {
      var f = document.forms["regForm"];
      if (f.username.value.trim() === "" || f.email.value.trim() === "" ||
          f.password.value === "" || f.confirmPassword.value === "") {
        alert("All fields are required.");
        return false;
      }
      if (f.password.value.length < 6) {
        alert("Password must be at least 6 characters long.");
        return false;
      }
      if (f.password.value !== f.confirmPassword.value) {
        alert("Password and Confirm Password do not match.");
        return false;
      }
      return true;
    }
  </script>
</head>
<body>
<%@ include file="includes/navbar.jsp" %>

<div class="container narrow">
  <div class="card">
    <h1 class="page-title">Create Account</h1>
    <p class="subtitle">Join CodeQuest. You start at Level 1 with 0 XP.</p>

    <% if (error != null) { %>
      <div class="msg msg-error"><%= Html.esc(error) %></div>
    <% } %>

    <form name="regForm" action="RegisterServlet" method="post" onsubmit="return checkForm();">
      <div class="form-group">
        <label for="username">Username</label>
        <input type="text" id="username" name="username" maxlength="30" value="<%= Html.esc(username) %>" placeholder="e.g. code_ninja" required>
      </div>
      <div class="form-group">
        <label for="email">Email address</label>
        <input type="email" id="email" name="email" maxlength="100" value="<%= Html.esc(email) %>" placeholder="you@example.com" required>
      </div>
      <div class="form-group">
        <label for="password">Password</label>
        <input type="password" id="password" name="password" placeholder="At least 6 characters" required>
      </div>
      <div class="form-group">
        <label for="confirmPassword">Confirm password</label>
        <input type="password" id="confirmPassword" name="confirmPassword" required>
      </div>
      <button type="submit" class="btn btn-block">Register</button>
    </form>
    <p class="form-footer">Already have an account? <a href="login.jsp">Log in</a></p>
  </div>
</div>
</body>
</html>
