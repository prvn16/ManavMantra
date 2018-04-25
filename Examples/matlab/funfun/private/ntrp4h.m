function [yint,ypint] = ntrp4h(tint,t,y,tnew,ynew,ymid,yp,ypnew)
%NTRP4H  Interpolation helper function for BVP5C.
%   YINT = NTRP4H(TINT,T,Y,TNEW,YNEW,YMID,YP,YPNEW) evaluates the quartic
%   interpolant interpolant at time TINT. TINT may be a scalar or a row
%   vector.  The quartic interpolates y,yp at t; ynew,ypnew at tnew; and
%   ymid at (t+tnew)/2.
%   [YINT,YPINT] = NTRP4H(TINT,T,Y,TNEW,YNEW,YMID,YP,YPNEW) returns also 
%   the derivative of the interpolating polynomial. 
%   
%   See also BVP5C, DEVAL.

%   Jacek Kierzenka and Lawrence F. Shampine
%   Copyright 1984-2007 The MathWorks, Inc.

% Convert to the scaled variable s with x = t + sh.  Must then convert 
% the derivatives: d/ds = d/dx * dx/ds = h*d/dx.
h = tnew - t;
s = (tint - t)/h;
s2 = s .* s;
s3 = s .* s2;
s4 = s .* s3;
y0p = h*yp;
y1p = h*ypnew;
del1 = ymid - y;
del2 = ynew - ymid;
del3 = y1p - y0p;
A2 = ((  11*del1 -  5*del2) +   del3) - 3*y0p;
A3 = ((- 18*del1 + 14*del2) - 3*del3) + 2*y0p;
A4 =  (   8*del1 -  8*del2) + 2*del3;
yint = y(:,ones(size(tint))) + (y0p*s + A2*s2 + A3*s3 + A4*s4);
if nargout > 1
  ypint = y0p(:,ones(size(tint))) + (2*A2*s + 3*A3*s2 + 4*A4*s3); 
  % Convert from d/ds to d/dx:  
  ypint = ypint ./ h;
end
