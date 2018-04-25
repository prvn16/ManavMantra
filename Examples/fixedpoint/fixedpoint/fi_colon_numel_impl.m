% This function is executed as extrinsic by MATLAB Coder to figure out the number 
% of elements for a fixed-point colon operator A:B:C.
function [n] = fi_colon_type_impl(A,B,C)

%   Copyright 2013 The MathWorks, Inc.

  n = numel(colon(A,B,C));
end