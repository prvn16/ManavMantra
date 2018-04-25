function t = or(A,B)
%OR     Logical OR
%   Refer to the MATLAB OR reference page for more details.
%
%   See also OR

%   Copyright 2004-2015 The MathWorks, Inc.

narginchk(2,2)

t = (A~=0) | (B~=0);
