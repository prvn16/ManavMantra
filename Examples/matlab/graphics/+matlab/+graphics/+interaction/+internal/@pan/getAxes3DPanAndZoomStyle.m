function ver3D = getAxes3DPanAndZoomStyle(hThis,hAx)
% Given an axes, determine the style of pan allowed

% Copyright 2013 The MathWorks, Inc.

ver3D = matlab.graphics.interaction.internal.getAxes3DPanAndZoomStyle(hThis.FigureHandle,hAx);