function disable(this)
%DISABLE  Disable this extension.

%   Copyright 2007-2015 The MathWorks, Inc.

% Reset the resize function.
hSP = this.ScrollPanel;
if ishghandle(hSP)
    
    % Remove our callback from the resize function, and put the old
    % imscrollpanel one back.
    oldFcn = get(hSP, 'ResizeFcn');
    set(hSP, 'ResizeFcn', oldFcn{3});

    % Make sure we remove the Callback from the newMagnification event.This
    % is not a listener, because the IMScrollPanel API is not an object.
    api = iptgetapi(hSP);
    api.removeNewMagnificationCallback(this.CallbackID);
    
    % Remove any callback on the image.
    api.setImageButtonDownFcn([]);
end

hFig = this.Application.Parent;

% Set the pointer back to an arrow and turn off the pointer manager.
iptPointerManager(hFig, 'disable');
set(hFig, 'Pointer', 'arrow');

this.hVisualChangedListener = [];

% [EOF]