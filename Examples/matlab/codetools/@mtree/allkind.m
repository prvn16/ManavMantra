function b = allkind( o, kind )
%ALLKIND  b = ALLKIND( obj, K )  do all nodes in obj have Kind K
%   K may be a string or a cell array of strings

% Copyright 2006-2014 The MathWorks, Inc.

    b = all( iskind( o, kind ) );
end
