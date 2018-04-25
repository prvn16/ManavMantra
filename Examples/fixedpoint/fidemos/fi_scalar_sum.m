function Y = fi_scalar_sum(U,V)
% Add U and V.
% Copyright 2008-2010 The MathWorks, Inc.
%#codegen
Y = fi(0, numerictype(U), fimath(U));
Y(1) = U + V;
