"""Ejecuta cada consulta SQL usada por las paginas ASP contra la BD real."""
import pyodbc

CS = ('DRIVER={ODBC Driver 17 for SQL Server};SERVER=localhost;'
      'DATABASE=BDD_PoliMusic;UID=usr_polimusic;PWD=Politecnica1')

CONSULTAS = {
    "login: validar credenciales":
        "SELECT ID_USER, USERNAME, PASSWORD, EMAIL, USER_PHOTO, USER_TYPE "
        "FROM TBL_USER WHERE USERNAME = 'userAdmin'",

    "funciones: rol desde catalogo":
        "SELECT VALUE FROM TBL_CATALOG WHERE COD_CATALOG_PARENT='1' AND COD_CATALOG='1'",

    "canciones: listado principal":
        "SELECT s.ID_SONG, s.SONG_NAME, s.SONG_PATH, ISNULL(s.PLAYS,0) AS PLAYS, "
        "(SELECT COUNT(*) FROM TBL_PLAYER p WHERE p.ID_SONG = s.ID_SONG) AS N_ARTISTAS, "
        "(SELECT TOP 1 a.ARTIST_NAME + ' ' + ISNULL(a.ARTIST_LASTNAME,'') "
        " FROM TBL_PLAYER p INNER JOIN TBL_ARTIST a ON p.ID_ARTIST = a.ID_ARTIST "
        " WHERE p.ID_SONG = s.ID_SONG) AS ARTISTA "
        "FROM TBL_SONG s ORDER BY s.SONG_NAME ASC",

    "canciones: albums destacados":
        "SELECT TOP 5 al.ID_ALBUM, al.TITLE_ALBUM, al.RELEASE_YEAR, al.ALBUM_IMAGE_PATH, "
        "(SELECT COUNT(*) FROM TBL_TRACKLIST t WHERE t.ID_ALBUM = al.ID_ALBUM) AS N_CANCIONES "
        "FROM TBL_ALBUM al "
        "ORDER BY N_CANCIONES DESC, al.TITLE_ALBUM ASC",

    "canciones: playlists destacadas":
        "SELECT TOP 5 pl.ID_PLAYLIST, pl.TITLE, pl.CREATION_DATE, pl.TYPE, pl.PHOTO, "
        "(SELECT COUNT(*) FROM TBL_PLAYLIST_SONG ps WHERE ps.ID_PLAYLIST = pl.ID_PLAYLIST) AS N_CANCIONES "
        "FROM TBL_PLAYLIST pl ORDER BY pl.CREATION_DATE DESC",

    "albumes.asp: albums":
        "SELECT al.ID_ALBUM, al.TITLE_ALBUM, al.RELEASE_YEAR, al.ALBUM_IMAGE_PATH, "
        "(SELECT COUNT(*) FROM TBL_TRACKLIST t WHERE t.ID_ALBUM = al.ID_ALBUM) AS N_CANCIONES "
        "FROM TBL_ALBUM al ORDER BY al.RELEASE_YEAR DESC",

    "albumes.asp: artistas":
        "SELECT a.ID_ARTIST, a.ARTIST_NAME, a.ARTIST_LASTNAME, a.ARTIST_IMAGE, "
        "(SELECT COUNT(*) FROM TBL_PLAYER p WHERE p.ID_ARTIST = a.ID_ARTIST) AS N_CANCIONES "
        "FROM TBL_ARTIST a ORDER BY a.ARTIST_NAME ASC",

    "playlists.asp: playlists":
        "SELECT pl.ID_PLAYLIST, pl.TITLE, pl.CREATION_DATE, pl.TYPE, pl.PHOTO, "
        "u.USERNAME, "
        "(SELECT COUNT(*) FROM TBL_PLAYLIST_SONG ps WHERE ps.ID_PLAYLIST = pl.ID_PLAYLIST) AS N_CANCIONES "
        "FROM TBL_PLAYLIST pl "
        "INNER JOIN TBL_USER u ON pl.ID_USER = u.ID_USER "
        "ORDER BY pl.CREATION_DATE DESC",
}

cn = pyodbc.connect(CS, timeout=8)
cur = cn.cursor()
errores = 0

for nombre, sql in CONSULTAS.items():
    try:
        cur.execute(sql)
        filas = cur.fetchall()
        cols = [d[0] for d in cur.description]
        print("[OK]   %-34s %d fila(s), columnas: %s" % (nombre, len(filas), ", ".join(cols)))
        if nombre.startswith("canciones: listado"):
            for f in filas:
                print("        -> id=%s | %s | %s | plays=%s | artista=%s"
                      % (f.ID_SONG, f.SONG_NAME, f.SONG_PATH, f.PLAYS, (f.ARTISTA or "").strip()))
    except Exception as e:
        errores += 1
        print("[ERROR] %-34s %s" % (nombre, str(e).split("]")[-1].strip()))

cn.close()
print("")
print("RESULTADO: %s" % ("todas las consultas validas" if errores == 0
                         else "%d consulta(s) con error" % errores))