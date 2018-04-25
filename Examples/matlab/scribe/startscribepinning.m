function startscribepinning(fig,onoff)
%STARTSCRIBEPINNING Turn annotation pinning mode on or off.

%   Copyright 1984-2014 The MathWorks, Inc.
%     $  $

% find the togglebutton
pintogg = uigettool(fig,'Annotation.Pin');

[scribeaxes, container_scribeaxes] = findAllScribeLayers(fig); 
scribeaxes = [scribeaxes container_scribeaxes];
scribechildren = get(scribeaxes,{'Children'});
scribechildrenExist = ~all(cellfun('isempty',scribechildren));

% if scribeaxes has no shapes or none of those shapes
% are rectangle, ellipse, textbox or arrow, then there is nothing to pin, so turn
% the pinning toggle off, set the cursor to an arrow and return
if ~scribechildrenExist
    if ~isempty(pintogg)
        set(pintogg,'state','off');
    end
    scribecursors(fig,0); 
    return;
end

% if this is being called by the toggle with just a fig arg and the toggle
% is now off, or called from elsewhere with onoff of 'off', turn pinning
% off. Otherwise turn it on.
if (nargin<2 && strcmpi(get(pintogg,'state'),'off')) || ...
        (nargin>1 && ischar(onoff) && strcmpi(onoff,'off'))
    pinning_onoff(fig,scribeaxes,pintogg,'off');
else
    pinning_onoff(fig,scribeaxes,pintogg,'on');
end

%----------------------------------------------------------------%
function pinning_onoff(fig,~,pintogg,onoff)

hPlotEdit = plotedit(fig,'getmode');
if strcmpi(onoff,'on')
    % be sure plotedit is on
    plotedit(fig,'on');
    activateuimode(hPlotEdit,'Standard.ScribePin');
else
    if ~isempty(hPlotEdit.CurrentMode)
        activateuimode(hPlotEdit,'');
    end
    % turn togglebutton off
    if ~isempty(pintogg)
        set(pintogg,'state','off');
    end
    scribecursors(fig,0); 
end

%----------------------------------------------------------------%