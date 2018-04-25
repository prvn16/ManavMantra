function edges = autorule(preferIntRule, minX, maxX, stdX, numelX, limits, numBinsMax)
;%#ok<NOSEM> Undocumented

% Implementation copied from toolbox/matlab/datafun/histcounts.m
% refactored to support tall arrays

%   Copyright 2016 The MathWorks, Inc.

import matlab.bigdata.internal.binmethods.integersrule;
import matlab.bigdata.internal.binmethods.scottsrule;

xrange = maxX - minX;

if ~isempty([minX, maxX]) && preferIntRule...
        && xrange <= 50 && maxX <= flintmax(class(maxX))/2 ...
        && minX >= -flintmax(class(minX))/2
    edges = integersrule(minX, maxX, limits, numBinsMax);
else
    edges = scottsrule(stdX, numelX, minX, maxX, limits);
end
end