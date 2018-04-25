function sysObj = getSystemForConversion(h)
% GETSYSTEMFORCONVERSION Returns the Object of the system that is being
% converted

% Copyright 2015 The MathWorks, inc

sysObj = h.GoalSpecifier.getSystemForConversion;
