function edges = sqrtrule(numelx, minx, maxx, limits)
;%#ok<NOSEM> Undocumented

% Implementation copied from toolbox/matlab/datafun/histcounts.m
% refactored to support tall arrays

%   Copyright 2016 The MathWorks, Inc.

nbins = max(ceil(sqrt(numelx)),1);

if isempty(limits)
    binwidth = (maxx-minx)/nbins;
    edges = matlab.internal.math.binpicker(minx,maxx,[],binwidth);
else
    % limits?
    edges = linspace(limits(1), limits(2),nbins+1);
end
end