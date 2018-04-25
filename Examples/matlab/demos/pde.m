function [c,f,s] = pde(x,t,u,DuDx)
%PDE pde demo function

%   Copyright 1984-2014 The MathWorks, Inc.

c = pi^2;
f = DuDx;
s = 0;
