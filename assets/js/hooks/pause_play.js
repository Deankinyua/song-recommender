let PausePlayHooks = {};

PausePlayHooks.PausePlay = {
  mounted() {
    const polygon_1 = document.getElementById("polygon-1");
    const polygon_2 = document.getElementById("polygon-2");
    const time = {
      start: null,
      total: 500,
    };

    // The shapes of the 2 polygons when they are in different states
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

    let isStopped = true;

    this.el.addEventListener("click", () => {
      requestAnimationFrame(playOrStop);
    });

    const getProgress = ({ elapsed, total }) => Math.min(elapsed / total, 1);

    const easeInOut = (progress) =>
      (progress *= 2) < 1
        ? 0.5 * Math.pow(progress, 5)
        : 0.5 * ((progress -= 2) * Math.pow(progress, 4) + 2);

    const buildShapeTransition = (isStopped) => {
      // when stopped is true, we move from pause to play
      const from = isStopped ? "pause" : "play";
      const to = isStopped ? "play" : "pause";

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
