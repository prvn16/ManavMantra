function edges = maxnumbinsrule(preferIntRule, minX, maxX, stdX, numelX, limits, maxNumBins)
;%#ok<NOSEM> Undocumented

%   Copyright 2016 The MathWorks, Inc.

% Try the autorule first
import matlab.bigdata.internal.binmethods.autorule
import matlab.bigdata.internal.binmethods.numbinsrule

edges = autorule(preferIntRule, minX, maxX, stdX, numelX, limits, maxNumBins);

if numel(edges)-1 > maxNumBins
    % autorule created too many bins - use the numbinsrule with N = maxNumBins
    edges = numbinsrule(maxNumBins, minX, maxX, limits);
end
end