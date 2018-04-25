function x = gammaincinv(y,a,tail)
%GAMMAINCINV  Inverse incomplete gamma function.
%   X = GAMMAINCINV(Y,A)
%   X = GAMMAINCINV(Y,A,TAIL)
%
%   See also: gammaincinv, tall.

%   Copyright 2016 The MathWorks, Inc.

narginchk(2,3);
[y,a] = tall.validateType(y,a,mfilename,{'single', 'double'},1:2);

% If supplied, the trailing argument must be the string 'lower' or 'upper'
if nargin>2
    validTail = {'upper','lower'};
    betaGammaCheckTail(tail,mfilename,2,validTail);

    % Bind-in the tail to avoid elementwise expansion
    fcn = @(p,q) gammaincinv(p,q,tail);
else
    % No tail supplied, so pure element-wise
    fcn = @gammaincinv;
end

x = elementfun(fcn, y, a);
end
