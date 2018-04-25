function t = isnan(A)
%ISNAN  True for Not-a-Number
%   Refer to the MATLAB ISNAN reference page for more information 
%
%   See also ISNAN

%   Copyright 2004-2012 The MathWorks, Inc.

% fixed-point or boolean fis can never contain NaN
if isfixed(A) || isboolean(A)
    t = false(size(A));
else
    t = isnan(double(A));
end

% LocalWords:  fis
