function modeWindowKeyPressFcn(~,hFig,evd,hThis,newKeyPressFcn)
% This function is undocumented and will change in a future release

% Modify the window callback function as specified by the mode. Techniques
% to minimize mode interaction issues are used here.

%   Copyright 2013-2015 The MathWorks, Inc.

%If we are in a bad state due to figure-copying, try to recover gracefully:
if ~isvalid(hThis) || hFig ~= hThis.FigureHandle
    set(hFig,'WindowButtonDownFcn','');
    set(hFig,'WindowButtonUpFcn','');
    set(hFig,'WindowKeyPressFcn','');
    set(hFig,'WindowKeyReleaseFcn','');
    set(hFig,'KeyPressFcn','');
    set(hFig,'KeyReleaseFcn','');
    set(hFig,'Pointer',get(0,'DefaultFigurePointer'));
    if isprop(hFig,'ScribeClearModeCallback')
        hFig.ScribeClearModeCallback = '';  
    end    
    return;
end

appdata = hThis.FigureState;

%If we typed on a UIControl object, return unless we are suspending the
%callback.
oldState = get(groot,'ShowHiddenHandles');
set(groot,'ShowHiddenHandles','on');
h = get(hFig,'CurrentObject');
set(groot,'ShowHiddenHandles',oldState);
if ~isempty(h) && (ishghandle(h,'uicontrol') || ishghandle(h,'uitable'))
    if ~hThis.UIControlInterrupt
        return;
    end
end

%Execute the specified callback function
hgfeval(newKeyPressFcn,hFig,evd);

% Disable any button functions on the object we typed on.

% First execute the current key restorer by destroying it, if there is one. 
% Key presses do not execute in a strict down-up-down-up sequence so there
% may be multiple keydowns in a sequence, and the key-up may be on a
% different object.
if isfield(appdata, 'KeyPressFcnRestorer') && ~isempty(appdata.KeyPressFcnRestorer)
    delete(appdata.KeyPressFcnRestorer);
    appdata.KeyPressFcnRestorer = [];
end

if ~isempty(h) && isprop(h, 'KeyPressFcn') && ~ishghandle(h,'figure')
    % Create a new restorer for this object
    FcnToRestore = h.KeyPressFcn;
    appdata.KeyPressFcnRestorer = onCleanup(@() setIfValid(h, 'KeyPressFcn', FcnToRestore));

    % Remove the current KeyPressFcn so that it doesn't execute
    h.KeyPressFcn = [];
end

hThis.FigureState = appdata;



function setIfValid(h, prop, value)
% Reset a property if both the object handle is still valid
if isvalid(h)
    h.(prop) = value;
end
