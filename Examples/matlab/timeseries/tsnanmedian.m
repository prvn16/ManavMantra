function y = tsnanmedian(x,dim)
%
% tstool utility function

%   Copyright 2005-2006 The MathWorks, Inc.

if nargin == 1
    y = tsprctile(x, 50);
else
    y = tsprctile(x, 50, dim);
end
