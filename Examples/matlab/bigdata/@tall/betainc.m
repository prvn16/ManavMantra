function y = betainc(x,z,w,tail)
%BETAINC  Incomplete beta function.
%   Y = BETAINC(X,Z,W)
%   Y = BETAINC(X,Z,W,TAIL)
%
%   See also: betainc, tall.

%   Copyright 2016 The MathWorks, Inc.

narginchk(3,4);
[x,z,w] = tall.validateType(x,z,w,mfilename,{'single', 'double'},1:3);

% If supplied, the trailing argument must be the string 'lower' or 'upper'
if nargin>3
    validTail = {'upper','lower'};
    betaGammaCheckTail(tail,mfilename,3,validTail);

    % Bind-in the tail to avoid elementwise expansion
    fcn = @(a,b,c) betainc(a,b,c,tail);
else
    % No tail supplied, so pure element-wise
    fcn = @betainc;
end

y = elementfun(fcn, x, z, w);
end
