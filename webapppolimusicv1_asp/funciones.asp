<%
' ================================================================================
' funciones.asp  -  Funciones de soporte de la aplicacion PoliMusic
' --------------------------------------------------------------------------------
' Contiene: control de sesion y roles, escape de datos, resolucion de rutas
' de los assets y utilidades de presentacion.
' ================================================================================
%>

<%
' ---------------------------------------------------------------------------
' SESION Y ROLES
' ---------------------------------------------------------------------------

' Indica si ya existe un usuario autenticado en la sesion actual.
Function HaySesion()
    HaySesion = (Len(Trim(CStr(Session("usuario")))) > 0)
End Function

' 1 = ADMIN (USER_TYPE = 1) ; 0 = usuario normal (USER_TYPE = 0)
Function EsAdmin()
    EsAdmin = (CStr(Session("userType")) = "1")
End Function

' Etiqueta legible del rol segun el catalogo TBL_CATALOG.
Function NombreRol()
    If EsAdmin() Then
        NombreRol = "ADMIN"
    Else
        NombreRol = "USER"
    End If
End Function

' Redirige al login si la pagina exige sesion activa.
Sub ExigirSesion()
    If Not HaySesion() Then
        Response.Redirect "login.asp?msg=sesion"
        Response.End
    End If
End Sub

' Redirige al login si el usuario no tiene rol ADMIN.
Sub ExigirAdmin()
    ExigirSesion
    If Not EsAdmin() Then
        Response.Redirect "canciones.asp?msg=sin_permiso"
        Response.End
    End If
End Sub

' ---------------------------------------------------------------------------
' ESCAPE Y VALIDACION
' ---------------------------------------------------------------------------

' Escapa HTML para imprimir texto vindo de la base de datos.
Function E(str)
    If IsNull(str) Then str = ""
    If IsEmpty(str) Then str = ""
    E = Server.HTMLEncode(CStr(str))
End Function

' Escapa comillas simples para construir sentencias SQL seguras.
Function Q(str)
    If IsNull(str) Then str = ""
    If IsEmpty(str) Then str = ""
    Q = Replace(CStr(str), "'", "''")
End Function

' Recorta espacios y escapa HTML en un solo paso (usar en formularios).
Function Limpio(str)
    Dim t
    If IsNull(str) Or IsEmpty(str) Then
        t = ""
    Else
        t = Trim(CStr(str))
    End If
    Limpio = Server.HTMLEncode(t)
End Function

' Convierte a entero de forma segura (0 si no es numerico).
Function Entero(str)
    If IsNumeric(str) Then
        Entero = CLng(str)
    Else
        Entero = 0
    End If
End Function

' ---------------------------------------------------------------------------
' RUTAS DE ASSETS
' La base de datos guarda las rutas con el prefijo "~/"
' (ej: '~/songFiles/bensound-adventure.mp3'). Esta funcion las convierte a una
' URL relativa valida para el navegador.
' ---------------------------------------------------------------------------
Function RutaWeb(path)
    Dim p
    If IsNull(path) Or IsEmpty(path) Then
        RutaWeb = ""
        Exit Function
    End If
    p = Trim(CStr(path))
    If Len(p) = 0 Then
        RutaWeb = ""
        Exit Function
    End If
    If Left(p, 2) = "~/" Then
        p = Mid(p, 3)
    End If
    RutaWeb = p
End Function

' Nombre del archivo a partir de la ruta completa.
Function NombreArchivo(path)
    Dim p, i
    p = RutaWeb(path)
    i = InStrRev(p, "/")
    If i > 0 Then
        NombreArchivo = Mid(p, i + 1)
    Else
        NombreArchivo = p
    End If
End Function

' Verifica en disco que el archivo exista realmente.
Function ArchivoExiste(pathWeb)
    Dim fso, fs
    On Error Resume Next
    Set fso = Server.CreateObject("Scripting.FileSystemObject")
    If Err.Number <> 0 Then
        Err.Clear
        ArchivoExiste = False
        Set fso = Nothing
        Exit Function
    End If
    Set fs = fso.GetFile(Server.MapPath(pathWeb))
    If Err.Number <> 0 Then
        Err.Clear
        ArchivoExiste = False
    Else
        ArchivoExiste = True
    End If
    On Error GoTo 0
    Set fs = Nothing
    Set fso = Nothing
