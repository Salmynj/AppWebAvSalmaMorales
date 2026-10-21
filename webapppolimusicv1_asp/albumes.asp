<%@ Language="VBScript" CodePage="65001" %>
<!--#include file="conexion.asp"-->
<!--#include file="funciones.asp"-->
<%'
' ================================================================================
' albumes.asp  -  Listado de albums (TBL_ALBUM + TBL_TRACKLIST)
' ================================================================================
ExigirSesion

Dim tituloPagina, paginaActual
tituloPagina = "PoliMusic | Albums"
paginaActual = "albumes"

Set rs = ConsultaSegura("SELECT al.ID_ALBUM, al.TITLE_ALBUM, al.RELEASE_YEAR, al.ALBUM_IMAGE_PATH, " & _
                  "(SELECT COUNT(*) FROM TBL_TRACKLIST t WHERE t.ID_ALBUM = al.ID_ALBUM) AS N_CANCIONES " & _
                  "FROM TBL_ALBUM al ORDER BY al.RELEASE_YEAR DESC", _
                  "No se pudieron cargar los albums.")

Set rsArtistas = ConsultaSegura("SELECT a.ID_ARTIST, a.ARTIST_NAME, a.ARTIST_LASTNAME, a.ARTIST_IMAGE, " & _
                          "(SELECT COUNT(*) FROM TBL_PLAYER p WHERE p.ID_ARTIST = a.ID_ARTIST) AS N_CANCIONES " & _
                          "FROM TBL_ARTIST a ORDER BY a.ARTIST_NAME ASC", _
                          "No se pudieron cargar los artistas.")
%>
<!--#include file="header.asp"-->

<section class="cabecera-pagina">
  <div>
    <p class="etiqueta-kicker">Catalogo musical</p>
    <h1 class="titulo-pagina">Bienvenido/a, <span class="nombre-resaltado"><%= E(Session("usuario")) %></span></h1>
    <p class="subtitulo-pagina">Albums registrados en <code>TBL_ALBUM</code> con sus canciones en <code>TBL_TRACKLIST</code>.</p>
  </div>
  <div class="cabecera-usuario">
    <img class="avatar avatar-grande" src="<%= E(UrlFoto(Session("foto"))) %>" alt="Foto de <%= E(Session("usuario")) %>">
    <a class="boton boton-secundario" href="logout.asp">Cerrar sesion</a>
  </div>
</section>

<section class="panel">
  <div class="panel-encabezado">
    <div>
      <h2 class="panel-titulo">Albums</h2>
      <p class="panel-texto">Listado completo de los albums almacenados en la base de datos.</p>
    </div>
    <div class="panel-contador">
      <span class="contador-numero"><%= rs.RecordCount %></span>
      <span class="contador-texto">albums<br>registrados</span>
    </div>
  </div>

  <% If Not rs.EOF Then %>
  <div class="rejilla-albumes">
    <%
    Do While Not rs.EOF
        Dim imgA
        imgA = UrlFoto(rs.Fields("ALBUM_IMAGE_PATH").Value)
        If Len(imgA) = 0 Or Not ArchivoExiste(imgA) Then imgA = "img/cover.svg"
    %>
      <article class="tarjeta-album">
        <img class="tarjeta-album-imagen" src="<%= E(imgA) %>" alt="Portada de <%= E(rs.Fields("TITLE_ALBUM").Value) %>">
        <h3 class="tarjeta-album-titulo"><%= E(rs.Fields("TITLE_ALBUM").Value) %></h3>
        <p class="tarjeta-album-meta"><%= E(rs.Fields("RELEASE_YEAR").Value) %> &middot; <%= E(rs.Fields("N_CANCIONES").Value) %> canciones</p>
      </article>
    <%
        rs.MoveNext
    Loop
    %>
  </div>
  <% Else %>
    <div class="vacio"><p class="vacio-titulo">No hay albums registrados</p></div>
  <% End If %>
</section>

<section class="panel">
  <div class="panel-encabezado">
    <div>
      <h2 class="panel-titulo">Artistas</h2>
      <p class="panel-texto">Artistas de <code>TBL_ARTIST</code> vinculados a las canciones mediante <code>TBL_PLAYER</code>.</p>
    </div>
  </div>
  <% If Not rsArtistas.EOF Then %>
  <div class="rejilla-artistas">
    <%
    Do While Not rsArtistas.EOF
        Dim imgAr
        imgAr = UrlFoto(rsArtistas.Fields("ARTIST_IMAGE").Value)
        If Len(imgAr) = 0 Or Not ArchivoExiste(imgAr) Then imgAr = "img/cover.svg"
    %>
      <article class="tarjeta-artista">
        <img class="tarjeta-artista-imagen" src="<%= E(imgAr) %>" alt="Foto de <%= E(rsArtistas.Fields("ARTIST_NAME").Value) %>">
        <h3 class="tarjeta-album-titulo"><%= E(rsArtistas.Fields("ARTIST_NAME").Value) %> <%= E(rsArtistas.Fields("ARTIST_LASTNAME").Value) %></h3>
        <p class="tarjeta-album-meta"><%= E(rsArtistas.Fields("N_CANCIONES").Value) %> canciones</p>
      </article>
    <%
        rsArtistas.MoveNext
    Loop
    %>
  </div>
  <% Else %>
    <div class="vacio"><p class="vacio-titulo">No hay artistas registrados</p></div>
  <% End If %>
</section>

<%
rs.Close
rsArtistas.Close
%>
<!--#include file="footer.asp"-->