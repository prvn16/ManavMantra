function modeWindowKeyReleaseFcn(hMode,hFig,evd,hThis,newKeyUpFcn) %#ok
% This function is undocumented and will change in a future release

% Modify the window callback function as specified by the mode. Techniques
% to minimize mode interaction issues are used here.

%  Copyright 2013-2015 The MathWorks, Inc.

appdata = hThis.FigureState;

% Restore any key functions on the object we clicked on
if isfield(appdata, 'KeyPressFcnRestorer')
    appdata.KeyPressFcnRestorer = [];
end

hThis.FigureState = appdata;

%Execute the specified callback function
hgfeval(newKeyUpFcn,hFig,evd);
