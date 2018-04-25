function y = gammainc(x,a,tail)
%GAMMAINC  Incomplete gamma function.
%   Y = GAMMAINC(X,A)
%   Y = GAMMAINC(X,A,TAIL)
%
%   See also: gammainc, tall.

%   Copyright 2016 The MathWorks, Inc.

narginchk(2,3);
[x,a] = tall.validateType(x,a,mfilename,{'single', 'double'},1:2);

% If supplied, the trailing argument must be the string 'lower', 'upper',
% 'scaledlower', or 'scaledupper'
if nargin>2
    validTail = {'upper','lower','scaledlower','scaledupper'};
    betaGammaCheckTail(tail,mfilename,2,validTail);

    % Bind-in the tail to avoid elementwise expansion
    fcn = @(p,q) gammainc(p,q,tail);
else
    % No tail supplied, so pure element-wise
    fcn = @gammainc;
end

y = elementfun(fcn, x, a);
end
