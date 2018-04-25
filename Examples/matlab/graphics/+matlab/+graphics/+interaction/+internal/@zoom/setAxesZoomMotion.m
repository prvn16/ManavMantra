function setAxesZoomMotion(hThis,hAx,style)

% Motion passes through to Constraint3D
cons = matlab.graphics.interaction.internal.constraintConvert2DTo3D(style);
setAxesZoomConstraint(hThis,hAx,cons);