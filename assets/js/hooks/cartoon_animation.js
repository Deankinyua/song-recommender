import { getProgress, getCX, easeInOut } from "../helpers/animation.js";
import { setLineCoordinates } from "../helpers/body_animation.js";
import {
  animateCartoonHead,
  animateFacePeriodically,
} from "../helpers/head_animation.js";

let CartoonAnimationHooks = {};

CartoonAnimationHooks.CartoonAnimation = {
  mounted() {
    const line_1 = document.querySelector(".line-1");
    const line_2 = document.querySelector(".line-2");
    const line_3 = document.querySelector(".line-3");
    const line_4 = document.querySelector(".line-4");
    const line_5 = document.querySelector(".line-5");
    const gaussian = document.querySelector("feGaussianBlur");
    const face = document.getElementById("cartoon-face");
    const eye_1 = document.getElementById("eye-1");
    const eye_2 = document.getElementById("eye-2");

    // Concerned with the head ------------------------------
    let initialHeadElementIndex = 0;
    const startCXValues = [getCX(face), getCX(eye_1), getCX(eye_2)];
    const finalCXValues = [70, 66.5, 73.5];
    const headElementsAnimatingOrder = [face, eye_1, eye_2];
    // --------------------------------------------------

    // Concerned with the body------------------------------
    let initialBodyElementIndex = 0;
    const bodyElementsAnimatingOrder = [line_5, line_3, line_1, line_2, line_4];

    let line_1_coordinates = { x1: 70, y1: 80, x2: 70, y2: 105 };
    let line_2_coordinates = { x1: 70, y1: 80, x2: 60, y2: 95 };
    let line_3_coordinates = { x1: 70, y1: 105, x2: 60, y2: 120 };
    let line_4_coordinates = { x1: 70, y1: 80, x2: 80, y2: 95 };
    let line_5_coordinates = { x1: 70, y1: 105, x2: 80, y2: 120 };

    const faceSize = { small: 10, big: 14 };
    const faceCyValues = { smallCy: 70, bigCy: 52 };
    const faceAnimation = { face, faceCyValues, faceSize };

    const eyeSize = 0.5;
    const eyeCyValues = { smallCy: 67.5, bigCy: 49.5 };
    const eye1Animation = { eye_1, eyeSize, eye1CyValues: eyeCyValues };
    const eye2Animation = { eye_2, eyeSize, eye2CyValues: eyeCyValues };

    const lineCoordinates = [
      line_5_coordinates,
      line_3_coordinates,
      line_1_coordinates,
      line_2_coordinates,
      line_4_coordinates,
    ];
    // --------------------------------------------

    const animateCartoonBody = (
      targetElementIndex,
      elementsAnimatingOrder,
      lineCoordinates,
    ) => {
      let index = targetElementIndex;
      const targetLine = elementsAnimatingOrder[index];

      const time = {
        start: performance.now(),
        total: 1500,
      };

      const animateLegs = (now) => {
        time.elapsed = now - time.start;
        const progress = getProgress(time);
        const easing = easeInOut(progress);
        const coordinates = lineCoordinates[index];

        setLineCoordinates(targetLine, coordinates, easing);

        if (progress < 1) {
          requestAnimationFrame(animateLegs);
        } else {
          index += 1;

          index < 5
            ? animateCartoonBody(index, elementsAnimatingOrder, lineCoordinates)
            : animateCartoonHead(
                initialHeadElementIndex,
                finalCXValues,
                headElementsAnimatingOrder,
                startCXValues,
                gaussian,
              );
        }
      };

      requestAnimationFrame(animateLegs);
    };

    setTimeout(() => {
      animateCartoonBody(
        initialBodyElementIndex,
        bodyElementsAnimatingOrder,
        lineCoordinates,
      );
    }, 1000);

    const animateCartoonFacePeriodically = () =>
      animateFacePeriodically(
        "up",
        faceAnimation,
        eye1Animation,
        eye2Animation,
        [line_1, line_2, line_4],
      );

    setTimeout(() => {
      animateCartoonFacePeriodically();
    }, 11000);
  },
};

export default CartoonAnimationHooks;
