function b = anykind( o, kind )
%ANYKIND  b = ANYKIND( obj, K )  does any node in obj have Kind K
%   K may be a string or a cell array of strings

% Copyright 2006-2014 The MathWorks, Inc.

    b = any( iskind( o, kind ) );
end
