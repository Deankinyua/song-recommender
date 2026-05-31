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

const shapesBackIcon = {
  start: [28, 10, 11, 18, 11, 18, 28, 26],
  end: [22, 10, 8, 15, 8, 21, 22, 26],
};

const shapesNextIcon = {
  start: [8, 10, 25, 18, 25, 18, 8, 26],
  end: [14, 10, 28, 15, 28, 21, 14, 26],
};

const getProgress = ({ elapsed, total }) => Math.min(elapsed / total, 1);
const getCX = (element) => Number(element.getAttribute("cx"));
const getCY = (element) => Number(element.getAttribute("cy"));

const easeInOut = (progress) =>
  (progress *= 2) < 1
    ? 0.5 * Math.pow(progress, 5)
    : 0.5 * ((progress -= 2) * Math.pow(progress, 4) + 2);

const easeOut = (progress) => Math.pow(--progress, 5) + 1;

const getNewCyPoint = (goingUp, circle, circlePositions, easingFunc) => {
  let { finalCy, startCy } = circlePositions;
  let currentCy = getCY(circle);

  const distanceCy = goingUp ? currentCy - finalCy : finalCy - currentCy;
  const easing = easingFunc * distanceCy;
  const newCyPoint = goingUp ? startCy - easing : currentCy + easing;

  return newCyPoint;
};

const changeFaceSizeAndPosition = (
  goingUp,
  face,
  faceSize,
  facePositions,
  eyes,
  eyePositions,
  upperBodyParts,
  easingFunc,
) => {
  let { small, big } = faceSize;

  let newCyPoint = getNewCyPoint(goingUp, face, facePositions, easingFunc);
  let newCyEyePoint = getNewCyPoint(goingUp, eyes[0], eyePositions, easingFunc);

  let difference = (big - small) * easingFunc;
  let newRadius = goingUp ? small + difference : big - difference;

  let neckPosition = newCyPoint + newRadius;

  face.setAttribute("r", `${newRadius}`);
  face.setAttribute("cy", `${newCyPoint}`);

  upperBodyParts.forEach((part) => {
    part.setAttribute("y1", `${neckPosition}`);
  });

  eyes.forEach((eye) => {
    eye.setAttribute("cy", `${newCyEyePoint}`);
  });
};

const buildShapeTransition = (isPaused) => {
  // when the song is paused, we change from a play icon to a pause icon
  const from = isPaused ? "play" : "pause";
  const to = isPaused ? "pause" : "play";

  return Object.keys(shapes[from]).reduce((acc, key) => {
    acc[`start_shape_${key}`] = shapes[from][key];
    acc[`end_shape_${key}`] = shapes[to][key];
    return acc;
  }, {});
};

const returnPolygonShapes = (buttonType, isStarting) => {
  if (buttonType === "back") {
    return isStarting
      ? { startPolygon: shapesBackIcon.start, endPolygon: shapesBackIcon.end }
      : { startPolygon: shapesBackIcon.end, endPolygon: shapesBackIcon.start };
  }
  if (buttonType === "next") {
    return isStarting
      ? { startPolygon: shapesNextIcon.start, endPolygon: shapesNextIcon.end }
      : { startPolygon: shapesNextIcon.end, endPolygon: shapesNextIcon.start };
  }
};

const returnPolygonPoints = (startShape, endShape, easingFunc) => {
  return startShape.map((start, index) => {
    const end = endShape[index];
    const distance = end - start;
    const point = start + easingFunc * distance;
    return point;
  });
};

export {
  buildShapeTransition,
  easeOut,
  easeInOut,
  getProgress,
  getCX,
  getCY,
  changeFaceSizeAndPosition,
  returnPolygonPoints,
  returnPolygonShapes,
};
