<%-- Shared navigation bar (static include). Variable names start with "nb" to avoid clashes. --%>
<%
    Object nbStudentId = session.getAttribute("userId");
    Object nbAdminId = session.getAttribute("adminId");
    String nbStudentName = (String) session.getAttribute("username");
    String nbAdminName = (String) session.getAttribute("adminName");
%>
<nav class="navbar">
  <a class="brand" href="index.html">&#9876; CodeQuest</a>
  <ul class="nav-links">
    <li><a href="index.html">Home</a></li>
<% if (nbAdminId != null) { %>
    <li><a href="admin-dashboard.jsp">Admin Dashboard</a></li>
    <li><a href="add-question.jsp">Add Question</a></li>
    <li><a href="ViewQuestionsServlet">View Questions</a></li>
    <li><a href="leaderboard.jsp">Leaderboard</a></li>
    <li><span class="nav-user">&#128737; <%= com.codequest.util.Html.esc(nbAdminName) %></span></li>
    <li><a href="AdminLogoutServlet">Logout</a></li>
<% } else if (nbStudentId != null) { %>
    <li><a href="DashboardServlet">Dashboard</a></li>
    <li><a href="MissionServlet">Missions</a></li>
    <li><a href="leaderboard.jsp">Leaderboard</a></li>
    <li><span class="nav-user">&#128100; <%= com.codequest.util.Html.esc(nbStudentName) %></span></li>
    <li><a href="LogoutServlet">Logout</a></li>
<% } else { %>
    <li><a href="register.jsp">Register</a></li>
    <li><a href="login.jsp">Student Login</a></li>
    <li><a href="admin-login.jsp">Admin Login</a></li>
    <li><a href="MissionServlet">Missions</a></li>
    <li><a href="leaderboard.jsp">Leaderboard</a></li>
<% } %>
  </ul>
</nav>
