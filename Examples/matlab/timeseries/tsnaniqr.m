function y = iqr(x,dim)
%
% tstool utility function

%   Copyright 2005-2006 The MathWorks, Inc.

if nargin == 1
    y = diff(tsprctile(x, [25; 75]));
else
    y = diff(tsprctile(x, [25; 75],dim),[],dim);
end
