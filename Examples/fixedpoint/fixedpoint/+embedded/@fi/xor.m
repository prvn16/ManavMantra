function t = xor(A,B)
%XOR Logical EXCLUSIVE OR
%   Refer to the MATLAB XOR reference page for more information.
%
%   See also XOR 

%   Copyright 2004-2015 The MathWorks, Inc.

narginchk(2,2)

t = xor(A~=0, B~=0);
