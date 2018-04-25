function edges = scottsrule(stdX, numelX, minX, maxX, limits)
;%#ok<NOSEM> Undocumented

% Implementation copied from toolbox/matlab/datafun/histcounts.m
% refactored to support tall arrays

%   Copyright 2016 The MathWorks, Inc.

% Scott's normal reference rule

binwidth = 3.5*stdX/(numelX^(1/3));

if isempty(limits)
    edges = matlab.internal.math.binpicker(minX, maxX,[], binwidth);
else
    edges = matlab.internal.math.binpickerbl(minX, maxX, limits(1), limits(2), binwidth);
end
end
