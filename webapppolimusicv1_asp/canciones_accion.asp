<%@ Language="VBScript" CodePage="65001" %>
<!--#include file="conexion.asp"-->
<!--#include file="funciones.asp"-->
<%
'================================================================================
' canciones_accion.asp  -  Procesamiento del CRUD de canciones (solo ADMIN)
'--------------------------------------------------------------------------------
' Este archivo NO genera interfaz: recibe el POST/GET de la pagina de canciones,
' valida que la sesion sea ADMIN, ejecuta la operacion sobre TBL_SONG y devuelve
' el control a canciones.asp con un mensaje en la variable de sesion.
'
'Operaciones soportadas:
'     accion=crear    -> INSERT en TBL_SONG
'    accion=editar   -> UPDATE en TBL_SONG
'     accion=eliminar -> DELETE en TBL_SONG (en cascada logica sobre las tablas
'                        hijas TBL_TRACKLIST, TBL_PLAYER y TBL_PLAYLIST_SONG)
'     accion=play     -> UPDATE PLAYS = PLAYS + 1
'================================================================================
%>

<%
' --- Control de seguridad ---------------------------------------------------
' Reproducir lo puede hacer cualquier usuario con sesion; crear, editar y
' eliminar son operaciones exclusivas del rol ADMIN.
ExigirSesion

Dim accion, msg, tipoMsg

accion = Trim(Request("accion"))
msg = ""
tipoMsg = "exito"

If accion <> "play" Then
    ExigirAdmin
End If

Select Case accion

    ' -------------------------------------------------------------- CREAR ----
    Case "crear"
        Dim nombre, ruta, rutaFinal
        nombre = Trim(Request.Form("songName"))
        ruta   = Trim(Request.Form("songPath"))

        If Len(nombre) = 0 Or Len(nombre) > 50 Then
            msg = "El nombre de la cancion es obligatorio y debe tener maximo 50 caracteres."
            tipoMsg = "error"
        ElseIf Not EsRutaValida(ruta) Then
            msg = "Debes indicar un archivo de audio .mp3 existente dentro de la carpeta songFiles."
            tipoMsg = "error"
        Else
            rutaFinal = NormalizaRuta(ruta)
            If YaExiste(rutaFinal) Then
                msg = "Ya existe una cancion registrada con esa misma ruta de archivo."
                tipoMsg = "error"
            Else
                EjecutarSeguro "INSERT INTO TBL_SONG (SONG_NAME, SONG_PATH, PLAYS) VALUES ('" & _
                        Q(nombre) & "', '" & Q(rutaFinal) & "', 0)", _
                        "No se pudo registrar la cancion en la base de datos."
                msg = "Cancion '" & nombre & "' registrada correctamente."
            End If
        End If

    ' -------------------------------------------------------------- EDITAR ---
    Case "editar"
        Dim idEd, nomEd, rutaEd
        idEd  = Entero(Request.Form("idSong"))
        nomEd = Trim(Request.Form("songName"))
        rutaEd = Trim(Request.Form("songPath"))

        If idEd <= 0 Then
            msg = "El identificador de la cancion no es valido."
            tipoMsg = "error"
        ElseIf Len(nomEd) = 0 Or Len(nomEd) > 50 Then
            msg = "El nombre de la cancion es obligatorio y debe tener maximo 50 caracteres."
            tipoMsg = "error"
        ElseIf Not EsRutaValida(rutaEd) Then
            msg = "Debes indicar un archivo de audio .mp3 existente dentro de la carpeta songFiles."
            tipoMsg = "error"
        Else
            rutaEd = NormalizaRuta(rutaEd)
            EjecutarSeguro "UPDATE TBL_SONG SET SONG_NAME = '" & Q(nomEd) & "', " & _
                     "SONG_PATH = '" & Q(rutaEd) & "' WHERE ID_SONG = " & idEd, _
                     "No se pudo actualizar la cancion en la base de datos."
            msg = "Cancion actualizada correctamente."
        End If

    ' ------------------------------------------------------------ ELIMINAR ---
    Case "eliminar"
        Dim idEl, nombreEl
        idEl = Entero(Request("idSong"))

        If idEl <= 0 Then
            msg = "El identificador de la cancion no es valido."
            tipoMsg = "error"
        Else
            nombreEl = NombreCancion(idEl)
            If Len(nombreEl) = 0 Then
                msg = "La cancion solicitada no existe."
                tipoMsg = "error"
            Else
                ' Se eliminan primero las filas hijas para respetar las FK
                Dim msgError
                msgError = "No se pudo eliminar la cancion '" & nombreEl & "' de la base de datos."
                EjecutarSeguro "DELETE FROM TBL_PLAYLIST_SONG WHERE ID_SONG = " & idEl, msgError
                EjecutarSeguro "DELETE FROM TBL_TRACKLIST WHERE ID_SONG = " & idEl, msgError
                EjecutarSeguro "DELETE FROM TBL_PLAYER WHERE ID_SONG = " & idEl, msgError
                EjecutarSeguro "DELETE FROM TBL_SONG WHERE ID_SONG = " & idEl, msgError
                msg = "Cancion '" & nombreEl & "' eliminada de la biblioteca."
            End If
        End If

    ' ------------------------------------------------------- SUMAR PLAY ------
    Case "play"
        Dim idPl
        idPl = Entero(Request("idSong"))
        If idPl > 0 Then
            ' El contador no es critico: si falla, el sitio sigue funcionando.
            On Error Resume Next
            Ejecutar "UPDATE TBL_SONG SET PLAYS = ISNULL(PLAYS,0) + 1 WHERE ID_SONG = " & idPl
            Err.Clear
            On Error GoTo 0
        End If
        ' Se invoca en segundo plano desde JavaScript: no redirige ni pinta HTML.
        Response.ContentType = "text/plain"
        Response.Write "ok"
        Response.End

    Case Else
        msg = "Operacion no reconocida."
        tipoMsg = "error"
