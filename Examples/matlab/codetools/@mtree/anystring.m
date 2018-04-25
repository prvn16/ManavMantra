function b = anystring( o, strs )
%ANYSTRING  b = ANYSTRING( obj, S ) true if some node has string S
%   S may be a string or a cell array of strings

% Copyright 2006-2014 The MathWorks, Inc.

    b = any( isstring( o, strs ) );
end
