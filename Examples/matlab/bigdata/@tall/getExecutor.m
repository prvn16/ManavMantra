function executor = getExecutor(t)
%getExecutor Get the underlying executor for the given tall array.
%
% This is an internal helper function that allows tall array method
% implementations to use the same underlying executor when wrapping a
% constant in a tall array.

% Copyright 2016 The MathWorks, Inc.

pv = hGetValueImpl(t);
executor = getExecutor(pv);
