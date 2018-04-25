function t = isinf(A)
%ISINF  True for infinite elements
%   Refer to the MATLAB ISINF reference page for more information 
%
%   See also ISINF

%   Copyright 2004-2012 The MathWorks, Inc.

% fixed-point and boolean fis can never contain inf.
if isfixed(A) || isboolean(A)
    t = false(size(A));
else
    t = isinf(double(A));
end

% LocalWords:  fis
