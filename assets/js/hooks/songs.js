let SongsHooks = {};

SongsHooks.Songs = {
  mounted() {
    let SongsHook = this;

    SongsHook.handleEvent("play_next_song", () => {
      let songNumbers = document.querySelectorAll(".song-number");

      songNumbers.forEach((songNumber, index) => {
        songNumber.textContent = index + 1;
      });

      const songPlayButtons = document.querySelectorAll(
        "section.song-play-icon > svg",
      );

      let nextSongBtn = songPlayButtons[0];

      // cook up a synthetic event
      nextSongBtn.dispatchEvent(new MouseEvent("click", { bubbles: true }));
    });
  },
};

export default SongsHooks;
