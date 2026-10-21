"""Genera una vista previa estatica (HTML) de canciones.asp con datos reales.

Sirve para revisar el diseno sin necesidad de IIS. Se guarda en .workbuddy-ai/tmp.
"""
import io, os, pyodbc

RAIZ = r"C:\Users\salma\Documents\Octavo_Semestre\Web_Avanzadas\AppWebAvSalmaMorales\webapppolimusicv1_asp"
CS = ('DRIVER={ODBC Driver 17 for SQL Server};SERVER=localhost;'
      'DATABASE=BDD_PoliMusic;UID=usr_polimusic;PWD=Politecnica1')

css = io.open(os.path.join(RAIZ, "css", "polimusic.css"), encoding="utf-8").read()
js = io.open(os.path.join(RAIZ, "js", "polimusic.js"), encoding="utf-8").read()

cn = pyodbc.connect(CS, timeout=8)
cur = cn.cursor()
canciones = cur.execute(
    "SELECT s.ID_SONG, s.SONG_NAME, s.SONG_PATH, ISNULL(s.PLAYS,0) AS PLAYS, "
    "(SELECT TOP 1 a.ARTIST_NAME + ' ' + ISNULL(a.ARTIST_LASTNAME,'') "
    " FROM TBL_PLAYER p INNER JOIN TBL_ARTIST a ON p.ID_ARTIST=a.ID_ARTIST "
    " WHERE p.ID_SONG=s.ID_SONG) AS ARTISTA "
    "FROM TBL_SONG s ORDER BY s.SONG_NAME ASC").fetchall()
albumes = cur.execute(
    "SELECT TOP 5 al.TITLE_ALBUM, al.RELEASE_YEAR, "
    "(SELECT COUNT(*) FROM TBL_TRACKLIST t WHERE t.ID_ALBUM=al.ID_ALBUM) AS N "
    "FROM TBL_ALBUM al ORDER BY N DESC, al.TITLE_ALBUM ASC").fetchall()
playlists = cur.execute(
    "SELECT pl.TITLE, pl.TYPE, "
    "(SELECT COUNT(*) FROM TBL_PLAYLIST_SONG ps WHERE ps.ID_PLAYLIST=pl.ID_PLAYLIST) AS N "
    "FROM TBL_PLAYLIST pl ORDER BY pl.CREATION_DATE DESC").fetchall()
cn.close()

BASE = RAIZ.replace("\\", "/")


def esc(s):
    s = "" if s is None else str(s)
    return (s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
             .replace('"', "&quot;"))


def existe_en_disco(ruta):
    rel = ruta.replace("~/", "")
    return os.path.isfile(os.path.join(RAIZ, rel.replace("/", os.sep)))


