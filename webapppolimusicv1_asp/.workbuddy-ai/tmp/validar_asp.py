"""Validador estructural de paginas ASP clasico (VBScript).

En ASP clasico todos los bloques <% ... %> de una misma pagina se combinan en
un unico ambito de codigo, por lo que una sentencia If puede abrirse en un
bloque y cerrarse en otro. El analizador concatena el flujo VBScript completo
de la pagina (respetando continuaciones de linea con guion bajo) y verifica el
balance de las construcciones de bloque.
"""
import io, os, re

RAIZ = r"C:\Users\salma\Documents\Octavo_Semestre\Web_Avanzadas\AppWebAvSalmaMorales\webapppolimusicv1_asp"

ARCHIVOS = ["index.asp", "login.asp", "logout.asp", "canciones.asp",
            "canciones_accion.asp", "albumes.asp", "artistas.asp",
            "playlists.asp", "conexion.asp", "funciones.asp",
            "header.asp", "footer.asp", "prueba_conexion.asp"]

# (regex de apertura, cierres esperados, requiere coincidencia exacta al inicio)
REGLAS = [
    (re.compile(r"^select\s+case\b"), {"end select"}),
    (re.compile(r"^do(\s+(while|until)\b)?.*$"), {"loop"}),
    (re.compile(r"^while\b"), {"wend"}),
    (re.compile(r"^for\s+each\b"), {"next"}),
    (re.compile(r"^for\b"), {"next"}),
    (re.compile(r"^(sub|function)\s+\w+"), {"end sub", "end function"}),
    (re.compile(r"^with\b"), {"end with"}),
]


def quitar_comentario(linea):
    salida, en_cadena = [], False
    for i, c in enumerate(linea):
        if c == '"':
            en_cadena = not en_cadena
        elif c == "'" and not en_cadena:
            break
        salida.append(c)
    return "".join(salida)


def flujo_vbscript(texto):
    """Concatena todos los bloques <% %> de la pagina en un flujo de codigo."""
    bloques = re.findall(r"<%(.*?)%>", texto, flags=re.S)
    return "\n".join(bloques)


def unir_continuaciones(lineas):
    """Une las lineas terminadas en ' _' con la siguiente."""
    salida, buffer = [], None
    for linea in lineas:
        if buffer is not None:
            buffer = buffer + linea.strip()
        else:
            buffer = linea
        if buffer.rstrip().endswith(" _"):
            buffer = buffer.rstrip()[:-1]
            continue
        salida.append(buffer)
        buffer = None
    if buffer is not None:
        salida.append(buffer)
    return salida


def analizar(codigo):
    problemas = []
    pila = []

    for numero, crudo in enumerate(unir_continuaciones(codigo.split("\n")), 1):
        linea = quitar_comentario(crudo).strip()
        if not linea:
            continue
        bajo = re.sub(r"\s+", " ", linea.lower())

        # --- cierres ---------------------------------------------------------
        cierre = None
        for clave in ("end select", "end sub", "end function", "end if",
                      "next", "loop", "wend", "end with"):
            if bajo.startswith(clave):
                cierre = clave
                break

        if cierre:
            if not pila:
                problemas.append("L%d: '%s' sin bloque abierto" % (numero, cierre))
            elif cierre not in pila[-1]:
                problemas.append("L%d: se cierra '%s' pero estaba abierto '%s'"
                                 % (numero, cierre, pila[-1]))
                pila.pop()
            else:
                pila.pop()
            continue

        # Exit/Continue no abren ni cierran
        if re.match(r"^(exit|continue)\s+(do|for|while|sub|function)\b", bajo):
            continue

        # Else / ElseIf no alteran la pila
        if re.match(r"^else(if)?\b", bajo):
            continue

        # --- aperturas -------------------------------------------------------
        abierto = None
        for patron, cierres in REGLAS:
            if patron.match(bajo):
                abierto = cierres
                break

        if abierto is None and re.match(r"^if\b", bajo):
            # 'If cond Then' abre bloque; 'If cond Then <sentencia>' no lo hace.
            if re.search(r"\bthen\b", bajo):
                cola = bajo.split(" then", 1)[1].strip()
                if cola == "":
                    abierto = {"end if"}

        if abierto:
            pila.append(abierto)

    for pendiente in reversed(pila):
        problemas.append("falta '%s'" % sorted(pendiente)[0])
    return problemas


def revisar(nombre):
    problemas = []
    ruta = os.path.join(RAIZ, nombre)
    texto = io.open(ruta, encoding="utf-8").read()

    for inc in re.findall(r'<!--#include\s+file="([^"]+)"\s*-->', texto, flags=re.I):
        if not os.path.isfile(os.path.join(RAIZ, inc.replace("/", os.sep))):
            problemas.append("include inexistente: %s" % inc)

    if texto.count("<%") != texto.count("%>"):
        problemas.append("desequilibrio de etiquetas <%% %%>: %d abre / %d cierra"
                         % (texto.count("<%"), texto.count("%>")))

    for p in analizar(flujo_vbscript(texto)):
        problemas.append(p)

    # Variable de sesion obligatoria definida en login.asp
    return problemas


fallos = 0
for nombre in ARCHIVOS:
    ruta = os.path.join(RAIZ, nombre)
    if not os.path.isfile(ruta):
        print("[FALTA]  %s" % nombre)
        fallos += 1
        continue
    problemas = revisar(nombre)
    if problemas:
        fallos += 1
        print("[ERROR]  %s" % nombre)
        for p in problemas:
            print("          - %s" % p)
    else:
        print("[OK]     %s" % nombre)

print("")
print("RESULTADO: %s" % ("todos los archivos correctos" if fallos == 0
                         else "%d archivo(s) con problemas" % fallos))