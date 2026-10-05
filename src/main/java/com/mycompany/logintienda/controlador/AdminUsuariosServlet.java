package com.mycompany.logintienda.controlador;

import com.mycompany.logintienda.modelo.ConexionBD;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "AdminUsuariosServlet", urlPatterns = {"/AdminUsuariosServlet"})
public class AdminUsuariosServlet extends HttpServlet {

    // Solo un Administrador con sesión activa puede usar este servlet
    private boolean esAdministrador(HttpServletRequest request) {
        HttpSession sesion = request.getSession(false);
        return sesion != null && "Administrador".equals(sesion.getAttribute("rol"));
    }

    // GET: listar usuarios o mostrar el formulario de edición
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!esAdministrador(request)) {
            response.sendRedirect("index.html");
            return;
        }

        String accion = request.getParameter("accion");

        try (Connection con = ConexionBD.getConexion()) {

            if ("editar".equals(accion)) {
                int id = Integer.parseInt(request.getParameter("id"));
                try (PreparedStatement ps = con.prepareStatement(
                        "SELECT id, usuario, rol FROM usuario WHERE id = ?")) {
                    ps.setInt(1, id);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            request.setAttribute("idEditar", rs.getInt("id"));
                            request.setAttribute("usuarioEditar", rs.getString("usuario"));
                            request.setAttribute("rolEditar", rs.getString("rol"));
                            request.getRequestDispatcher("editar_usuario.jsp").forward(request, response);
                            return;
                        }
                    }
                }
                response.sendRedirect("AdminUsuariosServlet");
                return;
            }

            // Por defecto: listar todos los usuarios
            List<String[]> lista = new ArrayList<>();
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT id, usuario, rol FROM usuario ORDER BY id");
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    lista.add(new String[]{
                        String.valueOf(rs.getInt("id")), rs.getString("usuario"), rs.getString("rol")});
                }
            }
            request.setAttribute("usuarios", lista);
            request.getRequestDispatcher("usuarios.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect("AdminUsuariosServlet");
        } catch (SQLException e) {
            throw new ServletException("Error al consultar los usuarios", e);
        }
    }

    // POST: eliminar o actualizar un usuario
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!esAdministrador(request)) {
            response.sendRedirect("index.html");
            return;
        }

        request.setCharacterEncoding("UTF-8");
        HttpSession sesion = request.getSession(false);
        String usuarioActual = (String) sesion.getAttribute("usuario");
        String accion = request.getParameter("accion");

        try (Connection con = ConexionBD.getConexion()) {

            if ("eliminar".equals(accion)) {
                int id = Integer.parseInt(request.getParameter("id"));
                // El administrador no puede eliminarse a sí mismo
                try (PreparedStatement ps = con.prepareStatement(
                        "DELETE FROM usuario WHERE id = ? AND usuario <> ?")) {
                    ps.setInt(1, id);
                    ps.setString(2, usuarioActual);
                    int filas = ps.executeUpdate();
                    response.sendRedirect("AdminUsuariosServlet?"
                            + (filas > 0 ? "mensaje=eliminado" : "error=propio"));
                }
                return;
            }

            if ("actualizar".equals(accion)) {
                int id = Integer.parseInt(request.getParameter("id"));
                String usuario = request.getParameter("usuario");
                String clave = request.getParameter("clave");
                String rol = request.getParameter("rol");
                String volver = "AdminUsuariosServlet?accion=editar&id=" + id;

                if (usuario == null || rol == null || usuario.trim().isEmpty()) {
                    response.sendRedirect(volver + "&error=vacio");
                    return;
                }
                usuario = usuario.trim();
                if (!rol.equals("Administrador") && !rol.equals("Vendedor")) {
                    response.sendRedirect(volver + "&error=rol");
                    return;
                }

                // ¿Otro usuario ya tiene ese nombre?
                try (PreparedStatement ps = con.prepareStatement(
                        "SELECT id FROM usuario WHERE usuario = ? AND id <> ?")) {
                    ps.setString(1, usuario);
                    ps.setInt(2, id);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            response.sendRedirect(volver + "&error=existe");
                            return;
                        }
                    }
                }

                // Nombre actual (para saber si el administrador se está editando a sí mismo)
                String nombreAnterior = null;
                try (PreparedStatement ps = con.prepareStatement(
                        "SELECT usuario FROM usuario WHERE id = ?")) {
                    ps.setInt(1, id);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            nombreAnterior = rs.getString("usuario");
                        }
                    }
                }

                // Si la clave viene vacía, se conserva la actual
                boolean cambiaClave = clave != null && !clave.trim().isEmpty();
                String sql = cambiaClave
                        ? "UPDATE usuario SET usuario = ?, clave = ?, rol = ? WHERE id = ?"
                        : "UPDATE usuario SET usuario = ?, rol = ? WHERE id = ?";
                try (PreparedStatement ps = con.prepareStatement(sql)) {
                    ps.setString(1, usuario);
                    if (cambiaClave) {
                        ps.setString(2, clave);
                        ps.setString(3, rol);
                        ps.setInt(4, id);
                    } else {
                        ps.setString(2, rol);
                        ps.setInt(3, id);
                    }
                    ps.executeUpdate();
                }

                // Si se editó a sí mismo, se actualiza la sesión
                if (usuarioActual.equals(nombreAnterior)) {
                    sesion.setAttribute("usuario", usuario);
                    sesion.setAttribute("rol", rol);
                }
                response.sendRedirect("AdminUsuariosServlet?mensaje=actualizado");
                return;
            }

            response.sendRedirect("AdminUsuariosServlet");

        } catch (NumberFormatException e) {
            response.sendRedirect("AdminUsuariosServlet");
        } catch (SQLException e) {
            throw new ServletException("Error al administrar los usuarios", e);
        }
    }
}