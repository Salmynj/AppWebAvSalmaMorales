<%@ Language="VBScript" CodePage="65001" %>
<!--#include file="conexion.asp"-->
<!--#include file="funciones.asp"-->
<%
' ================================================================================
' canciones.asp  -  Pagina principal: Song List de PoliMusic
' --------------------------------------------------------------------------------
' Muestra el mensaje de bienvenida con el usuario de la variable de sesion,
' el listado de canciones en una tabla HTML estilizada, el reproductor de audio
' y (solo para el rol ADMIN) el CRUD completo sobre TBL_SONG.
' ================================================================================

ExigirSesion

' --- Datos de la plantilla -----------------------------------------------------
Dim tituloPagina, paginaActual
tituloPagina = "PoliMusic | Canciones"
paginaActual = "canciones"

' --- Mensaje de la operacion anterior ------------------------------------------
Dim mensaje, tipoMensaje, pestana
mensaje = Session("mensaje")
tipoMensaje = Session("tipoMensaje")
pestana = Session("pestana")
Session("mensaje") = ""
Session("tipoMensaje") = ""
Session("pestana") = ""

If Request("msg") = "sin_permiso" Then
    mensaje = "Esa zona es exclusiva del usuario ADMIN. Inicia sesion con una cuenta de administrador."
    tipoMensaje = "aviso"
End If
%>
<!--#include file="header.asp"-->

<%
' --- Consulta principal: canciones con su artista y sus reproducciones ------
Dim rsCanciones, rsAlbumes, rsPlaylist
Set rsCanciones = Consulta("SELECT s.ID_SONG, s.SONG_NAME, s.SONG_PATH, ISNULL(s.PLAYS,0) AS PLAYS, " & _
                          "(SELECT COUNT(*) FROM TBL_PLAYER p WHERE p.ID_SONG = s.ID_SONG) AS N_ARTISTAS, " & _
                          "(SELECT TOP 1 a.ARTIST_NAME + ' ' + ISNULL(a.ARTIST_LASTNAME,'') " & _
                          " FROM TBL_PLAYER p INNER JOIN TBL_ARTIST a ON p.ID_ARTIST = a.ID_ARTIST " & _
                          " WHERE p.ID_SONG = s.ID_SONG) AS ARTISTA " & _
                          "FROM TBL_SONG s ORDER BY s.SONG_NAME ASC")

Set rsAlbumes = Consulta("SELECT TOP 5 al.ID_ALBUM, al.TITLE_ALBUM, al.RELEASE_YEAR, al.ALBUM_IMAGE_PATH, " & _
                        "(SELECT COUNT(*) FROM TBL_TRACKLIST t WHERE t.ID_ALBUM = al.ID_ALBUM) AS N_CANCIONES " & _
                        "FROM TBL_ALBUM al " & _
                        "ORDER BY N_CANCIONES DESC, al.TITLE_ALBUM ASC")

Set rsPlaylist = Consulta("SELECT TOP 5 pl.ID_PLAYLIST, pl.TITLE, pl.CREATION_DATE, pl.TYPE, pl.PHOTO, " & _
                         "(SELECT COUNT(*) FROM TBL_PLAYLIST_SONG ps WHERE ps.ID_PLAYLIST = pl.ID_PLAYLIST) AS N_CANCIONES " & _
                         "FROM TBL_PLAYLIST pl ORDER BY pl.CREATION_DATE DESC")
%>

<%' ------------------------------------------------------------ Encabezado --%>
<section class="cabecera-pagina">
  <div>
    <p class="etiqueta-kicker">Panel de escucha</p>
    <h1 class="titulo-pagina">
      Bienvenido/a, <span class="nombre-resaltado"><%= E(Session("usuario")) %></span>
    </h1>
    <p class="subtitulo-pagina">
      Tu sesion esta activa con el rol
      <span class="<%= ClaseRol() %>"><%= E(TextoRolDesdeCatalogo(Session("userType"))) %></span>
      <% If EsAdmin() Then %>
        &middot; tienes habilitados los controles de administracion (CRUD).
      <% Else %>
        &middot; modo escucha: puedes reproducir toda la biblioteca.
      <% End If %>
    </p>
  </div>

  <div class="cabecera-usuario">
    <img class="avatar avatar-grande" src="<%= E(UrlFoto(Session("foto"))) %>" alt="Foto de <%= E(Session("usuario")) %>">
    <div class="cabecera-usuario-datos">
      <strong><%= E(Session("usuario")) %></strong>
      <span><%= E(Session("email")) %></span>
    </div>
    <a class="boton boton-secundario" href="logout.asp">
      <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"></path><path d="M16 17l5-5-5-5"></path><path d="M21 12H9"></path></svg>
      Cerrar sesion
    </a>
  </div>
