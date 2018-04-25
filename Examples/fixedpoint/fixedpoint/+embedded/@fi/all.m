function t = all(A,dim)
%ALL    Determine whether all elements of a vector are nonzero
%   Refer to the MATLAB ALL reference page for more information. 
%
%   See also ALL

%   Copyright 1999-2012 The MathWorks, Inc.

if nargin<2
  dim = [];
end

if isempty(dim)
  t = all(A~=0);
else
  t = all(A~=0, double(dim));
end
