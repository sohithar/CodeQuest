package com.codequest.filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

/** Blocks every admin-only page / servlet unless an administrator is logged in. */
@WebFilter(urlPatterns = {
        "/admin-dashboard.jsp", "/add-question.jsp", "/view-questions.jsp",
        "/AddQuestionServlet", "/ViewQuestionsServlet", "/DeleteQuestionServlet"
})
public class AdminAuthFilter implements Filter {
    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;
        HttpSession session = request.getSession(false);

        if (session != null && session.getAttribute("adminId") != null) {
            chain.doFilter(req, res);
        } else {
            String text = (session != null && session.getAttribute("userId") != null)
                    ? "Access denied. This area is for administrators only."
                    : "Please log in as Admin to continue.";
            response.sendRedirect(request.getContextPath() + "/admin-login.jsp?msg="
                    + URLEncoder.encode(text, StandardCharsets.UTF_8));
        }
    }
}