</section>

<% If Len(mensaje) > 0 Then %>
  <div class="alerta alerta-<%= E(tipoMensaje) %>" role="alert"><%= E(mensaje) %></div>
<% End If %>

<%' ------------------------------------------------- Texto del Song List ------%>
<section class="panel">
  <div class="panel-encabezado">
    <div>
      <h2 class="panel-titulo">Song List</h2>
      <p class="panel-texto">
        A continuacion se presenta el listado de canciones (<strong>Song List</strong>)
        almacenado en la tabla <code>TBL_SONG</code> de la base de datos
        <code>BDD_PoliMusic</code>. Puedes reproducir cada tema con el boton
        <strong>Reproducir</strong>; el reproductor fijo de la parte inferior permite
        avanzar, pausar y ajustar el volumen.
      </p>
    </div>
    <div class="panel-contador">
      <span class="contador-numero"><%= rsCanciones.RecordCount %></span>
      <span class="contador-texto">canciones<br>registradas</span>
    </div>
  </div>

  <% If Not rsCanciones.EOF Then %>

  <%' ------------------------------------------- Tabla HTML del listado ------%>
  <div class="tabla-envoltura">
    <table class="tabla-canciones">
      <thead>
        <tr>
          <th class="col-num">#</th>
          <th class="col-titulo">Cancion</th>
          <th class="col-artista">Artista(s)</th>
          <th class="col-archivo">Archivo</th>
          <th class="col-plays">Plays</th>
          <th class="col-accion">Acciones</th>
        </tr>
      </thead>
      <tbody>
        <%
        Dim i, idS, nombreS, rutaS, urlS, playsS, artistasS, archivoS, disponible, coverS
        i = 0
        Do While Not rsCanciones.EOF
            i = i + 1
            idS      = CLng(rsCanciones.Fields("ID_SONG").Value)
            nombreS  = CStr(rsCanciones.Fields("SONG_NAME").Value)
            rutaS    = CStr(rsCanciones.Fields("SONG_PATH").Value)
            playsS   = CStr(rsCanciones.Fields("PLAYS").Value)
            artistasS = CStr(rsCanciones.Fields("ARTISTA").Value)

            If Len(Trim(artistasS)) = 0 Then artistasS = "Artista sin registrar"

            urlS        = UrlCancion(rutaS)
            archivoS    = NombreArchivo(rutaS)
            disponible  = (Len(urlS) > 0)

            ' Portada de respaldo segun la inicial del nombre de la cancion
            coverS = "img/cover-" & (((Asc(Left(nombreS & "x", 1)) Mod 5) + 1)) & ".svg"
        %>
        <tr class="fila-cancion" data-id="<%= idS %>" data-src="<%= E(urlS) %>" data-titulo="<%= E(nombreS) %>" data-artista="<%= E(artistasS) %>" data-cover="<%= E(coverS) %>">
          <td class="col-num">
            <span class="indice-fila"><%= i %></span>
            <button class="btn-reproducir" type="button"
                    <% If Not disponible Then %>disabled title="El archivo no se encontro en la carpeta songFiles"<% End If %>>
              <svg class="ico-play-fila" viewBox="0 0 24 24" width="16" height="16" fill="currentColor"><path d="M8 5v14l11-7z"></path></svg>
              <svg class="ico-pausa-fila" viewBox="0 0 24 24" width="16" height="16" fill="currentColor" style="display:none"><path d="M7 5h4v14H7zM13 5h4v14h-4z"></path></svg>
            </button>
          </td>
          <td class="col-titulo">
            <div class="celda-cancion">
              <img class="miniatura" src="<%= E(coverS) %>" alt="Portada de <%= E(nombreS) %>">
              <div>
                <strong class="nombre-cancion"><%= E(nombreS) %></strong>
                <% If Not disponible Then %>
                  <span class="estado-error">Audio no disponible</span>
                <% End If %>
              </div>
            </div>
          </td>
          <td class="col-artista">
            <span class="artista-tag"><%= E(artistasS) %></span>
          </td>
          <td class="col-archivo">
            <code class="ruta-archivo"><%= E(archivoS) %></code>
          </td>
          <td class="col-plays">
            <span class="contador-plays"><%= E(FormatoPlays(playsS)) %></span>
          </td>
          <td class="col-accion">
            <div class="acciones-fila">
              <% If disponible Then %>
                <button class="btn-accion btn-accion-play js-reproducir" type="button" title="Reproducir">
                  <svg viewBox="0 0 24 24" width="15" height="15" fill="currentColor"><path d="M8 5v14l11-7z"></path></svg>
                  <span>Reproducir</span>
                </button>
              <% Else %>
                <button class="btn-accion btn-accion-deshabilitado" type="button" disabled>
                  <svg viewBox="0 0 24 24" width="15" height="15" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M18 6 6 18M6 6l12 12"></path></svg>
                  <span>Sin audio</span>
                </button>
              <% End If %>

              <% If EsAdmin() Then %>
                <button class="btn-accion btn-accion-editar js-editar" type="button"
                        data-id="<%= idS %>" data-nombre="<%= E(nombreS) %>" data-ruta="<%= E(rutaS) %>" data-plays="<%= E(playsS) %>"
                        title="Editar cancion">
                  <svg viewBox="0 0 24 24" width="15" height="15" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 20h9"></path><path d="M16.5 3.5a2.1 2.1 0 0 1 3 3L7 19l-4 11-4z"></path></svg>
                  <span>Editar</span>
                </button>

                <button class="btn-accion btn-accion-eliminar js-eliminar" type="button"
                        data-id="<%= idS %>" data-nombre="<%= E(nombreS) %>"
                        title="Eliminar cancion">
                  <svg viewBox="0 0 24 24" width="15" height="15" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 6h18"></path><path d="M8 6V4h8v2"></path><path d="M19 6l-1 14H6L5 6"></path></svg>
                  <span>Eliminar</span>
                </button>
              <% End If %>
            </div>
          </td>
        </tr>
        <%
            rsCanciones.MoveNext
        Loop
        %>
      </tbody>
    </table>
  </div>

  <%
  Else %>
    <div class="vacio">
      <p class="vacio-titulo">Todavia no hay canciones registradas</p>
      <p class="vacio-texto">
        <% If EsAdmin() Then %>
          Usa el boton <strong>Nueva cancion</strong> para agregar la primera.
        <% Else %>
          Contacta al administrador para que cargue la biblioteca musical.
        <% End If %>
      </p>
    </div>
  <% End If %>
