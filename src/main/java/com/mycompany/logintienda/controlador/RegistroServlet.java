package com.mycompany.logintienda.controlador;

import com.mycompany.logintienda.modelo.ConexionBD;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

@WebServlet(name = "RegistroServlet", urlPatterns = {"/RegistroServlet"})
public class RegistroServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String usuario = request.getParameter("usuario");
        String clave = request.getParameter("clave");
        String rol = request.getParameter("rol");

        // Validaciones en el servidor
        if (usuario == null || clave == null || rol == null
                || usuario.trim().isEmpty() || clave.trim().isEmpty()) {
            response.sendRedirect("registro.html?error=vacio");
            return;
        }
        usuario = usuario.trim();
        if (!rol.equals("Administrador") && !rol.equals("Vendedor")) {
            response.sendRedirect("registro.html?error=rol");
            return;
        }

        try (Connection con = ConexionBD.getConexion()) {

            // ¿Ya existe ese usuario?
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT id FROM usuario WHERE usuario = ?")) {
                ps.setString(1, usuario);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        response.sendRedirect("registro.html?error=existe");
                        return;
                    }
                }
            }

            // Insertar el nuevo usuario
            try (PreparedStatement ps = con.prepareStatement(
                    "INSERT INTO usuario (usuario, clave, rol) VALUES (?, ?, ?)")) {
                ps.setString(1, usuario);
                ps.setString(2, clave);
                ps.setString(3, rol);
                ps.executeUpdate();
            }

            response.sendRedirect("index.html?registrado=1");

        } catch (SQLException e) {
            throw new ServletException("Error al registrar el usuario", e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("registro.html");
    }
}