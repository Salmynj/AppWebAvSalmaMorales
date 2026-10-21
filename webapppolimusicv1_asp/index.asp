<%@ Language="VBScript" CodePage="65001" %>
<!--#include file="conexion.asp"-->
<!--#include file="funciones.asp"-->
<%
' ================================================================================
' index.asp  -  Puerta de entrada de PoliMusic
' --------------------------------------------------------------------------------
' Redirige al login o al listado de canciones segun exista o no sesion activa.
' ================================================================================

If HaySesion() Then
    Response.Redirect "canciones.asp"
Else
    Response.Redirect "login.asp"
End If
Response.End
%>