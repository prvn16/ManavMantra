function overflowBins = getOverflowBins(dtContainerInfo, histogramBins, range)
%% GETOVERFLOWBINS function uses SimulinkFixedPoint.DTContainerInfo and a list of histogramBins to identify 
% if the given set of histogram bins are overflowing in the container type
% represented by DTContainerInfo. It further checks if the represented
% SimMin and SimMax is within representable range of container 
%
% dtContainerInfo - an instance of SimulinkFixedPoint.DTContainerInfo
% histogramBins - an array of int32 numbers representing the bins used in
% the histogram representation of certain simulation data
% range - fxptds.Range object containing the min and max extrema values 

%   Copyright 2016-2017 The MathWorks, Inc.

    overflowBins = [];
    % validate DTContainerInfo as
    if isempty(dtContainerInfo) || ~isa(dtContainerInfo,'SimulinkFixedPoint.DataTypeContainer.SpecifiedDataTypeContainer')
        return;
    end
    
    % validate histogramBins
    if isempty(histogramBins) || ~isnumeric(histogramBins) 
       return;
    end
    
    % get max abs range bin given the dtContainerInfo
    maxAbsRangeBin = fxptds.HistogramUtil.getMaxAbsRangeBin(dtContainerInfo);
    
    if ~isempty(maxAbsRangeBin)
        % Figure out if any of the bins in histogramBins are beyond the max
        % representable bin
        overflowBins = histogramBins(histogramBins > maxAbsRangeBin);
        if isempty(overflowBins) 
            if (~isempty(range.maxExtremum) && dtContainerInfo.max < range.maxExtremum )
                overflowBins = fxptds.HistogramUtil.computeHistogramBin(range.maxExtremum);
             elseif (~isempty(range.minExtremum) && dtContainerInfo.min > range.minExtremum)
                overflowBins = fxptds.HistogramUtil.computeHistogramBin(range.minExtremum);
            end
        end
    end
end
