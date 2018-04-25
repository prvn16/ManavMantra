function b = allstring( o, strs )
%ALLSTRING  b = ALLSTRING( obj, S ) true if all nodes have string S
%   S may be a string or a cell array of strings

% Copyright 2006-2014 The MathWorks, Inc.

    b = all( isstring( o, strs ) );
end