filas_html = []
for i, c in enumerate(canciones, 1):
    nombre = str(c.SONG_NAME)
    ruta = str(c.SONG_PATH)
    rel = ruta.replace("~/", "")
    disponible = existe_en_disco(ruta)
    src = (BASE + "/" + rel) if disponible else ""
    archivo = rel.split("/")[-1]
    portada = BASE + "/img/cover-%d.svg" % ((ord(nombre[0]) % 5) + 1)
    artista = (str(c.ARTISTA).strip() if c.ARTISTA else "") or "Artista sin registrar"

    if disponible:
        boton = ('<button class="btn-accion btn-accion-play js-reproducir" type="button">'
                 '<svg viewBox="0 0 24 24" width="15" height="15" fill="currentColor">'
                 '<path d="M8 5v14l11-7z"></path></svg><span>Reproducir</span></button>')
        play_num = ('<button class="btn-reproducir" type="button">'
                    '<svg class="ico-play-fila" viewBox="0 0 24 24" width="16" height="16" '
                    'fill="currentColor"><path d="M8 5v14l11-7z"></path></svg>'
                    '<svg class="ico-pausa-fila" viewBox="0 0 24 24" width="16" height="16" '
                    'fill="currentColor" style="display:none">'
                    '<path d="M7 5h4v14H7zM13 5h4v14h-4z"></path></svg></button>')
        aviso = ""
    else:
        boton = ('<button class="btn-accion btn-accion-deshabilitado" type="button" disabled>'
                 '<svg viewBox="0 0 24 24" width="15" height="15" fill="none" stroke="currentColor" '
                 'stroke-width="2" stroke-linecap="round"><path d="M18 6 6 18M6 6l12 12"></path></svg>'
                 '<span>Sin audio</span></button>')
        play_num = ('<button class="btn-reproducir" type="button" disabled title="Archivo no encontrado">'
                    '<svg class="ico-play-fila" viewBox="0 0 24 24" width="16" height="16" '
                    'fill="currentColor"><path d="M8 5v14l11-7z"></path></svg>'
                    '<svg class="ico-pausa-fila" viewBox="0 0 24 24" width="16" height="16" '
                    'fill="currentColor" style="display:none">'
                    '<path d="M7 5h4v14H7zM13 5h4v14h-4z"></path></svg></button>')
        aviso = '<span class="estado-error">Audio no disponible</span>'

    acciones = boton + (
        '<button class="btn-accion btn-accion-editar js-editar" type="button">'
        '<svg viewBox="0 0 24 24" width="15" height="15" fill="none" stroke="currentColor" '
        'stroke-width="2" stroke-linecap="round" stroke-linejoin="round">'
        '<path d="M12 20h9"></path><path d="M16.5 3.5a2.1 2.1 0 0 1 3 3L7 19l-4 11-4z"></path></svg>'
        '<span>Editar</span></button>'
        '<button class="btn-accion btn-accion-eliminar js-eliminar" type="button">'
        '<svg viewBox="0 0 24 24" width="15" height="15" fill="none" stroke="currentColor" '
        'stroke-width="2" stroke-linecap="round" stroke-linejoin="round">'
        '<path d="M3 6h18"></path><path d="M8 6V4h8v2"></path>'
        '<path d="M19 6l-1 14H6L5 6"></path></svg><span>Eliminar</span></button>')

    filas_html.append("""        <tr class="fila-cancion" data-id="%d" data-src="%s" data-titulo="%s"
            data-artista="%s" data-cover="%s">
          <td class="col-num"><span class="indice-fila">%d</span>%s</td>
          <td class="col-titulo">
            <div class="celda-cancion"><img class="miniatura" src="%s" alt="">
              <div><strong class="nombre-cancion">%s</strong>%s</div></div>
          </td>
          <td class="col-artista"><span class="artista-tag">%s</span></td>
          <td class="col-archivo"><code class="ruta-archivo">%s</code></td>
          <td class="col-plays"><span class="contador-plays">%d</span></td>
          <td class="col-accion"><div class="acciones-fila">%s</div></td>
        </tr>""" % (c.ID_SONG, esc(src), esc(nombre), esc(artista), esc(portada),
                    i, play_num, esc(portada), esc(nombre), aviso,
                    esc(artista), esc(archivo), c.PLAYS, acciones))


def item(imagen, titulo, meta):
    return ('<div class="item-lista"><img class="item-imagen" src="%s" alt="">'
            '<div class="item-datos"><strong>%s</strong><span>%s</span></div></div>'
            % (imagen, esc(titulo), esc(meta)))


alb_html = "\n".join(
    item(BASE + "/PlaylistImages/playlist%d.png" % ((i - 1) % 5 + 1),
         a.TITLE_ALBUM, "%s &middot; %d canciones" % (a.RELEASE_YEAR, a.N))
    for i, a in enumerate(albumes, 1))

pl_html = "\n".join(
    item(BASE + "/PlaylistImages/playlist%d.png" % ((i - 1) % 5 + 1),
         p.TITLE, "%s &middot; %d canciones" % ("Privada" if p.TYPE == 1 else "Publica", p.N))
    for i, p in enumerate(playlists, 1))

