function Kn = inverse_cordic_growth_constant(niter)
% Kn = INVERSE_CORDIC_GROWTH_CONSTANT(NITER) returns the inverse of the 
% CORDIC growth factor after NITER iterations. Kn quickly converges to around
% 0.60725.  

%   Copyright 2010 The MathWorks, Inc.

  if nargin<1, niter = 52; end
  Kn = 1/cordic_growth_constant(niter);
end