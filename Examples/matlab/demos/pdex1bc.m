function [pl,ql,pr,qr] = pdex1bc(xl,ul,xr,ur,t)
%PDEX1BC  Evaluate the boundary conditions for the problem coded in PDEX1.
%
%   See also PDEPE, PDEX1.

%   Lawrence F. Shampine and Jacek Kierzenka
%   Copyright 1984-2014 The MathWorks, Inc.

pl = ul;
ql = 0;
pr = pi * exp(-t);
qr = 1;