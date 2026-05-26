import { animatePausePlayButton } from "../helpers/play_pause_animation.js";
import { formatTime, return_song_icon_polygons } from "../helpers/player.js";

let SongPlayerHooks = {};

SongPlayerHooks.SongPlayer = {
  mounted() {
    const playBtn = this.el;
    let playBtnId = playBtn.id;
    const playerPolygon1 = document.getElementById(`polygon-1-${playBtnId}`);
    const playerPolygon2 = document.getElementById(`polygon-2-${playBtnId}`);

    const playedTimeEl = document.getElementById("song-played-time");
    const songProgressEl = document.getElementById("song-progress");
    const songDurationEl = document.getElementById("song-duration");
    const playPauseTooltipEl = document.getElementById("pause-play-tooltip");

    let isPaused = true;
    let player = null;
    let lastPlayedTime = null;

    this.handleEvent(
      "maybe_play_song",
      async ({
        current_song_duration,
        current_song_id,
        current_time,
        should_play,
      }) => {
        const { songIconPolygon1, songIconPolygon2 } =
          return_song_icon_polygons(current_song_id);
        this.currentSongIconPolygon1 = songIconPolygon1;
        this.currentSongIconPolygon2 = songIconPolygon2;

        player = {
          songDuration: current_song_duration,
          currentTime: current_time,
          isPlaying: should_play,
          playbackRate: 1,
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

    this.handleEvent("pause_previous_song", async ({ previous_song_id }) => {
      const { songIconPolygon1, songIconPolygon2 } =
        return_song_icon_polygons(previous_song_id);

      if (!isPaused) {
        await animatePausePlayButton(
          isPaused,
          songIconPolygon1,
          songIconPolygon2,
        );
      }
    });

    this.handleEvent("play_or_pause_song", async () => {
      const [, newPausedState] = await Promise.all([
        animatePausePlayButton(
          isPaused,
          this.currentSongIconPolygon1,
          this.currentSongIconPolygon2,
        ),
        animatePausePlayButton(isPaused, playerPolygon1, playerPolygon2),
      ]);

      isPaused = newPausedState;

      player.isPlaying = !player.isPlaying;
      toogleTooltip();
    });

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
        player.currentTime += delta * player.playbackRate;

        if (player.currentTime >= player.songDuration) {
          player.currentTime = player.songDuration;
          // At this point we can send an event to the server
          console.log("next song please");
          player.isPlaying = false;
        }
      }

      renderSongData();

      requestAnimationFrame(updateSongPlayedTime);
    }

    songProgressEl.addEventListener("input", (e) => {
      player.currentTime = Number(e.target.value);
    });

    playBtn.addEventListener("click", async () => {
      const [, newPausedState] = await Promise.all([
        animatePausePlayButton(
          isPaused,
          this.currentSongIconPolygon1,
          this.currentSongIconPolygon2,
        ),
        animatePausePlayButton(isPaused, playerPolygon1, playerPolygon2),
      ]);

      isPaused = newPausedState;

      player.isPlaying = !player.isPlaying;
      toogleTooltip();
    });

    requestAnimationFrame(updateSongPlayedTime);
  },
};

export default SongPlayerHooks;