</section>

<%' ------------------------------------------- Formulario CRUD (solo ADMIN) --%>
<% If EsAdmin() Then %>
<section class="panel">
  <div class="panel-encabezado">
    <div>
      <h2 class="panel-titulo">Administracion de canciones</h2>
      <p class="panel-texto">
        Solo el rol <strong>ADMIN</strong> puede crear, actualizar y eliminar registros
        de <code>TBL_SONG</code>. Las operaciones se guardan en la base de datos.
      </p>
    </div>
    <button class="boton boton-primario" id="btnNueva" type="button">
      <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M12 5v14M5 12h14"></path></svg>
      Nueva cancion
    </button>
  </div>

  <form id="formCancion" class="form-cancion" method="post" action="canciones_accion.asp">
    <input type="hidden" name="accion" value="crear">
    <input type="hidden" name="idSong" value="0">

    <div class="form-grilla">
      <label class="campo">
        <span class="campo-etiqueta">Nombre de la cancion</span>
        <input type="text" name="songName" id="songName" class="campo-input" maxlength="50"
               placeholder="Ej: Adventure" required>
      </label>

      <label class="campo">
        <span class="campo-etiqueta">Archivo de audio (.mp3)</span>
        <select name="songPath" id="songPath" class="campo-input" required>
          <option value="">Selecciona un archivo de songFiles...</option>
          <%
          ' Lista los .mp3 disponibles en la carpeta songFiles
          Dim fso, carpeta, archivo, opcion
          Set fso = Server.CreateObject("Scripting.FileSystemObject")
          If fso.FolderExists(Server.MapPath("songFiles")) Then
              Set carpeta = fso.GetFolder(Server.MapPath("songFiles"))
              For Each archivo In carpeta.Files
                  If LCase(fso.GetExtensionName(archivo.Name)) = "mp3" Then
                      opcion = "~/songFiles/" & archivo.Name
                      %>
          <option value="<%= E(opcion) %>"><%= E(archivo.Name) %></option>
                      <%
                  End If
              Next
              Set carpeta = Nothing
          End If
          Set fso = Nothing
          %>
        </select>
        <span class="campo-ayuda">El archivo se guarda en <code>songFiles/</code> y se reproduce desde ahi.</span>
      </label>
    </div>

    <div class="form-acciones">
      <span class="form-modo" id="formModo">Modo: crear nueva cancion</span>
      <div class="form-botones">
        <button type="button" class="boton boton-texto" id="btnCancelar">Limpiar formulario</button>
        <button type="submit" class="boton boton-primario" id="btnGuardar">Guardar cancion</button>
      </div>
    </div>
  </form>
