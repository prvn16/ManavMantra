function resetVisual(this)
%RESETVISUAL Resets the visual.

%   Copyright 2010-2017 The MathWorks, Inc.


% reset the data and visual.
reset(this);
if isempty(this.Application.DataSource)
    % Update the visual after resetting the data. This clears out the axes and
    % other HG objects in the display.
    update(this);
    postUpdate(this);
else
    updateDisplay(this.Application.DataSource);
end
this.InputNeedsValidation = true;
     
% [EOF]
