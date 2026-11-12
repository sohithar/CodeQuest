package com.codequest.listener;

import com.codequest.db.DBConnection;
import jakarta.servlet.ServletContext;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

import java.util.concurrent.atomic.AtomicInteger;

/**
 * ServletContext demonstration: reads the context-params from web.xml,
 * configures the shared DBConnection and stores application-wide values.
 */
@WebListener
public class AppInitListener implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        ServletContext ctx = sce.getServletContext();

        // Environment variables (used by Docker) override the web.xml values
        DBConnection.configure(
                pick(System.getenv("DB_URL"), ctx.getInitParameter("db.url")),
                pick(System.getenv("DB_USER"), ctx.getInitParameter("db.user")),
                pick(System.getenv("DB_PASSWORD"), ctx.getInitParameter("db.password")));

        int xpPerLevel = 100;
        try {
            xpPerLevel = Integer.parseInt(ctx.getInitParameter("xpPerLevel"));
        } catch (Exception ignored) {
            // keep default
        }
        if (xpPerLevel < 1) xpPerLevel = 100;

        ctx.setAttribute("appName", ctx.getInitParameter("appName"));
        ctx.setAttribute("xpPerLevel", xpPerLevel);
        ctx.setAttribute("studentLoginCount", new AtomicInteger(0));
        ctx.log("CodeQuest started. XP per level = " + xpPerLevel);
    }

    private static String pick(String env, String fallback) {
        return (env != null && !env.trim().isEmpty()) ? env : fallback;
    }
}
