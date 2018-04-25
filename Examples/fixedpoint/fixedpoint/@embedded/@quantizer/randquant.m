function u = randquant(q,varargin)
%RANDQUANT Uniformly distributed quantized random number
%   RANDQUANT(Q,N)
%   RANDQUANT(Q,M,N)
%   RANDQUANT(Q,M,N,P,...)
%   RANDQUANT(Q,[M,N])
%   RANDQUANT(Q,[M,N,P,...])
%
%   Works like RAND except the numbers are quantized and:
%   (1) If Q is a fixed-point quantizer then the numbers cover the
%       range of Q. 
%   (2) If Q is a floating-point quantizer then the numbers cover +- the
%       square-root of the realmax of Q.
%
%   Example:
%
%     q=quantizer([4 3]);
%     rng('default')
%     randquant(q,3)
%
%   returns
%
%     0.5000    0.6250   -0.5000
%     0.6250    0.1250         0
%    -0.8750   -0.8750    0.7500
%
%   See also QUANTIZER, EMBEDDED.QUANTIZER/RANGE, 
%            EMBEDDED.QUANTIZER/REALMAX, RAND

%   Copyright 1999-2012 The MathWorks, Inc.

u = rand(varargin{:});

switch q.mode
  case {'fixed','ufixed'}
    [a,b]=range(q);
    u = (b-a)*u+a;
  otherwise
    % In floating-point, cover +-sqrt(realmax(q))
    r = sqrt(q.realmax);
    u = r*(2*u-1);
end

u = q.quantizenumeric(u);
