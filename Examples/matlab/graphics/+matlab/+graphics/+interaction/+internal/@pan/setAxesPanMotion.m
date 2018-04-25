function setAxesPanMotion(hThis,hAx,style)

% Motion passes through to Constraint3D
cons = matlab.graphics.interaction.internal.constraintConvert2DTo3D(style);
setAxesPanConstraint(hThis,hAx,cons);