</section>
<% End If %>

<%' ------------------------------------------------- Albums y playlists ------%>
<section class="rejilla-tarjetas">

  <article class="tarjeta">
    <h3 class="tarjeta-titulo">Albums mas docking</h3>
    <p class="tarjeta-subtitulo">TBL_ALBUM + TBL_TRACKLIST</p>
    <%
    If Not rsAlbumes.EOF Then
        Do While Not rsAlbumes.EOF
            Dim imgAlb
            imgAlb = UrlFoto(rsAlbumes.Fields("ALBUM_IMAGE_PATH").Value)
            If Len(imgAlb) = 0 Or Not ArchivoExiste(imgAlb) Then imgAlb = "img/cover.svg"
    %>
      <div class="item-lista">
        <img class="item-imagen" src="<%= E(imgAlb) %>" alt="Portada de <%= E(rsAlbumes.Fields("TITLE_ALBUM").Value) %>">
        <div class="item-datos">
          <strong><%= E(rsAlbumes.Fields("TITLE_ALBUM").Value) %></strong>
          <span><%= E(rsAlbumes.Fields("RELEASE_YEAR").Value) %> &middot; <%= E(rsAlbumes.Fields("N_CANCIONES").Value) %> canciones</span>
        </div>
      </div>
    <%
            rsAlbumes.MoveNext
        Loop
    Else
    %>
      <p class="tarjeta-vacia">Sin albums registrados.</p>
    <%
    End If
    %>
  </article>

  <article class="tarjeta">
    <h3 class="tarjeta-titulo">Playlists recientes</h3>
    <p class="tarjeta-subtitulo">TBL_PLAYLIST + TBL_PLAYLIST_SONG</p>
    <%
    If Not rsPlaylist.EOF Then
        Do While Not rsPlaylist.EOF
            Dim imgPl, tipoPl
            imgPl = UrlFoto(rsPlaylist.Fields("PHOTO").Value)
            If Len(imgPl) = 0 Or Not ArchivoExiste(imgPl) Then imgPl = "img/cover.svg"
            If CStr(rsPlaylist.Fields("TYPE").Value) = "1" Then
                tipoPl = "Privada"
            Else
                tipoPl = "Publica"
            End If
    %>
      <div class="item-lista">
        <img class="item-imagen" src="<%= E(imgPl) %>" alt="Portada de <%= E(rsPlaylist.Fields("TITLE").Value) %>">
        <div class="item-datos">
          <strong><%= E(rsPlaylist.Fields("TITLE").Value) %></strong>
          <span><%= E(tipoPl) %> &middot; <%= E(rsPlaylist.Fields("N_CANCIONES").Value) %> canciones</span>
        </div>
      </div>
    <%
            rsPlaylist.MoveNext
        Loop
    Else
    %>
      <p class="tarjeta-vacia">Sin playlists registradas.</p>
    <%
    End If
    %>
  </article>

</section>

<%
rsCanciones.Close
rsAlbumes.Close
rsPlaylist.Close
%>

<%' ---------------------------------- Confirmacion de eliminacion (modal) ----%>
<% If EsAdmin() Then %>
<div class="modal" id="modalEliminar" aria-hidden="true">
  <div class="modal-caja" role="dialog" aria-modal="true" aria-labelledby="tituloModal">
    <h3 class="modal-titulo" id="tituloModal">Eliminar cancion</h3>
    <p class="modal-texto">
      Se eliminara <strong id="nombreEliminar"></strong> de la tabla <code>TBL_SONG</code>
      y sus vinculos en <code>TBL_TRACKLIST</code>, <code>TBL_PLAYER</code> y
      <code>TBL_PLAYLIST_SONG</code>. Esta accion no se puede deshacer.
    </p>
    <div class="modal-acciones">
      <button type="button" class="boton boton-texto" id="btnCancelarEliminar">Cancelar</button>
      <a href="#" class="boton boton-peligro" id="btnConfirmarEliminar">Eliminar definitivamente</a>
    </div>
  </div>
</div>
<% End If %>

<!--#include file="footer.asp"-->