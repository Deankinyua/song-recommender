import { animatePausePlayButton } from "../helpers/play_pause_animation.js";
import { formatTime } from "../helpers/player.js";

let SongPlayerHooks = {};

SongPlayerHooks.SongPlayer = {
  mounted() {
    const playBtn = this.el;
    let playBtnId = this.el.id;
    const polygon_1 = document.getElementById(`polygon-1-${playBtnId}`);
    const polygon_2 = document.getElementById(`polygon-2-${playBtnId}`);

    const playedTimeEl = document.getElementById("song-played-time");
    const songProgressEl = document.getElementById("song-progress");
    const songDurationEl = document.getElementById("song-duration");
    const playPauseTooltipEl = document.getElementById("pause-play-tooltip");

    let isStopped = true;
    let player = null;
    let lastPlayedTime = null;

    this.handleEvent(
      "maybe_play_song",
      async ({ current_song_duration, current_time, should_play }) => {
        player = {
          songDuration: current_song_duration,
          currentTime: current_time,
          isPlaying: should_play,
          playbackRate: 1,
        };

        if (should_play && isStopped) {
          isStopped = await animatePausePlayButton(
            isStopped,
            polygon_1,
            polygon_2,
          );
        }

        toogleTooltip();

        songProgressEl.max = player.songDuration;
        songDurationEl.textContent = formatTime(player.songDuration);
      },
    );

    this.handleEvent("play_or_pause_song", async () => {
      isStopped = await animatePausePlayButton(isStopped, polygon_1, polygon_2);
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
      isStopped = await animatePausePlayButton(isStopped, polygon_1, polygon_2);
      player.isPlaying = !player.isPlaying;
      toogleTooltip();
    });

    requestAnimationFrame(updateSongPlayedTime);
  },
};

export default SongPlayerHooks;
