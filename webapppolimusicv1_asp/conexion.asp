<%
' ================================================================================
' conexion.asp  -  Punto unico de conexion a la base de datos BDD_PoliMusic
' ================================================================================
%>

<%
' 1. Configuración hacia la Instancia Predeterminada y usuario administrador
Const BD_SERVIDOR = "."
Const BD_BASE     = "BDD_PoliMusic"
Const BD_USUARIO  = "sa"
Const BD_CLAVE    = "Politecnica1"

Const RUTA_CANCIONES = "~/songFiles/"
Const RUTA_USUARIOS  = "~/userImages/"
Const RUTA_ALBUMES   = "~/playlistImages/"
Const MODO_DEBUG = True

Const adUseClient    = 3
Const adOpenStatic   = 3
Const adLockReadOnly = 1
Const adCmdText      = 1
%>

<%
Function CadenasConexion()
    Dim lista(3)
    ' 2. Priorizamos el proveedor SQLOLEDB estándar
    lista(0) = "Provider=SQLOLEDB;Data Source=" & BD_SERVIDOR & ";Initial Catalog=" & BD_BASE & ";User ID=" & BD_USUARIO & ";Password=" & BD_CLAVE & ";"
    lista(1) = "Provider=MSOLEDBSQL;Data Source=" & BD_SERVIDOR & ";Initial Catalog=" & BD_BASE & ";User ID=" & BD_USUARIO & ";Password=" & BD_CLAVE & ";"
    lista(2) = "Driver={ODBC Driver 17 for SQL Server};Server=" & BD_SERVIDOR & ";Database=" & BD_BASE & ";Uid=" & BD_USUARIO & ";Pwd=" & BD_CLAVE & ";"
    lista(3) = "Driver={SQL Server};Server=" & BD_SERVIDOR & ";Database=" & BD_BASE & ";Uid=" & BD_USUARIO & ";Pwd=" & BD_CLAVE & ";"
    CadenasConexion = lista
End Function

Function ConnectionString()
    Dim lista
    lista = CadenasConexion()
    ConnectionString = lista(0)
End Function

Function Conectar()
    Dim cn, lista, i, cadena, fallos, abierta, detalle
    lista   = CadenasConexion()
    abierta = False
    fallos  = ""

    For i = 0 To UBound(lista)
        cadena = lista(i)
        Set cn = Server.CreateObject("ADODB.Connection")
        cn.ConnectionTimeout = 10

        On Error Resume Next
        Err.Clear
        cn.Open cadena
        If Err.Number = 0 Then
            abierta = True
        Else
            detalle = Err.Description
            Err.Clear
            fallos = fallos & "<li><code>" & Server.HTMLEncode(cadena) & "</code><br>" & Server.HTMLEncode(detalle) & "</li>"
        End If
        On Error GoTo 0

        If abierta Then Exit For Else Set cn = Nothing
    Next

    If Not abierta Then
        Response.Write "<div style='background:#fee2e2; border:1px solid #ef4444; padding:15px; color:#b91c1c;'>" & _
            "<strong>Error crítico de conexión.</strong><ul>" & fallos & "</ul></div>"
        Response.End
    End If

    Set Conectar = cn
End Function

Function Consulta(sql)
    Dim cn, rs
    Set cn = Conectar()
    Set rs = Server.CreateObject("ADODB.Recordset")
    rs.CursorLocation = adUseClient
    
    ' 3. Imprimimos el error directo en pantalla si la consulta SQL falla
    On Error Resume Next
    rs.Open sql, cn, adOpenStatic, adLockReadOnly, adCmdText
    
    If Err.Number <> 0 Then
        Response.Write "<div style='background:#fee2e2; padding:15px; color:red; border:1px solid red;'>" & _
                       "<strong>Error SQL:</strong> " & Err.Description & "<br><strong>Comando:</strong> " & sql & "</div>"
        Response.End
    End If
    On Error GoTo 0
    
    Set rs.ActiveConnection = Nothing
    cn.Close
    Set cn = Nothing
    Set Consulta = rs
End Function

Function Ejecutar(sql)
    Dim cn, affected
    Set cn = Conectar()
    cn.Execute sql, affected
    cn.Close
    Set cn = Nothing
    Ejecutar = affected
End Function
%>