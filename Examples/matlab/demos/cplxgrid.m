function z = cplxgrid(m)
%CPLXGRID Polar coordinate complex grid.
%   Z = CPLXGRID(m) is an (m+1)-by-(2*m+1) complex polar grid.
%   See CPLXMAP.

%   Copyright 1984-2014 The MathWorks, Inc.

r = (0:m)'/m;
theta = pi*(-m:m)/m;
z = r * exp(i*theta);
