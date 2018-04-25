function y = removefimath(x)
%REMOVEFIMATH Remove FIMATH object on output for fixed-point input
%
%   See also REMOVEFIMATH, SETFIMATH.

%   Copyright 2011-2012 The MathWorks, Inc.
    nargoutchk(1,1);
    y = x;
    y.fimathislocal = false;
end

% LocalWords:  SETFIMATH
