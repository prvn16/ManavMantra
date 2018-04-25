function updateDTXHistReadouts(ntx)
% Update all lines and text readouts in the histogram display
% that are affected by changes to DTX parameters
% (especially threshold settings)

%   Copyright 2010 The MathWorks, Inc.

updateNumericTypesAndSigns(ntx);

updateWordTextAndXPos(ntx);
updateIntTextAndXPos(ntx);
updateFracTextAndXPos(ntx);
updateOverflowTextAndXPos(ntx);
updateUnderflowTextAndXPos(ntx);
updateBarThreshColor(ntx);

% affected by DTX changes
update(ntx.hResultingTypeDialog);

% xxx affected by y-scale, but not by under/over thresholds
%     do we need to call this here?
updateRadixLineYExtent(ntx);