HTML = """<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Vista previa - PoliMusic (canciones.asp)</title>
<style>
%(css)s
.nota-preview{
  max-width:1360px;margin:16px 40px 0;padding:12px 18px;border-radius:12px;
  font-size:.84rem;background:rgba(251,191,36,.12);border:1px solid rgba(251,191,36,.45);
  color:#fcd34d;
}
</style>
</head>
<body class="body-app">
<div class="fondo-decorativo fondo-decorativo-app" aria-hidden="true">
  <span class="burbuja burbuja-1"></span><span class="burbuja burbuja-2"></span>
</div>

<p class="nota-preview">
  <strong>Vista previa estatica</strong> de <code>canciones.asp</code> con datos reales de
  <code>BDD_PoliMusic</code>. El reproductor y el CRUD funcionan; las acciones de base de
  datos (guardar/eliminar) requieren IIS con ASP y estan deshabilitadas aqui.
</p>

<div class="app-shell">
<aside class="sidebar">
  <a class="marca" href="#">
    <span class="marca-logo"><svg viewBox="0 0 24 24" width="22" height="22" fill="none"
      stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
      <path d="M9 18V5l12-2v13"></path><circle cx="6" cy="18" r="3"></circle>
      <circle cx="18" cy="16" r="3"></circle></svg></span>
    <span class="marca-texto">PoliMusic</span>
  </a>
  <nav class="nav-menu">
    <a class="nav-enlace activo" href="#">Canciones</a>
    <a class="nav-enlace" href="#">Albums</a>
    <a class="nav-enlace" href="#">Artistas</a>
    <a class="nav-enlace" href="#">Playlists</a>
  </nav>
  <div class="sidebar-pie">
    <p class="sidebar-titulo">Sesion activa</p>
    <div class="tarjeta-usuario">
      <img class="avatar" src="%(base)s/UserImages/root.png" alt="">
      <div class="tarjeta-usuario-datos">
        <strong class="tarjeta-usuario-nombre">userAdmin</strong>
        <span class="badge badge-admin">ADMIN</span>
      </div>
    </div>
    <a class="boton boton-logout" href="#">Cerrar sesion</a>
  </div>
</aside>

<main class="contenido">
  <section class="cabecera-pagina">
    <div>
      <p class="etiqueta-kicker">Panel de escucha</p>
      <h1 class="titulo-pagina">Bienvenido/a, <span class="nombre-resaltado">userAdmin</span></h1>
      <p class="subtitulo-pagina">Tu sesion esta activa con el rol
        <span class="badge badge-admin">ADMIN</span>
        &middot; tienes habilitados los controles de administracion (CRUD).</p>
    </div>
    <div class="cabecera-usuario">
      <img class="avatar avatar-grande" src="%(base)s/UserImages/root.png" alt="">
      <div class="cabecera-usuario-datos">
        <strong>userAdmin</strong><span>usrfakeadmin@epn.edu.ec</span>
      </div>
      <a class="boton boton-secundario" href="#">Cerrar sesion</a>
    </div>
  </section>

  <section class="panel">
    <div class="panel-encabezado">
      <div>
        <h2 class="panel-titulo">Song List</h2>
        <p class="panel-texto">A continuacion se presenta el listado de canciones
          (<strong>Song List</strong>) almacenado en la tabla <code>TBL_SONG</code> de la base de
          datos <code>BDD_PoliMusic</code>. Puedes reproducir cada tema con el boton
          <strong>Reproducir</strong>; el reproductor fijo de la parte inferior permite avanzar,
          pausar y ajustar el volumen.</p>
      </div>
      <div class="panel-contador">
        <span class="contador-numero">%(total)d</span>
        <span class="contador-texto">canciones<br>registradas</span>
      </div>
    </div>
    <div class="tabla-envoltura">
      <table class="tabla-canciones">
        <thead><tr>
          <th class="col-num">#</th><th class="col-titulo">Cancion</th>
          <th class="col-artista">Artista(s)</th><th class="col-archivo">Archivo</th>
          <th class="col-plays">Plays</th><th class="col-accion">Acciones</th>
        </tr></thead>
        <tbody>
%(filas)s
        </tbody>
      </table>
    </div>
  </section>

  <section class="panel">
    <div class="panel-encabezado">
      <div>
        <h2 class="panel-titulo">Administracion de canciones</h2>
        <p class="panel-texto">Solo el rol <strong>ADMIN</strong> puede crear, actualizar y
          eliminar registros de <code>TBL_SONG</code>.</p>
      </div>
      <button class="boton boton-primario" type="button">Nueva cancion</button>
    </div>
    <form class="form-cancion" onsubmit="return false;">
      <div class="form-grilla">
        <label class="campo"><span class="campo-etiqueta">Nombre de la cancion</span>
          <input class="campo-input" value="Adventure" maxlength="50"></label>
        <label class="campo"><span class="campo-etiqueta">Archivo de audio (.mp3)</span>
          <select class="campo-input">
            <option>bensound-adventure.mp3</option>
          </select>
          <span class="campo-ayuda">El archivo se guarda en <code>songFiles/</code>.</span></label>
      </div>
      <div class="form-acciones">
        <span class="form-modo">Modo: crear nueva cancion</span>
        <div class="form-botones">
          <button type="button" class="boton boton-texto">Limpiar formulario</button>
          <button type="submit" class="boton boton-primario">Guardar cancion</button>
        </div>
      </div>
    </form>
  </section>

  <section class="rejilla-tarjetas">
    <article class="tarjeta">
      <h3 class="tarjeta-titulo">Albums mas populares</h3>
      <p class="tarjeta-subtitulo">TBL_ALBUM + TBL_TRACKLIST</p>
%(albums)s
    </article>
    <article class="tarjeta">
      <h3 class="tarjeta-titulo">Playlists recientes</h3>
      <p class="tarjeta-subtitulo">TBL_PLAYLIST + TBL_PLAYLIST_SONG</p>
%(playlists)s
    </article>
  </section>
</main>
</div>

<div class="reproductor" id="reproductor">
  <div class="reproductor-info">
    <div class="reproductor-miniatura" id="repMiniatura">
      <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor"
        stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
        <path d="M9 18V5l12-2v13"></path><circle cx="6" cy="18" r="3"></circle>
        <circle cx="18" cy="16" r="3"></circle></svg>
    </div>
    <div class="reproductor-textos">
      <strong id="repTitulo">Selecciona una cancion</strong>
      <span id="repArtista">Usa el boton reproducir de la tabla</span>
    </div>
  </div>
  <div class="reproductor-controles">
    <button class="btn-icono" id="btnAnterior">
      <svg viewBox="0 0 24 24" width="18" height="18" fill="currentColor">
        <path d="M6 5h2v14H6zM20 5v14l-11-7z"></path></svg></button>
    <button class="btn-icono btn-play" id="btnReproducir">
      <svg id="icoPlay" viewBox="0 0 24 24" width="20" height="20" fill="currentColor">
        <path d="M8 5v14l11-7z"></path></svg>
      <svg id="icoPausa" viewBox="0 0 24 24" width="20" height="20" fill="currentColor"
        style="display:none"><path d="M7 5h4v14H7zM13 5h4v14h-4z"></path></svg></button>
    <button class="btn-icono" id="btnSiguiente">
      <svg viewBox="0 0 24 24" width="18" height="18" fill="currentColor">
        <path d="M16 5h2v14h-2zM4 5v14l11-7z"></path></svg></button>
  </div>
  <div class="reproductor-barra">
    <span class="tiempo" id="repTiempoActual">0:00</span>
    <input type="range" id="repProgreso" class="rango rango-progreso" min="0" max="100" value="0" step="0.1">
    <span class="tiempo" id="repTiempoTotal">0:00</span>
  </div>
  <div class="reproductor-volumen">
    <input type="range" id="repVolumen" class="rango rango-volumen" min="0" max="100" value="80">
  </div>
  <audio id="elementoAudio" preload="none"></audio>
</div>
<div class="aviso-audio" id="avisoAudio"></div>

<script>
%(js)s
</script>
</body>
</html>
""" % {"css": css, "js": js, "base": BASE, "total": len(canciones),
       "filas": "\n".join(filas_html), "albums": alb_html, "playlists": pl_html}

destino = os.path.join(RAIZ, ".workbuddy-ai", "tmp", "preview.html")
io.open(destino, "w", encoding="utf-8").write(HTML)
print("vista previa generada: %s" % destino)
print("canciones renderizadas: %d" % len(canciones))