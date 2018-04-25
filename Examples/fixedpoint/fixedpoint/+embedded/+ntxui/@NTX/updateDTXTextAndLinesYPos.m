function updateDTXTextAndLinesYPos(ntx)
% Updates Y-position of datatype explorer text and lines

%   Copyright 2010 The MathWorks, Inc.

% Only show explorer overlay if the user requested it,
% and the system allows it:
updateDTXTextYPos(ntx);  % do before updating lines
updateDTXLinesYPos(ntx); % needs text ypos updated first
    
