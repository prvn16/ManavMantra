function [X, info]= sylvester_tri(A, B, C)
%SYLVESTER_TRI Solve Triangular Sylvester Equations.
%   X = SYLVESTER_TRI(A,B,C) solves the Sylvester equation A*X + X*B = C,
%   where A is a m-by-m matrix, B is a n-by-n matrix, and X and C are
%   m-by-n matrices. 
%   
%   If A, B and C are real, A and B must be upper quasi-triangular. 
%   Otherwise, A and B must be upper triangular. SYLVESTER_TRI assumes
%   these properties and does not perform check.

%   Copyright 2015 The MathWorks, Inc.

[X, info] = builtin('_sylvester_tri',A,B,C);
