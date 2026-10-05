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

@WebServlet(name = "LoginServlet", urlPatterns = {"/LoginServlet"})
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String usuario = request.getParameter("usuario");
        String clave = request.getParameter("clave");

        String sql = "SELECT id, usuario, rol FROM usuario WHERE usuario = ? AND clave = ?";

        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, usuario);
            ps.setString(2, clave);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    HttpSession sesion = request.getSession();
                    sesion.setAttribute("usuario", rs.getString("usuario"));
                    sesion.setAttribute("rol", rs.getString("rol"));
                    response.sendRedirect("bienvenido.jsp");
                } else {
                    response.sendRedirect("index.html?error=1");
                }
            }
        } catch (SQLException e) {
            throw new ServletException("Error al consultar la base de datos", e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("index.html");
    }
}