/* ==========================================================================
   PoliMusic - Song.aspx player behaviour
   - play / pause per row (only one song at a time)
   - progress bar, seek, time, volume, mute
   - registers one reproduction in TBL_SONG through PlayCounter.ashx
   ========================================================================== */
(function () {
    "use strict";

    var players = Array.prototype.slice.call(document.querySelectorAll(".player"));
    if (!players.length) {
        return;
    }

    var content = document.querySelector(".content");
    var playUrl = content ? content.getAttribute("data-play-url") : null;
    var current = null;

    function formatTime(seconds) {
        if (!isFinite(seconds) || seconds < 0) {
            return "0:00";
        }
        var total = Math.floor(seconds);
        var minutes = Math.floor(total / 60);
        var rest = total % 60;
        return minutes + ":" + (rest < 10 ? "0" + rest : rest);
    }

    function textOf(node) {
        return node && node.textContent ? node.textContent.replace(/\s+/g, " ").trim() : "";
    }

    function getRow(root) {
        var node = root.parentNode;
        while (node && node.tagName !== "TR") {
            node = node.parentNode;
        }
        return node;
    }

    function setPlaying(root, playing) {
        root.classList.toggle("is-playing", playing);
        var row = getRow(root);
        if (row) {
            row.classList.toggle("is-playing", playing);
        }
        var toggle = root.querySelector(".player-toggle");
        if (toggle) {
            toggle.setAttribute("aria-label", playing ? "Pause" : "Play");
        }
    }

    function registerPlay(root, idSong) {
        if (!playUrl || !idSong || !window.fetch) {
            return;
        }
        if (root.getAttribute("data-counted") === "1") {
            return;
        }
        root.setAttribute("data-counted", "1");

        fetch(playUrl + "?id=" + encodeURIComponent(idSong), { credentials: "same-origin" })
            .then(function (response) {
                return response.ok ? response.json() : null;
            })
            .then(function (data) {
                if (!data || typeof data.plays !== "number" || data.plays < 0) {
                    return;
                }
                var row = getRow(root);
                var cell = row ? row.querySelector(".plays-pill") : null;
                if (cell) {
                    cell.textContent = data.plays.toLocaleString();
                }
            })
            .catch(function () {
                /* the counter is a nice to have: never break the playback */
            });
    }

    players.forEach(function (root) {
        var audio = root.querySelector("audio");
        var toggle = root.querySelector(".player-toggle");
        var track = root.querySelector(".player-track");
        var fill = root.querySelector(".player-fill");
        var currentTime = root.querySelector(".player-current");
        var duration = root.querySelector(".player-duration");
        var mute = root.querySelector(".player-mute");
        var volume = root.querySelector(".player-volume");
        var idSong = textOf(root.querySelector(".player-ref"));
        var source = textOf(root.querySelector(".player-src"));

        if (!audio || !toggle) {
            return;
        }

        if (source) {
            audio.setAttribute("src", source);
        }

        toggle.addEventListener("click", function () {
            if (audio.paused) {
                if (current && current !== root) {
                    var other = current.querySelector("audio");
                    if (other) {
                        other.pause();
                    }
                }
                current = root;
                root.setAttribute("data-played", "1");
                var promise = audio.play();
                if (promise && typeof promise.catch === "function") {
                    promise.catch(function () { /* autoplay blocked or file missing */ });
                }
                registerPlay(root, idSong);
            } else {
                audio.pause();
            }
        });

        audio.addEventListener("play", function () {
            setPlaying(root, true);
        });

        audio.addEventListener("pause", function () {
            setPlaying(root, false);
        });

        audio.addEventListener("ended", function () {
            setPlaying(root, false);
            if (fill) {
                fill.style.width = "0%";
            }
            if (currentTime) {
                currentTime.textContent = "0:00";
            }
        });

        audio.addEventListener("loadedmetadata", function () {
            if (duration) {
                duration.textContent = formatTime(audio.duration);
            }
        });

        audio.addEventListener("durationchange", function () {
            if (duration) {
                duration.textContent = formatTime(audio.duration);
            }
        });

        audio.addEventListener("timeupdate", function () {
            if (currentTime) {
                currentTime.textContent = formatTime(audio.currentTime);
            }
            if (fill) {
                var percentage = audio.duration ? (audio.currentTime / audio.duration) * 100 : 0;
                fill.style.width = percentage + "%";
            }
        });

        audio.addEventListener("error", function () {
            setPlaying(root, false);
            if (root.getAttribute("data-played") !== "1") {
                /* metadata probe failed: the row just keeps its default time */
                return;
            }
            root.classList.add("is-missing");
            if (duration) {
                duration.textContent = "--:--";
            }
            toggle.setAttribute("title", "The audio file was not found on the server");
        });

        if (track) {
            track.addEventListener("click", function (event) {
                if (!audio.duration) {
                    return;
                }
                var rect = track.getBoundingClientRect();
                if (!rect.width) {
                    return;
                }
                var ratio = (event.clientX - rect.left) / rect.width;
                ratio = Math.min(Math.max(ratio, 0), 1);
                audio.currentTime = ratio * audio.duration;
            });
        }

        if (mute) {
            mute.addEventListener("click", function () {
                audio.muted = !audio.muted;
                root.classList.toggle("is-muted", audio.muted);
            });
        }

        if (volume) {
            audio.volume = parseFloat(volume.value);
            volume.addEventListener("input", function () {
                var value = parseFloat(volume.value);
                audio.volume = value;
                audio.muted = value === 0;
                root.classList.toggle("is-muted", audio.muted);
            });
        }
    });
})();
