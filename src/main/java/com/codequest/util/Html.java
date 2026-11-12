package com.codequest.util;

import jakarta.servlet.http.HttpServletRequest;

/** Small helpers used by Servlets and JSP scriptlets. */
public class Html {

    private Html() {
    }

    /** Escapes text so it can be printed safely inside HTML (prevents XSS). */
    public static String esc(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }

    /** Escapes text and keeps line breaks. */
    public static String escBr(String s) {
        return esc(s).replace("\r\n", "<br>").replace("\n", "<br>");
    }

    /** Returns a trimmed request parameter, never null. */
    public static String param(HttpServletRequest request, String name) {
        String v = request.getParameter(name);
        return v == null ? "" : v.trim();
    }
}
