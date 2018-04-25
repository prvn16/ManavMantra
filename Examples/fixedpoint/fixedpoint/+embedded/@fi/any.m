function t = any(A,dim)
%ANY    True if any element of a vector is nonzero
%   Refer to the MATLAB ANY reference page for more information. 
%
%   See also ANY

%   Copyright 1999-2012 The MathWorks, Inc.

if nargin<2
  dim = [];
end

if isempty(dim)
  t = any(A~=0);
else
  t = any(A~=0, double(dim));
end
