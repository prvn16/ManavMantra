function c = linspace(a,b,n)
%LINSPACE Create equally-spaced sequence of durations.
%   C = LINSPACE(A,B) generates a row vector of 100 equally-spaced durations
%   between A and B. A and B are scalar durations.
%  
%   C = LINSPACE(A,B,N) generates N points between A and B. For N = 1, LINSPACE
%   returns B.

%   Copyright 2014 The MathWorks, Inc.

if nargin < 3, n = 100; end
[amillis,bmillis,c] = duration.compareUtil(a,b);

if ~isscalar(amillis) || ~isscalar(bmillis) || ~isscalar(n)
    error(message('MATLAB:duration:linspace:NonScalarInputs'));
end

c.millis = linspace(amillis,bmillis,n);
