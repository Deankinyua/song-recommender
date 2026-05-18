let GenrePreferencesPopupHooks = {};

GenrePreferencesPopupHooks.GenrePreferencesPopup = {
  mounted() {
    const genrePreferencesPopup = this.el;

    genrePreferencesPopup.addEventListener(
      "hide-genre-preferences-popup",
      () => {
        localStorage.setItem("show-genre-preferences-popup", false);
      },
    );
  },
};

export default GenrePreferencesPopupHooks;
