function [yint,ypint] = ntrp3h(tint,t,y,tnew,ynew,yp,ypnew)
%NTRP3H  Interpolation helper function for BVP4C, DDE23, DDESD, and DDENSD.
%   YINT = NTRP3H(TINT,T,Y,TNEW,YNEW,YP,YPNEW) evaluates the Hermite cubic
%   interpolant at time TINT. TINT may be a scalar or a row vector.   
%   [YINT,YPINT] = NTRP3H(TINT,T,Y,TNEW,YNEW,YP,YPNEW) returns also the
%   derivative of the interpolating polynomial. 
%   
%   See also BVP4C, DDE23, DDESD, DDENSD, DEVAL.

%   Jacek Kierzenka and Lawrence F. Shampine
%   Copyright 1984-2005 The MathWorks, Inc.

h = tnew - t;
s = (tint - t)/h;
s2 = s .* s;
s3 = s .* s2;
slope = (ynew - y)/h;
c = 3*slope - 2*yp - ypnew;
d = yp + ypnew - 2*slope;
yint = y(:,ones(size(tint))) + (h*d*s3 + h*c*s2 + h*yp*s);        
if nargout > 1
  ypint = yp(:,ones(size(tint))) + (3*d*s2 + 2*c*s);  
end    

