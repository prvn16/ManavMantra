function t = dongarra(n)
%DONGARRA   A benchmark.

%   Copyright 1984-2014 The MathWorks, Inc.

A = rand(n);
b = rand(n,1);
tic;
[x,r] = linsolve(A,b);
t = toc;
