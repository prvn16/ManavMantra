function edges = binwidthrule(binWidth, xMin, xMax, limits, numBinsMax)
;%#ok<NOSEM> Undocumented

% Implementation copied from toolbox/matlab/datafun/histcounts.m
% refactored to support tall arrays

%   Copyright 2016 The MathWorks, Inc.

if isempty(limits)
    xrange = xMax - xMin;
    
    if isempty(xMin)
        edges = cast([0 binWidth], 'like', xrange);
        return;
    end
    
    leftEdge = binWidth*floor(xMin/binWidth);
    nbins = max(1,ceil((xMax-leftEdge) ./ binWidth));
    
    % Do not create more than maximum bins.
    if nbins > numBinsMax  % maximum exceeded, recompute
        % Try setting bin width to xrange/(MaximumBins-1).
        % In cases where minx is exactly a multiple of
        % xrange/MaximumBins, then we can set bin width to
        % xrange/MaximumBins-1 instead.
        nbins = numBinsMax;
        binWidth = xrange/(numBinsMax-1);
        leftEdge = binWidth*floor(xMin/binWidth);
        
        if xMax <= leftEdge + (nbins-1) * binWidth
            binWidth = xrange/numBinsMax;
            leftEdge = xMin;
        end
    end
    edges = leftEdge + (0:nbins) .* binWidth; % get exact multiples
    
else
    % apply BinLimits 
    low = limits(1);
    high = limits(2);
    binWidth = max(binWidth, (high-low)/numBinsMax);
    edges = low:binWidth:high;
    
    if edges(end) < high|| isscalar(edges)
        edges = [edges high];
    end
end

end