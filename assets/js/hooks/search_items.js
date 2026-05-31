let SearchItemsHooks = {};

SearchItemsHooks.SearchItems = {
  mounted() {
    let searchItemsHook = this;

    const returnSongPlayButtons = () => {
      const songPlayButtons = document.querySelectorAll(
        "section.searched-song-play-icon > svg",
      );

      return songPlayButtons;
    };

    const setCurrentSongId = (current_song_id) => {
      let songPlayButtons = returnSongPlayButtons();
      songPlayButtons.forEach((playBtn) => {
        playBtn.dataset.current_song_id = current_song_id;
      });
    };

    searchItemsHook.handleEvent("set_current_song_id", ({ current_song_id }) =>
      setCurrentSongId(current_song_id),
    );

    searchItemsHook.handleEvent(
      "set_current_song_id_for_search",
      ({ current_song_id }) => setCurrentSongId(current_song_id),
    );
  },
};

export default SearchItemsHooks;
