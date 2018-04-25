function yp = lotka(t,y)
%LOTKA  Lotka-Volterra predator-prey model.

%   Copyright 1984-2014 The MathWorks, Inc.

yp = diag([1 - .01*y(2), -1 + .02*y(1)])*y;
