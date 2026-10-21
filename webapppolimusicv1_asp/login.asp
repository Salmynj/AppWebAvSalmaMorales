<%@ Language="VBScript" CodePage="65001" %>
<!--#include file="conexion.asp"-->
<!--#include file="funciones.asp"-->
<%
' ================================================================================
' login.asp  -  Pantalla de autenticacion de PoliMusic
' --------------------------------------------------------------------------------
' Valida las credenciales contra la tabla TBL_USER de BDD_PoliMusic y guarda
' en la variable de sesion los datos que luego consume el resto del sitio:
'    Session("usuario")   -> USERNAME  (nombre que se muestra en la bienvenida)
'    Session("idUsuario") -> ID_USER
'    Session("userType")  -> USER_TYPE  (0 = normal, 1 = admin)
'    Session("foto")      -> USER_PHOTO
'    Session("email")     -> EMAIL
' ================================================================================

' Si ya hay sesion activa se envia directo al listado de canciones.
If HaySesion() Then
    Response.Redirect "canciones.asp"
    Response.End
End If

' --- Variables de la plantilla ------------------------------------------------
Dim mensaje, tipoMensaje, usuarioIngresado, detalleError

mensaje = ""
tipoMensaje = ""
usuarioIngresado = ""
detalleError = ""

' --- Procesamiento del formulario (POST) ---------------------------------------
If Request("accion") = "entrar" Then

    usuarioIngresado = Trim(Request.Form("username"))
    Dim clave, rs, encontrado, numErr, txtErr

    clave = Trim(Request.Form("password"))
    encontrado = False

    If Len(usuarioIngresado) = 0 Or Len(clave) = 0 Then
        mensaje = "Ingresa tu usuario y tu contrasena para continuar."
        tipoMensaje = "error"
    Else
        On Error Resume Next
        Set rs = Consulta("SELECT ID_USER, USERNAME, PASSWORD, EMAIL, USER_PHOTO, USER_TYPE " & _
                          "FROM TBL_USER WHERE USERNAME = '" & Q(usuarioIngresado) & "'")
        numErr = Err.Number
        txtErr = Err.Description

        If numErr <> 0 Then
            Err.Clear
            On Error GoTo 0
            Session("mensaje") = "Ocurrio un error al consultar la base de datos. Intenta nuevamente."
            Session("tipoMensaje") = "error"
            Session("detalleError") = "Error " & CStr(numErr) & ": " & CStr(txtErr)
            Response.Redirect "login.asp"
            Response.End
        End If
        Err.Clear
        On Error GoTo 0

        If Not rs.EOF Then
            If CStr(rs.Fields("PASSWORD").Value) = clave Then
                encontrado = True

                ' --- Se construye la sesion ---------------------------------------
                Session("idUsuario") = CStr(rs.Fields("ID_USER").Value)
                Session("usuario")   = CStr(rs.Fields("USERNAME").Value)
                Session("userType")  = CStr(rs.Fields("USER_TYPE").Value)
                Session("foto")      = CStr(rs.Fields("USER_PHOTO").Value)
                Session("email")     = CStr(rs.Fields("EMAIL").Value)
                Session("rol")       = TextoRolDesdeCatalogo(rs.Fields("USER_TYPE").Value)

                ' Cookies de apoyo (no sustituyen a la sesion del servidor)
                Response.Cookies("pm_usuario") = Session("usuario")
                Response.Cookies("pm_usuario").Expires = DateAdd("h", 2, Now())

                Response.Redirect "canciones.asp"
                Response.End
            End If
        End If

        rs.Close
        Set rs = Nothing

        If Not encontrado Then
            mensaje = "Usuario o contrasena incorrectos. Intenta nuevamente."
            tipoMensaje = "error"
        End If
    End If
End If

' --- Mensajes que llegan por redirect ------------------------------------------
Dim msgUrl
msgUrl = Trim(Request.QueryString("msg"))
If msgUrl = "sesion" Then
    mensaje = "Debes iniciar sesion para entrar al sitio."
    tipoMensaje = "aviso"
ElseIf msgUrl = "logout" Then
    mensaje = "Sesion cerrada correctamente. Hasta luego!"
    tipoMensaje = "exito"
ElseIf Len(mensaje) = 0 And Len(Session("mensaje")) > 0 Then
    mensaje = Session("mensaje")
    tipoMensaje = Session("tipoMensaje")
End If
detalleError = CStr(Session("detalleError"))
Session("mensaje") = ""
Session("tipoMensaje") = ""
Session("detalleError") = ""
%>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>PoliMusic | Iniciar sesion</title>
<link rel="stylesheet" href="css/polimusic.css">
</head>
<body class="body-login">

<div class="fondo-decorativo" aria-hidden="true">
  <span class="burbuja burbuja-1"></span>
  <span class="burbuja burbuja-2"></span>
  <span class="burbuja burbuja-3"></span>
</div>

<main class="login-wrap">

  <section class="login-panel" role="region" aria-labelledby="tituloLogin">
    <div class="login-marca">
      <div class="logo-logo" aria-hidden="true">
        <svg viewBox="0 0 24 24" width="30" height="30" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <path d="M9 18V5l12-2v13"></path>
          <circle cx="6" cy="18" r="3"></circle>
          <circle cx="18" cy="16" r="3"></circle>
        </svg>
      </div>
      <div>
        <h1 class="login-titulo">PoliMusic</h1>
        <p class="login-subtitulo">Aplicaciones Web Avanzadas &middot; ASP Clasico</p>
      </div>
    </div>

    <% If Len(mensaje) > 0 Then %>
      <div class="alerta alerta-<%= tipoMensaje %>" role="alert"><%= E(mensaje) %></div>
    <% End If %>

    <% If MODO_DEBUG And Len(detalleError) > 0 Then %>
      <details class="alerta alerta-error detalle-tecnico">
        <summary>Detalle tecnico del error (MODO_DEBUG)</summary>
        <pre><%= E(detalleError) %></pre>
      </details>
    <% End If %>

    <form method="post" action="login.asp" class="login-form" autocomplete="off">
      <input type="hidden" name="accion" value="entrar">

      <label class="campo">
        <span class="campo-etiqueta">Usuario</span>
        <input type="text" name="username" id="username" class="campo-input"
               value="<%= E(usuarioIngresado) %>" placeholder="userNormal" maxlength="50" required>
      </label>

      <label class="campo">
        <span class="campo-etiqueta">Contrasena</span>
        <input type="password" name="password" id="password" class="campo-input"
               placeholder="********" maxlength="50" required>
      </label>

      <button type="submit" class="boton boton-primario boton-bloque">Entrar a PoliMusic</button>
    </form>

    <div class="login-ayuda">
      <p class="login-ayuda-titulo">Cuentas de prueba</p>
      <ul class="login-lista">
        <li><span class="chip chip-admin">ADMIN</span> userAdmin / 12345678</li>
        <li><span class="chip chip-user">USER</span> userNormal / 12345678</li>
      </ul>
    </div>
  </section>

  <aside class="login-lateral" aria-hidden="true">
    <p class="login-lateral-kicker">Proyecto</p>
    <p class="login-lateral-titulo">Tu biblioteca musical<br>conectada a SQL Server</p>
    <p class="login-lateral-texto">
      Song List, busqueda por artistas, albums y playlists servidos desde
      <strong>BDD_PoliMusic</strong>.
    </p>
  </aside>

</main>

</body>
</html>