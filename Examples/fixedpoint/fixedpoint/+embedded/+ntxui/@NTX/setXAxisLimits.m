function setXAxisLimits(ntx,xmin,xmax)
% Set new x-axis display limits, and switches
% x-axis to hold (non-autoscaling) mode.

%   Copyright 2010 The MathWorks, Inc.

ntx.XAxisDisplayMin = xmin;
ntx.XAxisDisplayMax = xmax;
ntx.XAxisAutoscaling = false;
updateXTickLabels(ntx);
