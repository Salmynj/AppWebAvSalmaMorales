<%@ Language="VBScript" CodePage="65001" %>
<%
'================================================================================
' logout.asp  -  Cierre de sesion
'--------------------------------------------------------------------------------
' Destruye todas las variables de sesion del usuario y lo devuelve al login.
'================================================================================

Session.Contents.RemoveAll
Session.Abandon

Response.Cookies("pm_usuario").Expires = Now() - 1

Response.Redirect "login.asp?msg=logout"
Response.End
%>