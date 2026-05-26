function formatTime(sec) {
  const minutes = Math.floor(sec / 60);
  const seconds = Math.floor(sec % 60)
    .toString()
    .padStart(2, "0");

  return `${minutes}:${seconds}`;
}

export { formatTime };
