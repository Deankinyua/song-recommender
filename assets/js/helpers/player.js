function formatTime(sec) {
  const minutes = Math.floor(sec / 60);
  const seconds = Math.floor(sec % 60)
    .toString()
    .padStart(2, "0");

  return `${minutes}:${seconds}`;
}

function return_song_icon_polygons(song_id) {
  let songIconPolygon1 = document.getElementById(`polygon-1-${song_id}`);

  let songIconPolygon2 = document.getElementById(`polygon-2-${song_id}`);

  return { songIconPolygon1, songIconPolygon2 };
}

export { formatTime, return_song_icon_polygons };
