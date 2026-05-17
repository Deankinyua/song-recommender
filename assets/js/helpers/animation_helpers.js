const shapes = {
  pause: {
    polygon_1: [11, 10, 15, 10, 15, 26, 11, 26],
    polygon_2: [21, 10, 25, 10, 25, 26, 21, 26],
  },
  play: {
    polygon_1: [11, 10, 11, 18, 11, 18, 11, 26],
    polygon_2: [11, 10, 28, 18, 28, 18, 11, 26],
  },
};

const getProgress = ({ elapsed, total }) => Math.min(elapsed / total, 1);

const easeInOut = (progress) =>
  (progress *= 2) < 1
    ? 0.5 * Math.pow(progress, 5)
    : 0.5 * ((progress -= 2) * Math.pow(progress, 4) + 2);

const buildShapeTransition = (isStopped) => {
  // when stopped is true, we move from play to pause
  const from = isStopped ? "play" : "pause";
  const to = isStopped ? "pause" : "play";

  return Object.keys(shapes[from]).reduce((acc, key) => {
    acc[`start_shape_${key}`] = shapes[from][key];
    acc[`end_shape_${key}`] = shapes[to][key];
    return acc;
  }, {});
};

const returnPolygonPoints = (startShape, endShape, easingFunc) => {
  return startShape.map((start, index) => {
    const end = endShape[index];
    const distance = end - start;
    const point = start + easingFunc * distance;
    return point;
  });
};

export { getProgress, easeInOut, buildShapeTransition, returnPolygonPoints };
