/* ============================================================================
   PoliMusic  -  JavaScript de la pagina de canciones
  ----------------------------------------------------------------------------
   1. Reproductor de audio (play/pausa, anterior/siguiente, progreso, volumen)
   2. CRUD del lado del cliente para el formulario de administracion
   3. Modal de confirmacion para eliminar canciones
   ========================================================================= */
(function () {
  "use strict";

  /* ------------------------------------------------------------ PLAYER --- */
  var audio       = document.getElementById("elementoAudio");
  var btnPlay     = document.getElementById("btnReproducir");
  var btnPrev     = document.getElementById("btnAnterior");
  var btnNext     = document.getElementById("btnSiguiente");
  var icoPlay     = document.getElementById("icoPlay");
  var icoPausa    = document.getElementById("icoPausa");
  var barra       = document.getElementById("repProgreso");
  var volumen     = document.getElementById("repVolumen");
  var tActual     = document.getElementById("repTiempoActual");
  var tTotal      = document.getElementById("repTiempoTotal");
  var repTitulo   = document.getElementById("repTitulo");
  var repArtista  = document.getElementById("repArtista");
  var repMiniatura= document.getElementById("repMiniatura");
  var aviso       = document.getElementById("avisoAudio");

  var filas = Array.prototype.slice.call(document.querySelectorAll(".fila-cancion"));
  var lista = filas.filter(function (f) {
    return f.getAttribute("data-src") && f.getAttribute("data-src") !== "";
  });

  var indiceActual = -1;

  function formatoTiempo(seg) {
    if (!isFinite(seg) || seg < 0) return "0:00";
    var m = Math.floor(seg / 60);
    var s = Math.floor(seg % 60);
    return m + ":" + (s < 10 ? "0" + s : s);
  }

  function pintarBarra(porcentaje) {
    var pct = Math.max(0, Math.min(100, porcentaje || 0));
    barra.style.background =
      "linear-gradient(90deg,#fbbf24 0%,#f472b6 " + pct + "%,rgba(255,255,255,.14) " + pct + "%)";
  }

  function marcarFilaActiva() {
    filas.forEach(function (f) {
      var enCurso = lista.indexOf(f) === indiceActual;
      f.classList.toggle("en-reproduccion", enCurso);

      var boton = f.querySelector(".btn-reproducir");
      if (boton) {
        var iPlay = boton.querySelector(".ico-play-fila");
        var iPausa = boton.querySelector(".ico-pausa-fila");
        if (iPlay) iPlay.style.display = enCurso && !audio.paused ? "none" : "";
        if (iPausa) iPausa.style.display = enCurso && !audio.paused ? "" : "none";
      }
    });
  }

  function actualizarIcono() {
    var reproduciendo = !audio.paused;
    if (icoPlay) icoPlay.style.display = reproduciendo ? "none" : "";
    if (icoPausa) icoPausa.style.display = reproduciendo ? "" : "none";
    marcarFilaActiva();
  }

  function mostrarAviso(texto) {
    if (!aviso) return;
    aviso.textContent = texto;
    aviso.classList.add("visible");
    clearTimeout(mostrarAviso.timer);
    mostrarAviso.timer = setTimeout(function () {
      aviso.classList.remove("visible");
    }, 3200);
  }

  function cargar(indice, debeSonar) {
    if (indice < 0 || indice >= lista.length) return;

    indiceActual = indice;
    var fila = lista[indice];

    var src     = fila.getAttribute("data-src");
    var titulo  = fila.getAttribute("data-titulo");
    var artista = fila.getAttribute("data-artista");
    var cover   = fila.getAttribute("data-cover");
    var idCancion = fila.getAttribute("data-id");

    audio.src = src;

    if (repTitulo) repTitulo.textContent = titulo || "Sin titulo";
    if (repArtista) repArtista.textContent = artista || "Artista desconocido";

    if (repMiniatura) {
      if (cover) {
        repMiniatura.innerHTML = '<img src="' + cover + '" alt="">';
      }
    }

    tActual.textContent = "0:00";
    tTotal.textContent = "0:00";
    pintarBarra(0);

    if (debeSonar) {
      var promesa = audio.play();
      if (promesa && typeof promesa.catch === "function") {
        promesa.catch(function () {
          mostrarAviso("No fue posible reproducir el archivo. Verifica que el mp3 exista en songFiles.");
        });
      }
      // Suma una reproduccion en TBL_SONG
      if (idCancion) {
        var img = new Image();
        img.src = "canciones_accion.asp?accion=play&idSong=" + encodeURIComponent(idCancion);
      }
    }

    actualizarIcono();
  }

  if (lista.length > 0 && audio) {
    if (btnPlay) {
      btnPlay.addEventListener("click", function () {
        if (indiceActual === -1) {
          cargar(0, true);
          return;
        }
        if (audio.paused) {
          var p = audio.play();
          if (p && typeof p.catch === "function") {
            p.catch(function () { mostrarAviso("El navegador bloqueara la reproduccion automatica."); });
          }
        } else {
          audio.pause();
        }
      });
    }

    if (btnPrev) {
      btnPrev.addEventListener("click", function () {
        if (indiceActual <= 0) return;
        cargar(indiceActual - 1, true);
      });
    }

    if (btnNext) {
      btnNext.addEventListener("click", function () {
        if (indiceActual >= lista.length - 1) return;
        cargar(indiceActual + 1, true);
      });
    }

    audio.addEventListener("timeupdate", function () {
      if (audio.duration) {
        tTotal.textContent = formatoTiempo(audio.duration);
        pintarBarra((audio.currentTime / audio.duration) * 100);
      }
      tActual.textContent = formatoTiempo(audio.currentTime);
    });

    audio.addEventListener("ended", function () {
      if (indiceActual < lista.length - 1) {
        cargar(indiceActual + 1, true);
      } else {
        actualizarIcono();
      }
    });

    audio.addEventListener("pause", actualizarIcono);
    audio.addEventListener("play", actualizarIcono);
    audio.addEventListener("error", function () {
      mostrarAviso("Error al cargar el archivo de audio.");
      actualizarIcono();
    });

    barra.addEventListener("input", function () {
      if (audio.duration) {
        audio.currentTime = (barra.value / 100) * audio.duration;
      }
    });

    volumen.addEventListener("input", function () {
      audio.volume = volumen.value / 100;
    });

    audio.volume = volumen.value / 100;

    // Botones de la tabla
    filas.forEach(function (fila) {
      var boton = fila.querySelector(".btn-reproducir");
      if (boton && !boton.disabled) {
        boton.addEventListener("click", function () {
          var pos = lista.indexOf(fila);
          if (pos === indiceActual && !audio.paused) {
            audio.pause();
          } else {
            cargar(pos, true);
          }
        });
      }

      var btnFila = fila.querySelector(".js-reproducir");
      if (btnFila) {
        btnFila.addEventListener("click", function () {
          cargar(lista.indexOf(fila), true);
        });
      }
    });
  }

  /* -------------------------------------------------------------- CRUD --- */
  var form      = document.getElementById("formCancion");
  var btnNueva  = document.getElementById("btnNueva");
  var btnCancel = document.getElementById("btnCancelar");
  var campoId   = document.getElementById("idSong");
  var campoNom  = document.getElementById("songName");
  var campoRuta = document.getElementById("songPath");
  var campoAcc  = form ? form.querySelector('input[name="accion"]') : null;
  var textoModo = document.getElementById("formModo");
  var btnGuardar= document.getElementById("btnGuardar");

  if (form) {
    function modoCrear() {
      if (campoAcc) campoAcc.value = "crear";
      if (campoId) campoId.value = "0";
      if (textoModo) textoModo.textContent = "Modo: crear nueva cancion";
      if (btnGuardar) btnGuardar.textContent = "Guardar cancion";
    }

    function modoEditar(id, nombre, ruta) {
      if (campoAcc) campoAcc.value = "editar";
      if (campoId) campoId.value = id;
      if (campoNom) campoNom.value = nombre;
      if (campoRuta) campoRuta.value = ruta;
      if (textoModo) textoModo.textContent = 'Modo: editando "' + nombre + '" (ID ' + id + ')';
      if (btnGuardar) btnGuardar.textContent = "Guardar cambios";

      form.scrollIntoView({ behavior: "smooth", block: "center" });
      if (campoNom) campoNom.focus();
    }

    if (btnNueva) {
      btnNueva.addEventListener("click", function () {
        form.reset();
        modoCrear();
        form.scrollIntoView({ behavior: "smooth", block: "center" });
        if (campoNom) campoNom.focus();
      });
    }

    if (btnCancel) {
      btnCancel.addEventListener("click", function () {
        form.reset();
        modoCrear();
      });
    }

    var botonesEditar = document.querySelectorAll(".js-editar");
    Array.prototype.forEach.call(botonesEditar, function (boton) {
      boton.addEventListener("click", function () {
        modoEditar(
          boton.getAttribute("data-id"),
          boton.getAttribute("data-nombre"),
          boton.getAttribute("data-ruta")
        );
      });
    });

    // Al enviar, se deshabilita el boton para evitar doble inserccion
    form.addEventListener("submit", function () {
      if (btnGuardar) {
        btnGuardar.disabled = true;
        btnGuardar.textContent = "Guardando...";
      }
    });
  }

  /* ------------------------------------------------------------- MODAL --- */
  var modal      = document.getElementById("modalEliminar");
  var nombreElim = document.getElementById("nombreEliminar");
  var linkConf   = document.getElementById("btnConfirmarEliminar");
  var btnCancelE = document.getElementById("btnCancelarEliminar");

  if (modal && linkConf) {
    var botonesEliminar = document.querySelectorAll(".js-eliminar");

    Array.prototype.forEach.call(botonesEliminar, function (boton) {
      boton.addEventListener("click", function () {
        var id = boton.getAttribute("data-id");
        var nom = boton.getAttribute("data-nombre");
        if (nombreElim) nombreElim.textContent = nom;
        linkConf.href = "canciones_accion.asp?accion=eliminar&idSong=" + encodeURIComponent(id);
        modal.classList.add("abierto");
        modal.setAttribute("aria-hidden", "false");
      });
    });

    function cerrarModal() {
      modal.classList.remove("abierto");
      modal.setAttribute("aria-hidden", "true");
    }

    if (btnCancelE) btnCancelE.addEventListener("click", cerrarModal);

    modal.addEventListener("click", function (ev) {
      if (ev.target === modal) cerrarModal();
    });

    document.addEventListener("keydown", function (ev) {
      if (ev.key === "Escape") cerrarModal();
    });
  }

  /* ---------------------------------------------------- ATAJOS TECLADO --- */
  document.addEventListener("keydown", function (ev) {
    var etiqueta = (ev.target.tagName || "").toLowerCase();
    if (etiqueta === "input" || etiqueta === "select" || etiqueta === "textarea") return;

    if (ev.code === "Space") {
      ev.preventDefault();
      if (btnPlay) btnPlay.click();
    } else if (ev.key === "ArrowRight" && ev.shiftKey) {
      if (btnNext) btnNext.click();
    } else if (ev.key === "ArrowLeft" && ev.shiftKey) {
      if (btnPrev) btnPrev.click();
    }
  });
})();