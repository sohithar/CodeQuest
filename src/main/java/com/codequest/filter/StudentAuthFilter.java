package com.codequest.filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

/** Blocks every student-only page / servlet unless a student is logged in. */
@WebFilter(urlPatterns = {
        "/DashboardServlet", "/MissionServlet", "/SubmitAnswerServlet",
        "/dashboard.jsp", "/missions.jsp", "/mission-result.jsp"
})
public class StudentAuthFilter implements Filter {
    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;
        HttpSession session = request.getSession(false);

        if (session != null && session.getAttribute("userId") != null) {
            chain.doFilter(req, res);
        } else {
            String msg = URLEncoder.encode("Please log in to continue.", StandardCharsets.UTF_8);
            response.sendRedirect(request.getContextPath() + "/login.jsp?msg=" + msg);
        }
    }
}
