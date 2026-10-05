<%@page contentType="text/html" pageEncoding="UTF-8"%>
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
    Integer idEditar = (Integer) request.getAttribute("idEditar");
    if (idEditar == null) {                      // si entran directo al .jsp, pasan por el servlet
        response.sendRedirect("AdminUsuariosServlet");
        return;
    }
    String usuarioEditar = (String) request.getAttribute("usuarioEditar");
    String rolEditar = (String) request.getAttribute("rolEditar");
    String error = request.getParameter("error");

    String textoError = null;
    if ("vacio".equals(error)) {
        textoError = "El usuario no puede estar vacío.";
    } else if ("rol".equals(error)) {
        textoError = "El rol seleccionado no es válido.";
    } else if ("existe".equals(error)) {
        textoError = "Ese nombre de usuario ya lo tiene otra persona.";
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tienda Nueva - Editar usuario</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="index.css">
    <style>
        select {
            width: 100%; padding: 12px; border: 1px solid var(--borde); border-radius: var(--radius-inputs);
            background: #FFFFFF; color: var(--texto-oscuro); font-family: 'Poppins', sans-serif;
            font-size: 14px; outline: none;
        }
        select:focus { border-color: var(--verde-principal); box-shadow: 0 0 0 3px rgba(20, 184, 166, 0.12); }
        .ayuda { margin-top: 6px; color: var(--texto-secundario); font-size: 12px; }
    </style>
</head>
<body>
    <main class="login-container">
        <section class="login-card">

            <h1>EDITAR USUARIO</h1>
            <p class="subtitulo">Usuario número <%= idEditar %></p>

            <% if (textoError != null) { %>
            <div class="mensaje-error" role="alert">
                <span class="icono-error" aria-hidden="true">!</span>
                <div>
                    <strong>No se pudo guardar</strong>
                    <p><%= textoError %></p>
                </div>
            </div>
            <% } %>

            <form action="AdminUsuariosServlet" method="post">
                <input type="hidden" name="accion" value="actualizar">
                <input type="hidden" name="id" value="<%= idEditar %>">

                <div class="campo">
                    <label for="usuario">Usuario</label>
                    <input type="text" id="usuario" name="usuario" maxlength="50"
                           value="<%= esc(usuarioEditar) %>" required>
                </div>

                <div class="campo">
                    <label for="clave">Nueva contraseña</label>
                    <input type="password" id="clave" name="clave" maxlength="100"
                           placeholder="Dejar vacío para conservar la actual" autocomplete="new-password">
                    <p class="ayuda">Si no escribe nada, la contraseña no cambia.</p>
                </div>

                <div class="campo">
                    <label for="rol">Rol</label>
                    <select id="rol" name="rol" required>
                        <option value="Vendedor" <%= "Vendedor".equals(rolEditar) ? "selected" : "" %>>Vendedor</option>
                        <option value="Administrador" <%= "Administrador".equals(rolEditar) ? "selected" : "" %>>Administrador</option>
                    </select>
                </div>

                <button type="submit">Guardar cambios</button>
            </form>

            <div class="links">
                <a href="AdminUsuariosServlet">Cancelar y volver a la lista</a>
            </div>

        </section>
    </main>
</body>
</html>
