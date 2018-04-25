function res = twobc(ya,yb)
%TWOBC  Evaluate the residual in the boundary conditions for TWOBVP.
%
%   See also TWOODE, TWOBVP.

%   Lawrence F. Shampine and Jacek Kierzenka
%   Copyright 1984-2014 The MathWorks, Inc.

res = [ ya(1); yb(1) + 2 ];
