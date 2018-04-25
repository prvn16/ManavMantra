function [c,f,s] = pdex1pde(x,t,u,DuDx)
%PDEX1PDE  Evaluate the differential equations components for the PDEX1 problem.
%
%   See also PDEPE, PDEX1.

%   Lawrence F. Shampine and Jacek Kierzenka
%   Copyright 1984-2014 The MathWorks, Inc.

c = pi^2;
f = DuDx;
s = 0;