# -*- coding: utf-8 -*-
"""Builds a static preview of Song.aspx (same markup the Web Forms page renders)."""

import html
import os

SONGS = [
    (1, "Adventure", "~/songFiles/bensound-adventure.mp3", 0),
    (2, "Dreams", "~/songFiles/bensound-dreams.mp3", 1),
    (3, "Energy", "~/songFiles/bensound-energy.mp3", 2),
    (4, "Scifi", "~/songFiles/bensound-scifi.mp3", 3),
    (5, "Tomorrow", "~/songFiles/bensound-tomorrow.mp3", 1_284),
]

PLAY_ICON = '<svg class="icon-play" viewBox="0 0 24 24" aria-hidden="true"><path d="M8 5.1v13.8L19 12z"/></svg>'
PAUSE_ICON = '<svg class="icon-pause" viewBox="0 0 24 24" aria-hidden="true"><path d="M6.5 5h3.8v14H6.5zM13.7 5h3.8v14h-3.8z"/></svg>'
VOL_ICON = (
    '<svg class="icon-volume" viewBox="0 0 24 24" aria-hidden="true">'
    '<path d="M4 9.5h3.2L12 5.6v12.8L7.2 14.5H4z"/>'
    '<path d="M15.4 9.2a4 4 0 0 1 0 5.6" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round"/>'
    '<path d="M17.9 6.7a7.5 7.5 0 0 1 0 10.6" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round"/>'
    "</svg>"
)

ROW = """
<tr class="song-row">
  <td class="col-id"><span class="song-id">{id}</span></td>
  <td class="col-name">
    <div class="song-name-cell">
      <span class="song-cover">{initial}</span>
      <span class="song-name">{name}</span>
      <span class="song-eq" aria-hidden="true"><i></i><i></i><i></i></span>
    </div>
  </td>
  <td class="col-path"><span class="song-path">{path}</span></td>
  <td class="col-plays"><span class="plays-pill">{plays}</span></td>
  <td class="col-player">
    <div class="player">
      <span class="player-ref" hidden>{id}</span>
      <span class="player-src" hidden>/songFiles/x.mp3</span>
      <audio preload="none"></audio>
      <button type="button" class="player-btn player-toggle" aria-label="Play" title="Play / Pause">{play}{pause}</button>
      <span class="player-time"><span class="player-current">0:00</span><span class="player-sep">/</span><span class="player-duration">3:07</span></span>
      <div class="player-track" title="Seek"><span class="player-fill"></span></div>
      <button type="button" class="player-btn player-mute" aria-label="Mute" title="Mute">{vol}</button>
      <input type="range" class="player-volume" min="0" max="1" step="0.05" value="0.8" aria-label="Volume" />
    </div>
  </td>
</tr>"""

rows = []
for index, (song_id, name, path, plays) in enumerate(SONGS):
    rows.append(ROW.format(
        id=song_id,
        initial=html.escape(name[0].upper()),
        name=html.escape(name),
        path=html.escape(path),
        plays=format(plays, ","),
        play=PLAY_ICON,
        pause=PAUSE_ICON,
        vol=VOL_ICON,
    ))

PAGE = """<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
<title>PoliMusic | Song list</title>
<link rel="stylesheet" href="../../Content/PoliMusic.css" />
</head>
<body>
<form>
<header class="topbar">
  <div class="topbar-inner">
    <a class="brand" href="#">
      <span class="brand-mark"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M9 17.5V6.2l9-1.8v9.1"/><circle cx="6.6" cy="18" r="2.4"/><circle cx="15.6" cy="16.4" r="2.4"/></svg></span>
      <span class="brand-text">Poli<strong>Music</strong></span>
    </a>
    <div class="topbar-user">
      <img class="avatar" src="../../UserImages/polimusicuseasalma.jpg" alt="User photo" />
      <div class="topbar-user-data">
        <span class="topbar-user-name">Salma.Morales</span>
        <span class="topbar-user-meta">
          <span class="role-tag">USER</span>
          <span class="topbar-user-mail">salma@epn.edu.ec</span>
        </span>
      </div>
      <a class="btn-logout" href="#">
        <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><path d="M16 17l5-5-5-5"/><path d="M21 12H9"/></svg>
        <span>Logout</span>
      </a>
    </div>
  </div>
</header>
<div class="app">

  <main class="content" data-play-url="#">
    <section class="hero">
      <div class="hero-text">
        <p class="kicker">Your library</p>
        <h1 class="hero-title">Welcome, <span class="hero-name">Salma.Morales</span>
          <span class="hero-badge"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M9 17.5V6.2l9-1.8v9.1"/><circle cx="6.6" cy="18" r="2.4"/><circle cx="15.6" cy="16.4" r="2.4"/></svg></span>
        </h1>
        <p class="hero-sub">Session started. This is the <strong>Song list</strong> stored in the <code>TBL_SONG</code> table of <code>BDD_PoliMusic</code>. Press play to listen to a track.</p>
      </div>
      <div class="hero-stats">
        <div class="stat"><span class="stat-value">5</span><span class="stat-label">songs</span></div>
        <div class="stat stat-accent"><span class="stat-value">1,290</span><span class="stat-label">plays</span></div>
      </div>
    </section>

    <section class="panel">
      <div class="panel-head">
        <div>
          <h2 class="panel-title">Song list</h2>
          <p class="panel-sub">Data source: <code>TBL_SONG</code> &middot; columns <code>ID_SONG</code>, <code>SONG_NAME</code>, <code>SONG_PATH</code>, <code>PLAYS</code>.</p>
        </div>
        <span class="panel-chip">5 tracks</span>
      </div>
      <div class="table-wrap">
        <table class="song-table">
          <thead><tr>
            <th class="col-id">ID Canción</th><th class="col-name">Nombre</th><th class="col-path">Ruta</th>
            <th class="col-plays">Reproducciones</th><th class="col-player">Reproducir</th>
          </tr></thead>
          <tbody>{rows}</tbody>
        </table>
      </div>
    </section>
  </main>

  <footer class="foot">
    <span>PoliMusic &middot; Web Applications &middot; ASP.NET Web Forms</span>
    <span>Entity / DAL / BLL &middot; TBL_SONG</span>
  </footer>
</div>
</form>
</body>
</html>
"""

target = os.path.join(os.path.dirname(os.path.abspath(__file__)), "preview-song.html")
with open(target, "w", encoding="utf-8") as handle:
    handle.write(PAGE.replace("{rows}", "\n".join(rows)))
print(target)
