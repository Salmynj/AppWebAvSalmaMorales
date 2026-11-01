<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Song.aspx.cs" Inherits="WebAppPoliMusicV2.Song" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml" lang="en">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>PoliMusic | Song list</title>
    <link rel="stylesheet" href="Content/PoliMusic.css" />
</head>
<body>
    <form id="form1" runat="server">

        <!-- ==================== Top bar ==================== -->
        <header class="topbar">
            <div class="topbar-inner">
                <a class="brand" href="Song.aspx">
                    <span class="brand-mark">
                        <svg viewBox="0 0 24 24" aria-hidden="true">
                            <path d="M9 17.5V6.2l9-1.8v9.1" />
                            <circle cx="6.6" cy="18" r="2.4" />
                            <circle cx="15.6" cy="16.4" r="2.4" />
                        </svg>
                    </span>
                    <span class="brand-text">Poli<strong>Music</strong></span>
                </a>

                <div class="topbar-user">
                    <asp:Image ID="imgUserPhoto" runat="server" CssClass="avatar" AlternateText="User photo" />
                    <div class="topbar-user-data">
                        <asp:Label ID="lblUserName" runat="server" CssClass="topbar-user-name"></asp:Label>
                        <span class="topbar-user-meta">
                            <asp:Label ID="lblUserRole" runat="server" CssClass="role-tag"></asp:Label>
                            <asp:Label ID="lblUserEmail" runat="server" CssClass="topbar-user-mail"></asp:Label>
                        </span>
                    </div>
                    <a class="btn-logout" href="Logout.aspx">
                        <svg viewBox="0 0 24 24" aria-hidden="true">
                            <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4" />
                            <path d="M16 17l5-5-5-5" />
                            <path d="M21 12H9" />
                        </svg>
                        <span>Logout</span>
                    </a>
                </div>
            </div>
        </header>

        <div class="app">

            <main class="content" data-play-url="Handlers/PlayCounter.ashx">

                <!-- ==================== Hero ==================== -->
                <section class="hero">
                    <div class="hero-text">
                        <p class="kicker">Your library</p>
                        <h1 class="hero-title">
                            Welcome,
                            <asp:Label ID="lblWelcomeName" runat="server" CssClass="hero-name"></asp:Label>
                            <span class="hero-badge">
                                <svg viewBox="0 0 24 24" aria-hidden="true">
                                    <path d="M9 17.5V6.2l9-1.8v9.1" />
                                    <circle cx="6.6" cy="18" r="2.4" />
                                    <circle cx="15.6" cy="16.4" r="2.4" />
                                </svg>
                            </span>
                        </h1>
                        <p class="hero-sub">
                            Session started. This is the <strong>Song list</strong> stored in the
                            <code>TBL_SONG</code> table of <code>BDD_PoliMusic</code>.
                            Press play to listen to a track.
                        </p>
                    </div>

                    <div class="hero-stats">
                        <div class="stat">
                            <span class="stat-value"><asp:Label ID="lblTotalSongs" runat="server">0</asp:Label></span>
                            <span class="stat-label">songs</span>
                        </div>
                        <div class="stat stat-accent">
                            <span class="stat-value"><asp:Label ID="lblTotalPlays" runat="server">0</asp:Label></span>
                            <span class="stat-label">plays</span>
                        </div>
                    </div>
                </section>

                <!-- ==================== Song list ==================== -->
                <section class="panel">
                    <div class="panel-head">
                        <div>
                            <h2 class="panel-title">Song list</h2>
                            <p class="panel-sub">
                                Data source: <code>TBL_SONG</code> &middot; columns
                                <code>ID_SONG</code>, <code>SONG_NAME</code>, <code>SONG_PATH</code>, <code>PLAYS</code>.
                            </p>
                        </div>
                        <span class="panel-chip">
                            <asp:Label ID="lblChipCount" runat="server">0</asp:Label> tracks
                        </span>
                    </div>

                    <asp:Label ID="lblMessage" runat="server" CssClass="alert" Visible="false"></asp:Label>

                    <div class="table-wrap">
                        <table class="song-table">
                            <thead>
                                <tr>
                                    <th class="col-id">ID Canción</th>
                                    <th class="col-name">Nombre</th>
                                    <th class="col-path">Ruta</th>
                                    <th class="col-plays">Reproducciones</th>
                                    <th class="col-player">Reproducir</th>
                                </tr>
                            </thead>
                            <tbody>
                                <asp:Repeater ID="rptSongs" runat="server">
                                    <ItemTemplate>
                                        <tr class="song-row">
                                            <td class="col-id">
                                                <span class="song-id"><%# Eval("ID") %></span>
                                            </td>
                                            <td class="col-name">
                                                <div class="song-name-cell">
                                                    <span class="song-cover"><%# GetInitial(Eval("SongName")) %></span>
                                                    <span class="song-name"><%# Server.HtmlEncode(Convert.ToString(Eval("SongName"))) %></span>
                                                    <span class="song-eq" aria-hidden="true"><i></i><i></i><i></i></span>
                                                </div>
                                            </td>
                                            <td class="col-path">
                                                <span class="song-path"><%# Server.HtmlEncode(Convert.ToString(Eval("SongPath"))) %></span>
                                            </td>
                                            <td class="col-plays">
                                                <span class="plays-pill"><%# FormatPlays(Eval("Plays")) %></span>
                                            </td>
                                            <td class="col-player">
                                                <div class="player">
                                                    <span class="player-ref" hidden><%# Eval("ID") %></span>
                                                    <span class="player-src" hidden><%# Server.HtmlEncode(GetSongUrl(Eval("SongPath"))) %></span>
                                                    <audio preload="metadata"></audio>

                                                    <button type="button" class="player-btn player-toggle" aria-label="Play" title="Play / Pause">
                                                        <svg class="icon-play" viewBox="0 0 24 24" aria-hidden="true">
                                                            <path d="M8 5.1v13.8L19 12z" />
                                                        </svg>
                                                        <svg class="icon-pause" viewBox="0 0 24 24" aria-hidden="true">
                                                            <path d="M6.5 5h3.8v14H6.5zM13.7 5h3.8v14h-3.8z" />
                                                        </svg>
                                                    </button>

                                                    <span class="player-time">
                                                        <span class="player-current">0:00</span>
                                                        <span class="player-sep">/</span>
                                                        <span class="player-duration">0:00</span>
                                                    </span>

                                                    <div class="player-track" title="Seek">
                                                        <span class="player-fill"></span>
                                                    </div>

                                                    <button type="button" class="player-btn player-mute" aria-label="Mute" title="Mute">
                                                        <svg class="icon-volume" viewBox="0 0 24 24" aria-hidden="true">
                                                            <path d="M4 9.5h3.2L12 5.6v12.8L7.2 14.5H4z" />
                                                            <path d="M15.4 9.2a4 4 0 0 1 0 5.6" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" />
                                                            <path d="M17.9 6.7a7.5 7.5 0 0 1 0 10.6" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" />
                                                        </svg>
                                                        <svg class="icon-muted" viewBox="0 0 24 24" aria-hidden="true">
                                                            <path d="M4 9.5h3.2L12 5.6v12.8L7.2 14.5H4z" />
                                                            <path d="M16 9.5l4.5 5M20.5 9.5L16 14.5" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" />
                                                        </svg>
                                                    </button>

                                                    <input type="range" class="player-volume" min="0" max="1" step="0.05" value="0.8" aria-label="Volume" />
                                                </div>
                                            </td>
                                        </tr>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </tbody>
                        </table>
                    </div>

                    <asp:Panel ID="pnlEmpty" runat="server" CssClass="empty" Visible="false">
                        <span class="empty-icon">
                            <svg viewBox="0 0 24 24" aria-hidden="true">
                                <path d="M9 17.5V6.2l9-1.8v9.1" />
                                <circle cx="6.6" cy="18" r="2.4" />
                                <circle cx="15.6" cy="16.4" r="2.4" />
                            </svg>
                        </span>
                        <p class="empty-title">There are no songs yet</p>
                        <p class="empty-text">The table <code>TBL_SONG</code> does not have records for this library.</p>
                    </asp:Panel>
                </section>

            </main>

            <footer class="foot">
                <span>PoliMusic &middot; Web Applications &middot; ASP.NET Web Forms</span>
                <span>Entity / DAL / BLL &middot; TBL_SONG</span>
            </footer>
        </div>
    </form>

    <script src="Content/PoliMusic.js"></script>
</body>
</html>
