function b = isstring( o, strs )
%ISSTRING  b = ISSTRING( obj, S ) true if nodes have string S
%   S may be a string or a cell array of strings
%ISSTRING  b = ISSTRING( obj ) behaves the same as the built-in string,
%   return false because mtree is not a string array.
% Copyright 2006-2016 The MathWorks, Inc.

  if nargin == 1
    b = false;
  else
    b = false(1,o.m);
    I = find( o.IX );
    for i=1:o.m
        ii = I(i);
        oo = makeAttrib( o, ii );
        if ~isnull( mtfind( oo, 'String', strs ) )
            b(i) = true;
        end
    end
  end
end
