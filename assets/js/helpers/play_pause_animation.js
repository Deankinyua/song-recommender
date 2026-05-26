import {
  getProgress,
  easeInOut,
  buildShapeTransition,
  returnPolygonPoints,
} from "./animation.js";

const animatePausePlayButton = (isStopped, polygon_1, polygon_2) => {
  return new Promise((resolve) => {
    const time = {
      start: performance.now(),
      total: 500,
    };

    const playOrPause = (now) => {
      time.elapsed = now - time.start;
      const progress = getProgress(time);
      const easing = easeInOut(progress);

      let {
        start_shape_polygon_1,
        end_shape_polygon_1,
        start_shape_polygon_2,
        end_shape_polygon_2,
      } = buildShapeTransition(isStopped);

      const polygon_1_points = returnPolygonPoints(
        start_shape_polygon_1,
        end_shape_polygon_1,
        easing,
      );

      const polygon_2_points = returnPolygonPoints(
        start_shape_polygon_2,
        end_shape_polygon_2,
        easing,
      );

      polygon_1.setAttribute("points", polygon_1_points.join(" "));
      polygon_2.setAttribute("points", polygon_2_points.join(" "));

      if (progress < 1) requestAnimationFrame(playOrPause);
      if (progress >= 1) {
        isStopped = !isStopped;
        resolve(isStopped);
      }
    };

    requestAnimationFrame(playOrPause);
  });
};

export { animatePausePlayButton };
