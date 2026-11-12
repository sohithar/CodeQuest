package com.codequest.db;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * Reusable database connection class shared by every Servlet / JSP.
 * The settings are loaded from the ServletContext (web.xml) by AppInitListener.
 */
public class DBConnection {

    private static String url = "jdbc:mysql://localhost:3306/codequest_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
    private static String user = "root";
    private static String password = "root";

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            System.err.println("MySQL JDBC driver not found. Put mysql-connector-j.jar in WEB-INF/lib.");
        }
    }

    private DBConnection() {
    }

    /** Called once at application start-up with the values from web.xml. */
    public static void configure(String dbUrl, String dbUser, String dbPassword) {
        if (dbUrl != null && !dbUrl.trim().isEmpty()) url = dbUrl.trim();
        if (dbUser != null) user = dbUser;
        if (dbPassword != null) password = dbPassword;
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(url, user, password);
    }
}
