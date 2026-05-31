import { animatePausePlayButton } from "../helpers/play_pause_animation.js";
import { formatTime, return_song_icon_polygons } from "../helpers/player.js";
import { animateControlButton } from "../helpers/controls_animation.js";

let SongPlayerHooks = {};

SongPlayerHooks.SongPlayer = {
  mounted() {
    let playerHook = this;
    const playBtn = playerHook.el;
    let playBtnId = playBtn.id;
    const playerPolygon1 = document.getElementById(`polygon-1-${playBtnId}`);
    const playerPolygon2 = document.getElementById(`polygon-2-${playBtnId}`);

    const backIcon = document.getElementById("back-icon");
    const backTargetPolygon = document.getElementById("back-polygon-2");
    const nextIcon = document.getElementById("next-icon");
    const nextTargetPolygon = document.getElementById("next-polygon-2");

    const playedTimeEl = document.getElementById("song-played-time");
    const songProgressEl = document.getElementById("song-progress");
    const songDurationEl = document.getElementById("song-duration");
    const playPauseTooltipEl = document.getElementById("pause-play-tooltip");

    let isPaused = true;
    let player = null;
    let lastPlayedTime = null;

    function showCurrentlyPlayingSong(current_song_id) {
      const currentSongName = document.getElementById(
        `song-name-${current_song_id}`,
      );

      currentSongName?.classList.add("playing-song-name");
    }

    function toogleTooltip() {
      playPauseTooltipEl.textContent = player.isPlaying ? "Pause" : "Play";
    }

    function renderSongData() {
      if (player) {
        songProgressEl.value = player.currentTime;
        playedTimeEl.textContent = formatTime(player.currentTime);
      }
    }

    function updateSongPlayedTime(timestamp) {
      if (!lastPlayedTime) lastPlayedTime = timestamp;

      const delta = (timestamp - lastPlayedTime) / 1000;
      lastPlayedTime = timestamp;

      if (player?.isPlaying) {
        player.currentTime += delta;
        playerHook.currentSongPlayIcon.dataset.duration_played = Math.min(
          player.currentTime,
          player.songDuration,
        );

        if (player.currentTime >= player.songDuration) {
          player.currentTime = player.songDuration;
          // At this point we can send an event to the server to play the next song
          player.isPlaying = false;
          playerHook.pushEvent("play_next_song", {
            duration_played: player.songDuration,
          });
        }
      }

      renderSongData();

      requestAnimationFrame(updateSongPlayedTime);
    }

    async function animatePlayerAndSongIcons() {
      const [, newPausedState] = await Promise.all([
        animatePausePlayButton(
          isPaused,
          playerHook.currentSongIconPolygon1,
          playerHook.currentSongIconPolygon2,
        ),
        animatePausePlayButton(isPaused, playerPolygon1, playerPolygon2),
      ]);

      isPaused = newPausedState;

      player.isPlaying = !player.isPlaying;
      toogleTooltip();
    }

    playerHook.handleEvent(
      "maybe_play_song",
      async ({
        current_song_duration,
        current_song_id,
        current_time,
        should_play,
      }) => {
        const { songIconPolygon1, songIconPolygon2 } =
          return_song_icon_polygons(current_song_id);
        playerHook.currentSongIconPolygon1 = songIconPolygon1;
        playerHook.currentSongIconPolygon2 = songIconPolygon2;

        playerHook.currentSongPlayIcon =
          document.getElementById(current_song_id);

        showCurrentlyPlayingSong(current_song_id);

        player = {
          songDuration: current_song_duration,
          currentTime: current_time,
          isPlaying: should_play,
        };

        if (should_play) {
          if (isPaused) {
            await Promise.all([
              animatePausePlayButton(
                isPaused,
                songIconPolygon1,
                songIconPolygon2,
              ),
              animatePausePlayButton(isPaused, playerPolygon1, playerPolygon2),
            ]);
          } else {
            await animatePausePlayButton(
              true,
              songIconPolygon1,
              songIconPolygon2,
            );
          }

          isPaused = false;
        }

        toogleTooltip();

        songProgressEl.max = player.songDuration;
        songDurationEl.textContent = formatTime(player.songDuration);
      },
    );

    playerHook.handleEvent(
      "pause_previous_song",
      async ({ previous_song_id }) => {
        const { songIconPolygon1, songIconPolygon2 } =
          return_song_icon_polygons(previous_song_id);

        if (songIconPolygon1) {
          !isPaused
            ? await animatePausePlayButton(
                isPaused,
                songIconPolygon1,
                songIconPolygon2,
              )
            : null;
        }
      },
    );

    playerHook.handleEvent("maybe_pause_song", async () => {
      if (player?.isPlaying) await animatePlayerAndSongIcons();
    });

    songProgressEl.addEventListener("input", (e) => {
      player.currentTime = Number(e.target.value);
    });

    playBtn.addEventListener("click", async () => animatePlayerAndSongIcons());

    backIcon.addEventListener("click", () => {
      player.currentTime = 0;
      animateControlButton("back", true, backTargetPolygon);
    });

    nextIcon.addEventListener("click", () => {
      playerHook.pushEvent("play_next_song", {
        duration_played: player.songDuration,
      });
      animateControlButton("next", true, nextTargetPolygon);
    });

    requestAnimationFrame(updateSongPlayedTime);
  },
};

export default SongPlayerHooks;
