function mouseUpLocal(ntx)
% Invoked when the mouse button has been released after it was pressed
% when hovering over one of the threshold lines

%   Copyright 2010 The MathWorks, Inc.

% Shut down motion function immediately
set(ntx.hFig,'WindowButtonMotionFcn',[]);

% Reset if a threshold drag
% Reset at end of mouse drag
% (only a small overhead if that wasn't the drag operation being performed,
%  and not an operational issue)
ntx.LastDragWordSizeLine = [];

% Let DialogPanel try to handle mouse up event first
handledMouseUp = mouseUp(ntx.dp);
if ~handledMouseUp
    % No other systems handled up event
    % Let NTX deal with it
    
    if ntx.WhichLineDragged == 4 % wordlength region
        % Change from closed hand pointer to the pointer that would be
        % used if the mouse button was not being pressed
        mouseMoveLocal(ntx);
    end
end

% Key part: reset mouse handlers
enableMouse(ntx);
