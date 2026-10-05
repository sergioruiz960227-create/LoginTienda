document.addEventListener("DOMContentLoaded", () => {
    const formulario = document.getElementById("loginForm");
    const mensajeError = document.getElementById("mensajeError");
    const textoError = document.getElementById("textoError");
    const mensajeExito = document.getElementById("mensajeExito");
    const usuarioInput = document.getElementById("usuario");
    const passwordInput = document.getElementById("password");

    function mostrarError(mensaje) {
        textoError.textContent = mensaje;
        mensajeError.hidden = false;
    }

    function ocultarMensajes() {
        mensajeError.hidden = true;
        mensajeExito.hidden = true;
    }

    // Mensajes que envía el servidor en la dirección (?error=1 / ?registrado=1)
    const parametros = new URLSearchParams(window.location.search);
    if (parametros.has("error")) {
        mostrarError("El usuario o la contraseña son incorrectos.");
    }
    if (parametros.has("registrado")) {
        mensajeExito.hidden = false;
    }

    // Solo se bloquea el envío si hay campos vacíos;
    // si están llenos, el formulario viaja al LoginServlet (POST)
    formulario.addEventListener("submit", (e) => {
        if (usuarioInput.value.trim() === "" || passwordInput.value.trim() === "") {
            e.preventDefault();
            mostrarError("Por favor, complete todos los campos.");
        }
    });

    // Los mensajes se ocultan cuando la persona escribe de verdad
    // (keydown, para que el autocompletado del navegador no los borre)
    usuarioInput.addEventListener("keydown", ocultarMensajes);
    passwordInput.addEventListener("keydown", ocultarMensajes);

    // Enlaces auxiliares aún no incluidos en este proyecto
    document.querySelectorAll(".enlace-construccion").forEach((enlace) => {
        enlace.addEventListener("click", (e) => {
            e.preventDefault();
            alert("Módulo en construcción.");
        });
    });
});
