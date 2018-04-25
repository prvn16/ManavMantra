function out = ternaryfun(condition, ifTrue, ifFalse)
%TERNARYFUN Helper that calls the underlying ternaryfun

%   Copyright 2016-2017 The MathWorks, Inc.

% This prevents this frame and anything below it being added to the gather
% error stack.
frameMarker = matlab.bigdata.internal.InternalStackFrame; %#ok<NASGU>

out = wrapUnderlyingMethod(@ternaryfun, ...
    {}, condition, ifTrue, ifFalse);
end
