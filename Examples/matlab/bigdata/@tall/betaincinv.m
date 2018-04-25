function x = betaincinv(y,z,w,tail)
%BETAINCINV  Inverse incomplete beta function.
%   X = BETAINCINV(Y,Z,W)
%   X = BETAINCINV(Y,Z,W,TAIL)
%
%   See also: betaincinv, tall.

%   Copyright 2016 The MathWorks, Inc.

narginchk(3,4);
[y,z,w] = tall.validateType(y,z,w,mfilename,{'single', 'double'},1:3);

% If supplied, the trailing argument must be the string 'lower' or 'upper'
if nargin>3
    validTail = {'upper','lower'};
    betaGammaCheckTail(tail,mfilename,3,validTail)

    % Bind-in the tail to avoid elementwise expansion
    fcn = @(a,b,c) betaincinv(a,b,c,tail);
else
    % No tail supplied, so pure element-wise
    fcn = @betaincinv;
end

x = elementfun(fcn, y, z, w);
end
