function mouseDragWordSizeLine(ntx)
% Mouse drag starting at the horizontal wordsize cursor
%
% Need to do relative motion in pixels, not data range
% That's because the vertical axis can (and will) rescale on us during the
% drag operation, so data units quickly become "unreliable".  It's the
% relative motion we're after.
%
% We use ntx.LastDragWordSizeLine as temp storage of mouse coordinate

%   Copyright 2010 The MathWorks, Inc.

hax = ntx.hHistAxis;

% Get current point in pixels
pt = get(hax,'CurrentPoint'); % in data units
curr_y_data = pt(1,2); % in data units

yh_pix = get(hax,'Position');   % pos in pixels
yh_pix = yh_pix(4);        % height of axis in pixels
yh_data = get(hax,'YLim'); % ylim in data units
yh_data = yh_data(2);      % ylimmax in data units

% Convert current mouse height to pixels
curr_y_pix = curr_y_data * yh_pix/yh_data;

% LastDragWordSizeLine is reset to empty on mouse-up events
% Test for that
last_y_pix = ntx.LastDragWordSizeLine;
if isempty(last_y_pix)
    last_y_pix = curr_y_pix; % First call: copy current
end
ntx.LastDragWordSizeLine = curr_y_pix;

% Use vertical distance moved with mouse, relative to the total y-axis
% length, as the proportion of change.  This is generally in range [0,1],
% but is unbounded if the user drags beyond the y-limits.  Expect that.
frac = (curr_y_pix - last_y_pix);  % in pixels, allowing pos/neg drag

% Sensitivity, overall scale adjustment = pixels * sens
%  < 1 reduces sensitivity, > 1 increases it
% We're adjusting a number that's in the range [0,1]
% We add a fraction of the pixel count to the scale factor
%
% 0.01 -> 100 pixels of motion will add +1 to the scale factor
%    (and thereby saturate it at -1 or +1)
sens = 0.015;

% Use fraction to adjust scaling
% Scaling must be kept in range [0,1], and defaults to 0.5
scaling = ntx.DataPeakYScaling + frac*sens;
if scaling < 0
    scaling = 0;
elseif scaling > 1
    scaling = 1;
end
ntx.DataPeakYScaling = scaling;

% Minimal update of display
setYAxisLimits(ntx);
updateXAxisTextPos(ntx);
updateDTXTextAndLinesYPos(ntx);
