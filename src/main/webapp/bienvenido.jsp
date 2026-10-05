<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%!
    // Escapa texto para mostrarlo de forma segura dentro de HTML
    private String esc(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
                .replace("\"", "&quot;").replace("'", "&#39;");
    }
%>
<%!
    private String permisos(String rol) {
        return "Administrador".equals(rol) ? "Acceso total al sistema" : "Acceso al módulo de ventas";
    }
%>
<%
    String usuario = (String) session.getAttribute("usuario");
    String rol = (String) session.getAttribute("rol");
    if (usuario == null) {
        response.sendRedirect("index.html");
        return;
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tienda Nueva - Bienvenido</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="index.css">
</head>
<body>
    <main class="login-container">
        <section class="login-card">
            <h1>¡Bienvenido, <%= esc(usuario) %>!</h1>
            <p class="subtitulo">Su rol es: <b><%= esc(rol) %></b></p>
            <p class="subtitulo"><%= permisos(rol) %></p>
            <p class="subtitulo">Hora del servidor: <%= new java.util.Date() %></p>

            <% if ("Administrador".equals(rol)) { %>
            <div class="links" style="justify-content:center; margin-top:0; margin-bottom:15px;">
                <a href="AdminUsuariosServlet">Administrar usuarios</a>
            </div>
            <% } %>

            <div class="links" style="justify-content:center; margin-top:0;">
                <a href="LogoutServlet">Cerrar sesión</a>
            </div>
        </section>
    </main>
</body>
</html>
