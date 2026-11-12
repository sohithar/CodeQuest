<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.codequest.util.Html, java.util.concurrent.atomic.AtomicInteger" %>
<%
    if (session.getAttribute("adminId") == null) {
        response.sendRedirect("admin-login.jsp?msg=Please+log+in+as+Admin+to+continue.");
        return;
    }
    String adminName = (String) session.getAttribute("adminName");

    // ServletContext values (set in AppInitListener)
    String appName = (String) application.getAttribute("appName");
    Object loginCounter = application.getAttribute("studentLoginCount");
    int studentLogins = (loginCounter instanceof AtomicInteger) ? ((AtomicInteger) loginCounter).get() : 0;
    Object xpPerLevel = application.getAttribute("xpPerLevel");
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Admin Dashboard - CodeQuest</title>
  <link rel="stylesheet" href="css/style.css">
</head>
<body>
<%@ include file="includes/navbar.jsp" %>

<div class="container">
  <h1 class="page-title">Admin Dashboard</h1>
  <p class="subtitle">Welcome, <b><%= Html.esc(adminName) %></b>. Manage the <%= Html.esc(appName) %> programming questions from here.</p>

  <div class="features" style="padding:0">
    <div class="feature">
      <div class="icon">&#10133;</div>
      <h3>Add Question</h3>
      <p>Create a new Java, SQL or DSA mission.</p>
      <br><a class="btn" href="add-question.jsp">Add Question</a>
    </div>
    <div class="feature">
      <div class="icon">&#128203;</div>
      <h3>View Questions</h3>
      <p>See and manage all existing questions.</p>
      <br><a class="btn btn-purple" href="ViewQuestionsServlet">View Questions</a>
    </div>
    <div class="feature">
      <div class="icon">&#128682;</div>
      <h3>Logout</h3>
      <p>End the admin session safely.</p>
      <br><a class="btn btn-outline" href="AdminLogoutServlet">Logout</a>
    </div>
  </div>

  <div class="stats">
    <div class="stat"><div class="num"><%= studentLogins %></div><div class="lbl">Student logins since server start (ServletContext)</div></div>
    <div class="stat"><div class="num"><%= xpPerLevel %></div><div class="lbl">XP needed per level (context-param)</div></div>
  </div>
</div>
</body>
</html>
