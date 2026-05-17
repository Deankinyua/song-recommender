import {
  getProgress,
  easeInOut,
  buildShapeTransition,
  returnPolygonPoints,
} from "js/helpers/animation_helpers.js";

let PausePlayHooks = {};

PausePlayHooks.PausePlay = {
  mounted() {
    const polygon_1 = document.getElementById("polygon-1");
    const polygon_2 = document.getElementById("polygon-2");

    const time = {
      start: null,
      total: 500,
    };

    let isStopped = true;

    this.el.addEventListener("click", () => {
      requestAnimationFrame(playOrStop);
    });

    const playOrStop = (now) => {
      if (!time.start) time.start = now;
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

      if (progress < 1) requestAnimationFrame(playOrStop);
      if (progress >= 1) {
        isStopped = !isStopped;
        time.start = null;
      }
    };
  },
};

export default PausePlayHooks;
