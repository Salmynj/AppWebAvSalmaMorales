<%
' ================================================================================
' header.asp  -  Cabecera comun del sitio (logotipo, navegacion, usuario)
' --------------------------------------------------------------------------------
' Espera que la pagina que lo incluye ya haya validado la sesion.
' ================================================================================
%>
  </main>
</div>

<%' ------------------------------------------------------------ Reproductor --%>
<div class="reproductor" id="reproductor">
  <div class="reproductor-info">
    <div class="reproductor-miniatura" id="repMiniatura">
      <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 18V5l12-2v13"></path><circle cx="6" cy="18" r="3"></circle><circle cx="18" cy="16" r="3"></circle></svg>
    </div>
    <div class="reproductor-textos">
      <strong id="repTitulo">Selecciona una cancion</strong>
      <span id="repArtista">Usa el boton reproducir de la tabla</span>
    </div>
  </div>

  <div class="reproductor-controles">
    <button class="btn-icono" id="btnAnterior" title="Anterior" aria-label="Cancion anterior">
      <svg viewBox="0 0 24 24" width="18" height="18" fill="currentColor"><path d="M6 5h2v14H6zM20 5v14l-11-7z"></path></svg>
    </button>
    <button class="btn-icono btn-play" id="btnReproducir" title="Reproducir / Pausa" aria-label="Reproducir o pausar">
      <svg id="icoPlay" viewBox="0 0 24 24" width="20" height="20" fill="currentColor"><path d="M8 5v14l11-7z"></path></svg>
      <svg id="icoPausa" viewBox="0 0 24 24" width="20" height="20" fill="currentColor" style="display:none"><path d="M7 5h4v14H7zM13 5h4v14h-4z"></path></svg>
    </button>
    <button class="btn-icono" id="btnSiguiente" title="Siguiente" aria-label="Cancion siguiente">
      <svg viewBox="0 0 24 24" width="18" height="18" fill="currentColor"><path d="M16 5h2v14h-2zM4 5v14l11-7z"></path></svg>
    </button>
  </div>

  <div class="reproductor-barra">
    <span class="tiempo" id="repTiempoActual">0:00</span>
    <input type="range" id="repProgreso" class="rango rango-progreso" min="0" max="100" value="0" step="0.1" aria-label="Progreso de la cancion">
    <span class="tiempo" id="repTiempoTotal">0:00</span>
  </div>

  <div class="reproductor-volumen">
    <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 5 6 9H2v6h4l5 4z"></path><path d="M19.07 4.93a10 10 0 0 1 0 14.14M15.54 8.46a5 5 0 0 1 0 7.07"></path></svg>
    <input type="range" id="repVolumen" class="rango rango-volumen" min="0" max="100" value="80" aria-label="Volumen">
  </div>

  <audio id="elementoAudio" preload="none"></audio>
</div>

<div class="aviso-audio" id="avisoAudio" role="status" aria-live="polite"></div>

<script src="js/polimusic.js"></script>
</body>
</html>