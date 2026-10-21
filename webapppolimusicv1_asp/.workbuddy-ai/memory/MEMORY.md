# MEMORIA DEL PROYECTO - webapppolimusicv1_asp

## Qué es
Clon de Spotify desarrollado en **ASP clásico (VBScript)** para la materia
Aplicaciones Web Avanzadas (Octavo Semestre). Prohibido usar ASP.NET con C#.

## Base de datos
- Motor: SQL Server 2025 en `localhost`, instancia por defecto.
- BD `BDD_PoliMusic`, usuario `usr_polimusic` / `Politecnica1`.
- El script de creación está en `../BDD_PoliMusic.sql` (codificado en UTF-16LE,
  hay que convertirlo con `iconv -f UTF-16LE -t UTF-8` para leerlo).
- **Regla del laboratorio: NO crear tablas adicionales.** Solo las del script.
- `TBL_USER.USER_TYPE`: 0 = usuario normal, 1 = admin.
- `TBL_CATALOG` guarda las etiquetas de rol (`COD_CATALOG_PARENT='1'`).

## Usuarios de prueba
- `userAdmin` / `12345678` → rol ADMIN (puede hacer CRUD)
- `userNormal` / `12345678` → rol USER (solo escucha)

## Convenciones del código
- Todas las páginas son `.asp` y empiezan con
  `<%@ Language="VBScript" CodePage="65001" %>` seguido de los includes
  `conexion.asp` y `funciones.asp`.
- Los includes viven en la **raíz**, no en subcarpeta (ASP resuelve mal las
  rutas relativas de `#include`).
- Las rutas en la BD usan el prefijo `~/` (ej. `~/songFiles/x.mp3`); la función
  `RutaWeb()` las convierte a URL relativa.
- Los assets reales son solo: `SongFiles/bensound-adventure.mp3`,
  `UserImages/{default.jpg,root.png}`, `PlaylistImages/playlist1-5.png`.
  Todo lo demás (álbumes, artistas) no tiene imagen y usa `img/cover-*.svg`.
- Se evitan acentos en el código para no depender de la página de códigos.

## Flujo
`index.asp` → `login.asp` (guarda `Session("usuario")`, `Session("userType")`,
`Session("foto")`, `Session("email")`) → `canciones.asp` (Song List + CRUD +
reproductor) → `logout.asp`.

## Despliegue
Copiar el contenido de esta carpeta a `C:\inetpub\wwwroot`. Requiere permisos de
administrador (no disponibles en este entorno). En IIS debe estar habilitado el
soporte para ASP clásico. Si el SQL Server corre en Docker, cambiar
`BD_SERVIDOR` en `conexion.asp` a `localhost,14333`.

## Diseño
Paleta propia: índigo/violeta (`#8b6df0`) + ámbar (`#fbbf24`) + rosa
(`#f472b6`). Nada de verde Spotify. Estilos en `css/polimusic.css`.
