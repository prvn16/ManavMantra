function scale = getImageScale
% This function is undocumented and may change without notice.

% Copyright 2015 The MathWorks, Inc.

ss = get(0,'ScreenSize');
dpss = matlab.ui.internal.PositionUtils.getDevicePixelScreenSize;
ratios = (dpss./ss);
scale = ratios(end);
