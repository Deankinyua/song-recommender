let SongPlayIconHooks = {};

SongPlayIconHooks.SongPlayIcon = {
  mounted() {
    let songPlayIconHook = this;
    const songPlayBtn = songPlayIconHook.el;

    songPlayBtn.addEventListener("click", () => {
      let id = songPlayBtn.id;

      let {
        artist_id,
        artist_monthly_listeners,
        artist_name,
        current_song_id,
        duration_ms,
        genre_name,
        name,
      } = songPlayBtn.dataset;

      const previousSongPlayBtn = document.getElementById(current_song_id);
      const previous_song_duration_played = previousSongPlayBtn
        ? Number(previousSongPlayBtn.dataset.duration_played)
        : null;

      const params = {
        artist_id,
        artist_monthly_listeners: Number(artist_monthly_listeners),
        artist_name,
        duration_ms: Number(duration_ms),
        previous_song_duration_played: previous_song_duration_played,
        genre_name,
        id,
        name,
      };

      if (id === current_song_id) {
        let songPlayerIcon = document.getElementById("pause-play");

        songPlayerIcon.dispatchEvent(
          new MouseEvent("click", { bubbles: false }),
        );
      } else {
        songPlayIconHook.pushEvent("play_new_song", params);
      }
    });
  },
};

export default SongPlayIconHooks;
