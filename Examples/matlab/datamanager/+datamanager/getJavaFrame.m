function javaFrame = getJavaFrame(f)

%   Copyright 2007-2012 The MathWorks, Inc.

% store the last warning thrown
[ lastWarnMsg, lastWarnId ] = lastwarn;

% disable the warning when using the 'JavaFrame' property
% this is a temporary solution
oldJFWarning = warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
javaFrame = get(f,'JavaFrame');
% Following if - else statement is used to be compliant with the message
% catalog autoconversion tool.
% warning(oldJFWarning.state, 'MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
if strcmp(oldJFWarning.state,'on')
    warning('on', 'MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
elseif strcmp(oldJFWarning.state,'off')
    warning('off', 'MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
end
% restore the last warning thrown
lastwarn(lastWarnMsg, lastWarnId);