End Function

' Construye la URL publica de una cancion y verifica que exista en disco.
Function UrlCancion(path)
    Dim u
    u = RutaWeb(path)
    If ArchivoExiste(u) Then
        UrlCancion = u
    Else
        UrlCancion = ""
    End If
End Function

' ---------------------------------------------------------------------------
' PRESENTACION
' ---------------------------------------------------------------------------

' Convierte un numero de reproducciones en un texto corto (1.2K).
Function FormatoPlays(n)
    If IsNumeric(n) Then
        If CLng(n) >= 1000 Then
            FormatoPlays = FormatNumber(CDbl(n) / 1000, 1) & "K"
        Else
            FormatoPlays = CStr(CLng(n))
        End If
    Else
        FormatoPlays = "0"
    End If
End Function

' Construye una clase CSS a partir del rol para pintar el badge.
Function ClaseRol()
    If EsAdmin() Then
        ClaseRol = "badge badge-admin"
    Else
        ClaseRol = "badge badge-user"
    End If
End Function

' URL de la foto del usuario con respaldo a la imagen por defecto.
Function UrlFoto(path)
    Dim u
    u = RutaWeb(path)
    If Len(u) = 0 Or Not ArchivoExiste(u) Then
        UrlFoto = "userImages/default.jpg"
    Else
        UrlFoto = u
    End If
End Function

' ---------------------------------------------------------------------------
' MANEJO DE ERRORES DE BASE DE DATOS
' ---------------------------------------------------------------------------

' Muestra una alerta amigable y, si MODO_DEBUG esta activo en conexion.asp,
' el detalle tecnico real (numero y descripcion del error de ADODB/SQL Server).
' Poner MODO_DEBUG = False antes de entregar el laboratorio.
Sub MostrarErrorBD(mensaje, numErr, txtErr)
    Response.Write "<div class='alerta alerta-error' role='alert'>" & E(mensaje) & "</div>"
    If MODO_DEBUG Then
        Response.Write "<details class='alerta alerta-error detalle-tecnico'>" & _
                       "<summary>Detalle tecnico del error</summary><pre>" & _
                       E("Error " & CStr(numErr) & ": " & CStr(txtErr)) & "</pre></details>"
    End If
End Sub

' Consulta a la base de datos con manejo de errores. Si la consulta falla,
' escribe el error en pantalla y detiene la pagina.
Function ConsultaSegura(sql, mensajeError)
    Dim rs, numErr, txtErr
    On Error Resume Next
    Set rs = Consulta(sql)
    numErr = Err.Number
    txtErr = Err.Description
    Err.Clear
    On Error GoTo 0

    If numErr <> 0 Then
        MostrarErrorBD mensajeError, numErr, txtErr
        Response.End
    End If

    Set ConsultaSegura = rs
End Function

' Ejecuta una sentencia de escritura (INSERT / UPDATE / DELETE) con manejo de
' errores. Si falla, muestra el detalle tecnico y detiene la pagina.
Function EjecutarSeguro(sql, mensajeError)
    Dim affected, numErr, txtErr
    On Error Resume Next
    affected = Ejecutar(sql)
    numErr = Err.Number
    txtErr = Err.Description
    Err.Clear
    On Error GoTo 0

    If numErr <> 0 Then
        MostrarErrorBD mensajeError, numErr, txtErr
        Response.End
    End If

    EjecutarSeguro = affected
End Function

' Traduce el valor de USER_TYPE usando el catalogo TBL_CATALOG.
Function TextoRolDesdeCatalogo(idTipo)
    Dim rs, v
    v = "USER"
    On Error Resume Next
    Set rs = Consulta("SELECT VALUE FROM TBL_CATALOG WHERE COD_CATALOG_PARENT='1' AND COD_CATALOG='" & Q(idTipo) & "'")
    If Err.Number <> 0 Then
        Err.Clear
        v = "USER"
    ElseIf IsObject(rs) Then
        If Not rs.EOF Then v = CStr(rs.Fields("VALUE").Value)
        rs.Close
        Set rs = Nothing
    End If
    On Error GoTo 0
    TextoRolDesdeCatalogo = v
End Function
%>