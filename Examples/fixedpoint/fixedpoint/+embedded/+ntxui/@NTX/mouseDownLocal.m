function mouseDownLocal(ntx)
% Capture current location, and record shift-click state

%   Copyright 2010-2012 The MathWorks, Inc.

% The mouse could have moved since the last "hover" operation
% so make an explicit call to update mouse motion:
mouseMoveLocal(ntx);

% Let DialogPanel handle any mouseDown events of its own first
motionFcn = mouseDown(ntx.dp);

hfig = ntx.hFig;
if isempty(motionFcn)
    % Assume threshold cursors or wordlength region brought us here
    
    % Refresh after mouseMoveLocal() call
    
    % Mouse selection type
    %  normal: left click
    %  alt: right click, or ctrl+click (left or right)
    %  extend: shift+click (left or right)
    %  open: double-click (left or right)
    selType = get(hfig,'SelectionType');
    
    switch ntx.WhichLineDragged
        case 0
            % Do nothing - basically, ignore the button down event
            %
            % Do NOT set mouse motion function, etc
            
            return % EARLY EXIT
            
        case 1
            % Mouse down on underflow line
            % Enable drag line fcn
            motionFcn = @(h,e)mouseDragThresholdLine(ntx);
            % Check linestyle of "other" line
            isBlack = all(get(ntx.hlOver,'Color')==0);
            ntx.LockThresholds = ~isBlack && ...
                any(strcmpi(selType,{'alt','extend'}));
        case 2
            % Mouse down on overflow line
            % Enable drag line fcn
            motionFcn = @(h,e)mouseDragThresholdLine(ntx);
            % Check linestyle of "other" line
            isBlack = all(get(ntx.hlUnder,'Color')==0);
            ntx.LockThresholds = ~isBlack && ...
                any(strcmpi(selType,{'alt','extend'}));
        case 3
            % Mouse down on WordSize line
            motionFcn = @(h,e)mouseDragWordSizeLine(ntx);
            
        case 4
            % Mouse down in wordsize (WL) region
            % Perform locked drag if both cursors are ok to lock
            %
            % mouseMoveLocal() checks this and WhichLineDragged wouldn't be 4
            % unless conditions for dragging WL region were met
            %
            % However, we only allow "normal" click, not right or shift
            if ~strcmpi(selType,'normal')
                return % EARLY EXIT
            end
                %{
            isBlack = ...
                all(get(ntx.hlOver,'color')==0) || ...
                all(get(ntx.hlUnder,'color')==0);
            ntx.LockThresholds = ~isBlack;
                %}
            ntx.LockThresholds = true;
            motionFcn = @(h,e)mouseDragThresholdLine(ntx);
            setptr(hfig,'closedhand');
            
        otherwise
            % We should never get here:
            % Internal message to help debugging. Not intended to be user-visible.
            error(message('fixed:NumericTypeScope:unsupportedEnumerationMouseDown',ntx.WhichLineDragged));
    end
end
set(hfig, ...
    'WindowScrollWheelFcn','', ...
    'WindowButtonDownFcn','', ...
    'WindowButtonMotionFcn',motionFcn, ...
    'WindowButtonUpFcn',@(hco,ev)mouseUpLocal(ntx));
