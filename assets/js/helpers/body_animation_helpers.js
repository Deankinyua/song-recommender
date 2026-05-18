let setLineCoordinates = (
  targetElement,
  targetElementCoordinates,
  easingFunc,
) => {
  let { x1, y1, x2, y2 } = targetElementCoordinates;

  const x_distance = x2 - x1;
  const x_point = x1 + easingFunc * x_distance;
  const y_distance = y2 - y1;
  const y_point = y1 + easingFunc * y_distance;

  targetElement.setAttribute("x1", `${x1}`);
  targetElement.setAttribute("y1", `${y1}`);
  targetElement.setAttribute("x2", `${x_point}`);
  targetElement.setAttribute("y2", `${y_point}`);
};

export { setLineCoordinates };
