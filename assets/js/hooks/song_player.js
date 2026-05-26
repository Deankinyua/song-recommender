import { animatePausePlayButton } from "../helpers/play_pause_animation.js";

let SongPlayerHooks = {};

SongPlayerHooks.SongPlayer = {
  mounted() {
    const playBtn = this.el;
    let playBtnId = this.el.id;
    const polygon_1 = document.getElementById(`polygon-1-${playBtnId}`);
    const polygon_2 = document.getElementById(`polygon-2-${playBtnId}`);

    const playedTimeEl = document.getElementById("song-played-time");
    const songProgress = document.getElementById("song-progress");
    const songDurationEl = document.getElementById("song-duration");
    const playPauseTooltipEl = document.getElementById("pause-play-tooltip");

    let isStopped = true;

    const player = {
      songDuration: 240,
      currentTime: 0,
      isPlaying: false,
      playbackRate: 1,
    };

    songProgress.max = player.songDuration;

    function formatTime(sec) {
      const minutes = Math.floor(sec / 60);
      const seconds = Math.floor(sec % 60)
        .toString()
        .padStart(2, "0");

      return `${minutes}:${seconds}`;
    }

    songDurationEl.textContent = formatTime(player.songDuration);

    function renderSongData() {
      songProgress.value = player.currentTime;
      playedTimeEl.textContent = formatTime(player.currentTime);
    }

    let lastPlayedTime = null;

    function updateSongPlayedTime(timestamp) {
      if (!lastPlayedTime) lastPlayedTime = timestamp;

      const delta = (timestamp - lastPlayedTime) / 1000;
      lastPlayedTime = timestamp;

      if (player.isPlaying) {
        player.currentTime += delta * player.playbackRate;

        if (player.currentTime >= player.songDuration) {
          player.currentTime = player.songDuration;
          player.isPlaying = false;
        }
      }

      renderSongData();
      requestAnimationFrame(updateSongPlayedTime);
    }

    requestAnimationFrame(updateSongPlayedTime);

    songProgress.addEventListener("input", (e) => {
      player.currentTime = Number(e.target.value);
    });

    playBtn.addEventListener("click", async () => {
      isStopped = await animatePausePlayButton(isStopped, polygon_1, polygon_2);
      player.isPlaying = !player.isPlaying;
      playPauseTooltipEl.textContent = player.isPlaying ? "Pause" : "Play";
    });
  },
};

export default SongPlayerHooks;
