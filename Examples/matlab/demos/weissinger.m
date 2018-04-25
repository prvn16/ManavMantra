function res = weissinger(t,y,yp)
%WEISSINGER  Evaluate the residual of the Weissinger implicit ODE
%
%   See also ODE15I.

%   Jacek Kierzenka and Lawrence F. Shampine
%   Copyright 1984-2014 The MathWorks, Inc.

res = t*y^2 * yp^3 - y^3 * yp^2 + t*(t^2 + 1)*yp - t^2 * y;
