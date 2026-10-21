<%@ Language="VBScript" CodePage="65001" %>
<!--#include file="conexion.asp"-->
<!--#include file="funciones.asp"-->
<%
'================================================================================
' artistas.asp  -  Los artistas se muestran junto a los albums en albumes.asp
'================================================================================
ExigirSesion
Response.Redirect "albumes.asp#artistas"
Response.End
%>