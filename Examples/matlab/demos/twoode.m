function dydx = twoode(x,y)
%TWOODE  Evaluate the differential equations for TWOBVP.
%
%   See also TWOBC, TWOBVP.

%   Lawrence F. Shampine and Jacek Kierzenka
%   Copyright 1984-2014 The MathWorks, Inc.

dydx = [ y(2); -abs(y(1)) ];