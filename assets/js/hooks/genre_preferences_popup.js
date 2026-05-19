let GenrePreferencesPopupHooks = {};

GenrePreferencesPopupHooks.GenrePreferencesPopup = {
  mounted() {
    const genrePreferencesPopup = this.el;

    genrePreferencesPopup.addEventListener(
      "hide_genre_preferences_popup",
      () => {
        localStorage.setItem("show-genre-preferences-popup", false);
      },
    );
  },
};

export default GenrePreferencesPopupHooks;
