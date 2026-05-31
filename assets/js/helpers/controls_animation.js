import {
  getProgress,
  easeInOut,
  returnPolygonPoints,
  returnPolygonShapes,
} from "./animation.js";

const animateControlButton = (buttonType, isStarting, polygon) => {
  const time = {
    start: performance.now(),
    total: 150,
  };

  const animatePolygon = (now) => {
    time.elapsed = now - time.start;
    const progress = getProgress(time);
    const easing = easeInOut(progress);

    const { startPolygon, endPolygon } = returnPolygonShapes(
      buttonType,
      isStarting,
    );

    const polygon_points = returnPolygonPoints(
      startPolygon,
      endPolygon,
      easing,
    );

    polygon.setAttribute("points", polygon_points.join(" "));

    if (progress < 1) requestAnimationFrame(animatePolygon);
    if (progress >= 1) {
      isStarting
        ? setTimeout(() => {
            animateControlButton(buttonType, false, polygon);
          }, 100)
        : null;
    }
  };

  requestAnimationFrame(animatePolygon);
};

export { animateControlButton };
