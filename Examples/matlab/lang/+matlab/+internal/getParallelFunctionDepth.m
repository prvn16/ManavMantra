function val = getParallelFunctionDepth()
%getParallelFunctionDepth get the current parallel function depth
%
% Get the current parallel function depth.

%   Copyright 2008 The MathWorks, Inc.

% Get the current value by incrementing by zero
val = matlab.internal.incrementParallelFunctionDepth(0);