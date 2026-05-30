let SongsHooks = {};

SongsHooks.Songs = {
  mounted() {
    let songHook = this;

    const setSongNumbers = () => {
      let songNumbers = document.querySelectorAll(".song-number");

      songNumbers.forEach((songNumber, index) => {
        songNumber.textContent = index + 1;
      });
    };

    const returnSongPlayButtons = () => {
      const songPlayButtons = document.querySelectorAll(
        "section.song-play-icon > svg",
      );

      return songPlayButtons;
    };

    const setCurrentSongId = (current_song_id) => {
      setSongNumbers();
      let songPlayButtons = returnSongPlayButtons();
      songPlayButtons.forEach((playBtn) => {
        playBtn.dataset.current_song_id = current_song_id;
      });
    };

    songHook.handleEvent("play_next_song", () => {
      setSongNumbers();

      const songPlayButtons = returnSongPlayButtons();

      let nextSongBtn = songPlayButtons[0];

      // cook up a synthetic event
      nextSongBtn.dispatchEvent(new MouseEvent("click", { bubbles: false }));
    });

    songHook.handleEvent("set_current_song_id", ({ current_song_id }) =>
      setCurrentSongId(current_song_id),
    );
  },
};

export default SongsHooks;
