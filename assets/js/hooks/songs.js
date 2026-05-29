let SongsHooks = {};

SongsHooks.Songs = {
  mounted() {
    let SongsHook = this;

    const setSongNumbers = () => {
      let songNumbers = document.querySelectorAll(".song-number");

      songNumbers.forEach((songNumber, index) => {
        songNumber.textContent = index + 1;
      });
    };

    SongsHook.handleEvent("play_next_song", () => {
      setSongNumbers();

      const songPlayButtons = document.querySelectorAll(
        "section.song-play-icon > svg",
      );

      let nextSongBtn = songPlayButtons[0];

      // cook up a synthetic event
      nextSongBtn.dispatchEvent(new MouseEvent("click", { bubbles: true }));
    });

    SongsHook.handleEvent("set_song_numbers", () => setSongNumbers());
  },
};

export default SongsHooks;
