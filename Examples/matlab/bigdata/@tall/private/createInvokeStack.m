function stack = createInvokeStack(name)
%createInvokeStack create the stack captured by all invoke methods for gather errors.
%
% This should only be called by the tall/invoke methods.
%

% Copyright 2016 The MathWorks, Inc.

stack = dbstack('-completenames', 2);

if nargin
    tallName = ['tall/', name];
else
    tallName = 'tall';
end
topStackFrame = struct('file', {''}, 'name', {tallName}, 'line', {0});
stack = [topStackFrame; stack];
