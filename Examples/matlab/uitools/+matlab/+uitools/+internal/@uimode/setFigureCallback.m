function storedValue = setFigureCallback(hThis,hFig,propName,callback)
% This function is undocumented and will change in a future release

% Sets the (undocumented) property of the figure.

%   Copyright 2013 The MathWorks, Inc.

% This function is only supported with java figures

if ~usejava('awt')
    storedValue = [];
    return;
end

%Disable the JavaFrame warning:
[ lastWarnMsg, lastWarnId ] = lastwarn; 
oldstate = warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame'); 

javaFrame = handle(get(hFig,'JavaFrame'));

% Restore the warning state:
warning(oldstate);
lastwarn(lastWarnMsg,lastWarnId);

if isempty(javaFrame)
    storedValue = [];
    return;
end
axisComponent = handle(javaFrame.getAxisComponent);

if isfield(hThis.WindowJavaListeners,propName) && ~isempty(hThis.WindowJavaListeners.(propName))
    delete(hThis.WindowJavaListeners.(propName))
end

% All properties are set on the axis component.
hThis.WindowJavaListeners.(propName) = handle.listener(axisComponent,propName,callback);
set(hThis.WindowJavaListeners.(propName),'Enable',hThis.Enable);
storedValue = callback;