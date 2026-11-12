<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, com.codequest.db.DBConnection, com.codequest.util.Html" %>
<%
    String me = (String) session.getAttribute("username");
    String error = null;
    String sql = "SELECT u.username, u.level_no, u.xp, "
            + "(SELECT COUNT(*) FROM mission_submissions s WHERE s.user_id = u.id AND s.is_correct = 1) AS completed "
            + "FROM users u ORDER BY u.xp DESC, completed DESC, u.username ASC";
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta http-equiv="refresh" content="30">
  <title>Leaderboard - CodeQuest</title>
  <link rel="stylesheet" href="css/style.css">
</head>
<body>
<%@ include file="includes/navbar.jsp" %>

<div class="container">
  <h1 class="page-title">&#127942; Global Leaderboard</h1>
  <p class="subtitle">Ranked by total XP. This page refreshes automatically every 30 seconds.</p>

  <div class="table-wrap">
    <table>
      <tr><th>Rank</th><th>Player</th><th>Level</th><th>Completed Missions</th><th>Total XP</th></tr>
<%
    int rank = 0;
    try (Connection con = DBConnection.getConnection();
         PreparedStatement ps = con.prepareStatement(sql);
         ResultSet rs = ps.executeQuery()) {

        while (rs.next()) {
            rank++;
            String player = rs.getString("username");
            String rowClass = (rank <= 3 ? "rank-" + rank : "");
            if (player.equals(me)) rowClass += " me";
            String indicator = (rank == 1) ? "&#129351;" : (rank == 2) ? "&#129352;" : (rank == 3) ? "&#129353;" : "#" + rank;
%>
      <tr class="<%= rowClass %>">
        <td class="<%= rank <= 3 ? "medal" : "" %>"><%= indicator %></td>
        <td><%= Html.esc(player) %><%= player.equals(me) ? " (you)" : "" %></td>
        <td>Level <%= rs.getInt("level_no") %></td>
        <td><%= rs.getInt("completed") %></td>
        <td><b><%= rs.getInt("xp") %> XP</b></td>
      </tr>
<%
        }
    } catch (SQLException e) {
        error = "Database error: " + e.getMessage();
    }

    if (error != null) {
%>
      <tr><td colspan="5" class="empty"><span class="failed"><%= Html.esc(error) %></span></td></tr>
<%
    } else if (rank == 0) {
%>
      <tr><td colspan="5" class="empty">No players yet. Be the first to <a href="register.jsp">register</a> and earn XP!</td></tr>
<%
    }
%>
    </table>
  </div>
</div>
</body>
</html>
