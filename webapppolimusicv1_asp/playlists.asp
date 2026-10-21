<%@ Language="VBScript" CodePage="65001" %>
<!--#include file="conexion.asp"-->
<!--#include file="funciones.asp"-->
<%
'================================================================================
' playlists.asp  -  Playlists de los usuarios (TBL_PLAYLIST + TBL_PLAYLIST_SONG)
'================================================================================
ExigirSesion

Dim tituloPagina, paginaActual
tituloPagina = "PoliMusic | Playlists"
paginaActual = "playlists"

Set rs = ConsultaSegura("SELECT pl.ID_PLAYLIST, pl.TITLE, pl.CREATION_DATE, pl.TYPE, pl.PHOTO, " & _
                  "u.USERNAME, " & _
                  "(SELECT COUNT(*) FROM TBL_PLAYLIST_SONG ps WHERE ps.ID_PLAYLIST = pl.ID_PLAYLIST) AS N_CANCIONES " & _
                  "FROM TBL_PLAYLIST pl " & _
                  "INNER JOIN TBL_USER u ON pl.ID_USER = u.ID_USER " & _
                  "ORDER BY pl.CREATION_DATE DESC", _
                  "No se pudieron cargar las playlists.")
%>
<!--#include file="header.asp"-->

<section class="cabecera-pagina">
  <div>
    <p class="etiqueta-kicker">Colecciones</p>
    <h1 class="titulo-pagina">Bienvenido/a, <span class="nombre-resaltado"><%= E(Session("usuario")) %></span></h1>
    <p class="subtitulo-pagina">Playlists creadas por los usuarios de <code>TBL_USER</code>.</p>
  </div>
  <div class="cabecera-usuario">
    <img class="avatar avatar-grande" src="<%= E(UrlFoto(Session("foto"))) %>" alt="Foto de <%= E(Session("usuario")) %>">
    <a class="boton boton-secundario" href="logout.asp">Cerrar sesion</a>
  </div>
</section>

<section class="panel">
  <div class="panel-encabezado">
    <div>
      <h2 class="panel-titulo">Playlists</h2>
      <p class="panel-texto">
        A continuacion se presenta el listado de playlists (<strong>Playlist List</strong>)
        con la cantidad de canciones vinculadas en <code>TBL_PLAYLIST_SONG</code>.
      </p>
    </div>
    <div class="panel-contador">
      <span class="contador-numero"><%= rs.RecordCount %></span>
      <span class="contador-texto">playlists<br>registradas</span>
    </div>
  </div>

  <% If Not rs.EOF Then %>
  <div class="tabla-envoltura">
    <table class="tabla-canciones">
      <thead>
        <tr>
          <th class="col-num">#</th>
          <th class="col-titulo">Playlist</th>
          <th class="col-artista">Propietario</th>
          <th class="col-archivo">Creada</th>
          <th class="col-plays">Canciones</th>
          <th class="col-accion">Tipo</th>
        </tr>
      </thead>
      <tbody>
        <%
        Dim i, imgP
        i = 0
        Do While Not rs.EOF
            i = i + 1
            imgP = UrlFoto(rs.Fields("PHOTO").Value)
            If Len(imgP) = 0 Or Not ArchivoExiste(imgP) Then imgP = "img/cover.svg"
        %>
        <tr class="fila-cancion">
          <td class="col-num"><span class="indice-fila"><%= i %></span></td>
          <td class="col-titulo">
            <div class="celda-cancion">
              <img class="miniatura" src="<%= E(imgP) %>" alt="Portada de <%= E(rs.Fields("TITLE").Value) %>">
              <strong class="nombre-cancion"><%= E(rs.Fields("TITLE").Value) %></strong>
            </div>
          </td>
          <td class="col-artista"><span class="artista-tag"><%= E(rs.Fields("USERNAME").Value) %></span></td>
          <td class="col-archivo"><code class="ruta-archivo"><%= FormatDateTime(rs.Fields("CREATION_DATE").Value, 2) %></code></td>
          <td class="col-plays"><span class="contador-plays"><%= E(rs.Fields("N_CANCIONES").Value) %></span></td>
          <td class="col-accion">
            <span class="chip <% If CStr(rs.Fields("TYPE").Value) = "1" Then %>chip-admin<% Else %>chip-user<% End If %>">
              <%= IIf(CStr(rs.Fields("TYPE").Value) = "1", "Privada", "Publica") %>
            </span>
          </td>
        </tr>
        <%
            rs.MoveNext
        Loop
        %>
      </tbody>
    </table>
  </div>
  <% Else %>
    <div class="vacio"><p class="vacio-titulo">No hay playlists registradas</p></div>
  <% End If %>
</section>

<%
rs.Close
%>
<!--#include file="footer.asp"-->