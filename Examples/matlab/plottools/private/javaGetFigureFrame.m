function javaFrame = javaGetFigureFrame(f)

%   Copyright 2007-2012 The MathWorks, Inc.

% Make sure the figure is valid.
if isempty(f) || ~ishandle(f)
    javaFrame = [];
    return
end

% store the last warning thrown
[ lastWarnMsg, lastWarnId ] = lastwarn;

% disable the warning when using the 'JavaFrame' property
% this is a temporary solution
oldJFWarning = warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
javaFrame = get(f,'JavaFrame');
warning(oldJFWarning.state, 'MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');

% restore the last warning thrown
lastwarn(lastWarnMsg, lastWarnId);