End Select

' --- Mensaje de retorno -------------------------------------------------------
Session("mensaje") = msg
Session("tipoMensaje") = tipoMsg
Session("pestana") = "canciones"
Response.Redirect "canciones.asp"
Response.End


' =============================================================================
' Funciones auxiliares locales
' =============================================================================

' Normaliza la ruta al formato guardado en la base de datos: '~/songFiles/x.mp3'
Function NormalizaRuta(ruta)
    Dim p, pos
    p = Trim(ruta)
    p = Replace(p, "\", "/")

    ' Quita el prefijo '~/' que usa la base de datos
    If Left(p, 2) = "~/" Then p = Mid(p, 3)

    ' Si ya contiene 'songFiles/', se conserva solo el nombre del archivo
    pos = InStr(1, p, "songFiles/", vbTextCompare)
    If pos > 0 Then
        p = Mid(p, pos + Len("songFiles/"))
    End If

    ' Quita cualquier barra inicial sobrante
    Do While Left(p, 1) = "/"
        p = Mid(p, 2)
    Loop

    NormalizaRuta = "~/songFiles/" & p
End Function

' Verifica que la ruta apunte a un .mp3 que exista fisicamente en songFiles
Function EsRutaValida(ruta)
    Dim p, url
    EsRutaValida = False
    If Len(Trim(ruta)) = 0 Then Exit Function

    p = NormalizaRuta(ruta)
    If LCase(Right(p, 4)) <> ".mp3" Then Exit Function

    url = Mid(p, 3)   ' quita '~/'
    EsRutaValida = ArchivoExiste(url)
End Function

' Indica si ya hay una cancion usando esa misma ruta
Function YaExiste(rutaCompleta)
    Dim rs, n
    n = 0
    On Error Resume Next
    Set rs = Consulta("SELECT COUNT(*) AS TOTAL FROM TBL_SONG WHERE SONG_PATH = '" & Q(rutaCompleta) & "'")
    If Err.Number = 0 And IsObject(rs) And Not rs.EOF Then n = CLng(rs.Fields("TOTAL").Value)
    Err.Clear
    On Error GoTo 0
    If IsObject(rs) Then
        rs.Close
        Set rs = Nothing
    End If
    YaExiste = (n > 0)
End Function

' Devuelve el nombre de una cancion por su ID
Function NombreCancion(id)
    Dim rs, n
    n = ""
    On Error Resume Next
    Set rs = Consulta("SELECT SONG_NAME FROM TBL_SONG WHERE ID_SONG = " & CLng(id))
    If Err.Number = 0 And IsObject(rs) And Not rs.EOF Then n = CStr(rs.Fields("SONG_NAME").Value)
    Err.Clear
    On Error GoTo 0
    If IsObject(rs) Then
        rs.Close
        Set rs = Nothing
    End If
    NombreCancion = n
End Function
%>