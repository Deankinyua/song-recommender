import { getProgress, easeOut } from "./animation.js";

const closeOrShutEyes = (closing, eyeSize, easingFunc) => {
  let eyeSizeDifference = eyeSize * easingFunc;
  let newEyeSize = closing ? eyeSize - eyeSizeDifference : eyeSizeDifference;
  return Math.max(newEyeSize, 0);
};

const animateCartoonEyes = (closing, eyes, eyeSize) => {
  const time = {
    start: performance.now(),
    total: 1000,
  };

  const animateEyes = (now) => {
    time.elapsed = now - time.start;
    const progress = getProgress(time);
    const easing = easeOut(progress);

    let newEyeSize = closeOrShutEyes(closing, eyeSize, easing);

    eyes.forEach((eye) => {
      eye.setAttribute("r", `${newEyeSize}`);
    });

    if (progress < 1) {
      requestAnimationFrame(animateEyes);
    } else {
      closing
        ? setTimeout(() => {
            animateCartoonEyes(false, eyes, eyeSize);
          }, 1000)
        : null;
    }
  };

  requestAnimationFrame(animateEyes);
};

export { animateCartoonEyes };
