function javaFrame = getJavaFrame(f)

%   Copyright 2007-2017 The MathWorks, Inc.

% store the last warning thrown
[ lastWarnMsg, lastWarnId ] = lastwarn;

% disable the warning when using the 'JavaFrame' property
% this is a temporary solution
oldJFWarning = warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
javaFrame = get(f,'JavaFrame');
% Following line is replaced by the if else condition to satisfy the
% compliance with message catalog pass.
% warning(oldJFWarning.state, 'MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
if (strcmp(oldJFWarning.state,'on'))
    warning('on', 'MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
elseif (strcmp(oldJFWarning.state,'off'))
    warning('off', 'MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
end
% restore the last warning thrown
lastwarn(lastWarnMsg, lastWarnId);