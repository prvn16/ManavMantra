function a = subsasgnRecurser(a,s,b)
%SUBSASGNRECURSER Utility for overloaded subsasgn method in @table.

%   Copyright 2012 The MathWorks, Inc.

% Call builtin, to get correct dispatching even if b is a table object.
a = builtin('subsasgn',a,s,b);
