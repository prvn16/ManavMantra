function cordic_growth = cordic_growth_constant(niter)
% CORDIC_GROWTH_CONSTANT(NITER) returns the CORDIC growth factor after
% NITER iterations. Kn quickly converges to around 1.6468.

%   Copyright 2010 The MathWorks, Inc.

  if nargin<1, niter = 27; end
  cordic_growth = prod(sqrt(1+2.^(-2*(0:double(niter)-1))));
end