<%'
' ================================================================================
' header.asp  -  Cabecera comun del sitio (logotipo, navegacion, usuario)
' --------------------------------------------------------------------------------
' Espera que la pagina que lo incluye ya haya validado la sesion.
' ================================================================================
%>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title><%= E(tituloPagina) %></title>
<link rel="stylesheet" href="css/polimusic.css">
</head>
<body class="body-app">

<div class="fondo-decorativo fondo-decorativo-app" aria-hidden="true">
  <span class="burbuja burbuja-1"></span>
  <span class="burbuja burbuja-2"></span>
</div>

<div class="app-shell">

  <%' ------------------------------------------------ Barra lateral de navegacion --%>
  <aside class="sidebar">
    <a class="marca" href="canciones.asp">
      <span class="marca-logo" aria-hidden="true">
        <svg viewBox="0 0 24 24" width="22" height="22" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <path d="M9 18V5l12-2v13"></path>
          <circle cx="6" cy="18" r="3"></circle>
          <circle cx="18" cy="16" r="3"></circle>
        </svg>
      </span>
      <span class="marca-texto">PoliMusic</span>
    </a>

    <nav class="nav-menu" aria-label="Navegacion principal">
      <a class="nav-enlace <% If paginaActual = "canciones" Then Response.Write("activo") End If %>" href="canciones.asp">
        <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 12a9 9 0 1 0 3-6.7"></path><path d="M3 4v5h5"></path></svg>
        Canciones
      </a>
      <a class="nav-enlace <% If paginaActual = "albumes" Then Response.Write("activo") End If %>" href="albumes.asp">
        <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="9"></circle><circle cx="12" cy="12" r="3"></circle></svg>
        Albums
      </a>
      <a class="nav-enlace <% If paginaActual = "artistas" Then Response.Write("activo") End If %>" href="artistas.asp">
        <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M22 21v-2a4 4 0 0 0-3-3.9"></path></svg>
        Artistas
      </a>
      <a class="nav-enlace <% If paginaActual = "playlists" Then Response.Write("activo") End If %>" href="playlists.asp">
        <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path><path d="M7 10l5 5 5-5"></path><path d="M12 15V3"></path></svg>
        Playlists
      </a>
    </nav>

    <div class="sidebar-pie">
      <p class="sidebar-titulo">Sesion activa</p>
      <div class="tarjeta-usuario">
        <img class="avatar" src="<%= E(UrlFoto(Session("foto"))) %>" alt="Foto de <%= E(Session("usuario")) %>">
        <div class="tarjeta-usuario-datos">
          <strong class="tarjeta-usuario-nombre"><%= E(Session("usuario")) %></strong>
          <span class="<%= ClaseRol() %>"><%= E(TextoRolDesdeCatalogo(Session("userType"))) %></span>
        </div>
      </div>
      <a class="boton boton-logout" href="logout.asp">
        <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"></path><path d="M16 17l5-5-5-5"></path><path d="M21 12H9"></path></svg>
        Cerrar sesion
      </a>
    </div>
  </aside>

  <%' ------------------------------------------------ Contenido principal --%>
  <main class="contenido">