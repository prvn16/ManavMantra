function edges = numbinsrule(N, minX, maxX, limits)
;%#ok<NOSEM> Undocumented

% Implementation extracted from toolbox/matlab/datafun/histcounts.m
% refactored to support tall arrays

%   Copyright 2016 The MathWorks, Inc.

if isempty(limits)
    xrange = maxX - minX;
    edges = matlab.internal.math.binpicker(minX, maxX, N, xrange/N);
else
    low = limits(1);
    high = limits(2);
    edges = [low+(0:N-1).*((high-low)/N), high];
end

end