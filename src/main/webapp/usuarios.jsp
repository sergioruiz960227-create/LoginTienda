<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%!
    // Escapa texto para mostrarlo de forma segura dentro de HTML
    private String esc(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
                .replace("\"", "&quot;").replace("'", "&#39;");
    }
%>
<%
    // Solo un Administrador con sesión puede ver esta página
    String rolSesion = (String) session.getAttribute("rol");
    if (session.getAttribute("usuario") == null || !"Administrador".equals(rolSesion)) {
        response.sendRedirect("index.html");
        return;
    }
    List<String[]> usuarios = (List<String[]>) request.getAttribute("usuarios");
    if (usuarios == null) {                      // si entran directo al .jsp, pasan por el servlet
        response.sendRedirect("AdminUsuariosServlet");
        return;
    }
    String mensaje = request.getParameter("mensaje");
    String error = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tienda Nueva - Administrar usuarios</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="index.css">
    <style>
        .login-card.ancho { width: 720px; }
        .tabla-contenedor { overflow-x: auto; }
        .tabla-usuarios { width: 100%; border-collapse: collapse; font-size: 14px; }
        .tabla-usuarios th, .tabla-usuarios td { padding: 10px 12px; border-bottom: 1px solid var(--borde); text-align: left; }
        .tabla-usuarios th { color: var(--texto-secundario); font-size: 13px; font-weight: 600; }
        .acciones { display: flex; gap: 8px; align-items: center; }
        .btn-editar, .btn-eliminar {
            display: inline-block; width: auto; padding: 6px 12px; border-radius: 8px;
            font-family: 'Poppins', sans-serif; font-size: 13px; font-weight: 500; text-decoration: none;
        }
        .btn-editar { background: #EFF6FF; color: #1D4ED8; border: 1px solid #BFDBFE; }
        .btn-editar:hover { background: #DBEAFE; }
        .btn-eliminar { background: #FEF2F2; color: #B91C1C; border: 1px solid #FECACA; cursor: pointer; }
        .btn-eliminar:hover { background: #FEE2E2; }
        .aviso { margin-bottom: 20px; padding: 12px 14px; border-radius: 10px; font-size: 13px; }
        .aviso-ok { background: #F0FDF4; border: 1px solid #BBF7D0; color: #166534; }
        .aviso-error { background: #FEF2F2; border: 1px solid #FECACA; color: #B91C1C; }
    </style>
</head>
<body>
    <main class="login-container">
        <section class="login-card ancho">

            <h1>ADMINISTRAR USUARIOS</h1>
            <p class="subtitulo">Editar o eliminar los usuarios del sistema</p>

            <% if ("eliminado".equals(mensaje)) { %>
                <div class="aviso aviso-ok">Usuario eliminado correctamente.</div>
            <% } else if ("actualizado".equals(mensaje)) { %>
                <div class="aviso aviso-ok">Usuario actualizado correctamente.</div>
            <% } %>
            <% if ("propio".equals(error)) { %>
                <div class="aviso aviso-error">No se pudo eliminar: no puede eliminar su propio usuario.</div>
            <% } %>

            <div class="tabla-contenedor">
                <table class="tabla-usuarios">
                    <thead>
                        <tr><th>ID</th><th>Usuario</th><th>Rol</th><th>Acciones</th></tr>
                    </thead>
                    <tbody>
                    <% for (String[] u : usuarios) { %>
                        <tr>
                            <td><%= esc(u[0]) %></td>
                            <td><%= esc(u[1]) %></td>
                            <td><%= esc(u[2]) %></td>
                            <td>
                                <div class="acciones">
                                    <a class="btn-editar" href="AdminUsuariosServlet?accion=editar&id=<%= esc(u[0]) %>">Editar</a>
                                    <form action="AdminUsuariosServlet" method="post"
                                          onsubmit="return confirm('¿Seguro que desea eliminar este usuario?');">
                                        <input type="hidden" name="accion" value="eliminar">
                                        <input type="hidden" name="id" value="<%= esc(u[0]) %>">
                                        <button type="submit" class="btn-eliminar">Eliminar</button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                    <% } %>
                    </tbody>
                </table>
            </div>

            <div class="links">
                <a href="bienvenido.jsp">Volver a la bienvenida</a>
            </div>

        </section>
    </main>
</body>
</html>
