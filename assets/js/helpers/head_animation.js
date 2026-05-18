import {
  getProgress,
  getCX,
  changeFaceSizeAndPosition,
  easeInOut,
  easeOut,
} from "./animation_helpers.js";

import { animateCartoonEyes } from "./eyes_animation.js";

// The functions here animate circles. CX is the cx value of the circle
const deviation = 25;

// This is the blur
const blur = (start, gaussian) => {
  const time = {
    start,
    total: 800,
  };

  const blurFace = (now) => {
    time.elapsed = now - time.start;
    const progress = deviation - deviation * getProgress(time);
    gaussian.setAttribute("stdDeviation", `${progress}, 0`);
    if (progress) requestAnimationFrame(blurFace);
  };

  requestAnimationFrame(blurFace);
};

const animateCartoonHead = (
  targetElementIndex,
  finalCXValues,
  elementsAnimatingOrder,
  startCXValues,
  gaussianBlurElement,
) => {
  let index = targetElementIndex;
  const finalPosition = finalCXValues[index];
  const targetElement = elementsAnimatingOrder[index];
  const currentPosition = getCX(targetElement);
  const distance = currentPosition - finalPosition;
  const startX = startCXValues[index];

  const time = {
    start: performance.now(),
    total: 700,
  };

  const animateFace = (now) => {
    time.elapsed = now - time.start;

    const progress = getProgress(time);
    const easing = easeOut(progress) * distance;
    const cx = startX - easing;

    targetElement.setAttribute("cx", cx);

    if (progress < 1) {
      requestAnimationFrame(animateFace);
    } else {
      index += 1;

      if (index < 3) {
        animateCartoonHead(
          index,
          finalCXValues,
          elementsAnimatingOrder,
          startCXValues,
        );
      }
    }
  };

  if (index < 1) blur(time.start, gaussianBlurElement);

  requestAnimationFrame(animateFace);
};

const blinkEyesThenGoDown = (
  faceAnimation,
  eye1Animation,
  eye2Animation,
  upperBodyParts,
) => {
  const { eye_1, eyeSize } = eye1Animation;
  const { eye_2 } = eye2Animation;
  const eyes = [eye_1, eye_2];

  setTimeout(() => {
    animateFacePeriodically(
      "down",
      faceAnimation,
      eye1Animation,
      eye2Animation,
      upperBodyParts,
    );
  }, 3500);

  animateCartoonEyes(true, eyes, eyeSize);
};

const animateFacePeriodically = (
  animationDirection,
  faceAnimation,
  eye1Animation,
  eye2Animation,
  upperBodyParts,
) => {
  let goingUp = animationDirection === "up";

  const {
    face,
    faceCyValues: { smallCy, bigCy },
    faceSize,
  } = faceAnimation;

  const facePositions = goingUp
    ? { finalCy: bigCy, startCy: smallCy }
    : { finalCy: smallCy, startCy: bigCy };

  const { eye_1, eye1CyValues } = eye1Animation;
  const { eye_2 } = eye2Animation;
  const eyes = [eye_1, eye_2];

  const eyePositions = goingUp
    ? { finalCy: eye1CyValues.bigCy, startCy: eye1CyValues.smallCy }
    : { finalCy: eye1CyValues.smallCy, startCy: eye1CyValues.bigCy };

  const time = {
    start: performance.now(),
    total: 700,
  };

  const animate = (now) => {
    time.elapsed = now - time.start;
    const progress = getProgress(time);
    const easing = easeInOut(progress);

    changeFaceSizeAndPosition(
      goingUp,
      face,
      faceSize,
      facePositions,
      eyes,
      eyePositions,
      upperBodyParts,
      easing,
    );

    if (progress < 1) {
      requestAnimationFrame(animate);
    } else {
      goingUp
        ? blinkEyesThenGoDown(
            faceAnimation,
            eye1Animation,
            eye2Animation,
            upperBodyParts,
          )
        : setTimeout(() => {
            animateFacePeriodically(
              "up",
              faceAnimation,
              eye1Animation,
              eye2Animation,
              upperBodyParts,
            );
          }, 2500);
    }
  };

  requestAnimationFrame(animate);
};

export { animateCartoonHead, animateFacePeriodically };
