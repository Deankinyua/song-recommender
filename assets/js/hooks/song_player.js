import {
  getProgress,
  easeInOut,
  buildShapeTransition,
  returnPolygonPoints,
} from "js/helpers/animation_helpers.js";

let SongPlayerHooks = {};

SongPlayerHooks.SongPlayer = {
  mounted() {
    const playBtn = document.getElementById("pause-play");
    const polygon_1 = document.getElementById("polygon-1");
    const polygon_2 = document.getElementById("polygon-2");

    const playedTimeEl = document.getElementById("song-played-time");
    const songProgress = document.getElementById("song-progress");
    const songDurationEl = document.getElementById("song-duration");
    const playPauseTooltipEl = document.getElementById("pause-play-tooltip");

    const time = {
      start: null,
      total: 500,
    };

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

    playBtn.addEventListener("click", () => {
      requestAnimationFrame(playOrStop);
      player.isPlaying = !player.isPlaying;
      playPauseTooltipEl.textContent = player.isPlaying ? "Pause" : "Play";
    });

    const playOrStop = (now) => {
      if (!time.start) time.start = now;
      time.elapsed = now - time.start;

      const progress = getProgress(time);
      const easing = easeInOut(progress);

      let {
        start_shape_polygon_1,
        end_shape_polygon_1,
        start_shape_polygon_2,
        end_shape_polygon_2,
      } = buildShapeTransition(isStopped);

      const polygon_1_points = returnPolygonPoints(
        start_shape_polygon_1,
        end_shape_polygon_1,
        easing,
      );

      const polygon_2_points = returnPolygonPoints(
        start_shape_polygon_2,
        end_shape_polygon_2,
        easing,
      );

      polygon_1.setAttribute("points", polygon_1_points.join(" "));
      polygon_2.setAttribute("points", polygon_2_points.join(" "));

      if (progress < 1) requestAnimationFrame(playOrStop);
      if (progress >= 1) {
        isStopped = !isStopped;
        time.start = null;
      }
    };
  },
};

export default SongPlayerHooks;
