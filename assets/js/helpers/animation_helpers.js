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

export {
  buildShapeTransition,
  easeOut,
  easeInOut,
  getProgress,
  getCX,
  getCY,
  changeFaceSizeAndPosition,
  returnPolygonPoints,
};
