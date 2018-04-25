function t = and(A,B)
%&      Logical AND
%   Refer to the MATLAB AND reference page for more information.
% 
%   See also AND

%   Copyright 2004-2015 The MathWorks, Inc.

narginchk(2,2)

t = (A~=0) & (B~=0);
