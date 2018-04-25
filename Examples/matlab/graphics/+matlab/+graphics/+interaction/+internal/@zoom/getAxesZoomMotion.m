function style = getAxesZoomMotion(hThis,hAx)

% Motion passes through to Constraint3D
cons = getAxesZoomConstraint(hThis,hAx);
style = cell(numel(cons),1);
for i = 1:numel(cons)
    style{i} = matlab.graphics.interaction.internal.constraintConvert3DTo2D(cons{i});
end