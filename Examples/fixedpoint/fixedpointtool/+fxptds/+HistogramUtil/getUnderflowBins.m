function underflowBins = getUnderflowBins(dtContainerInfo, histogramBins, range)
%% GETUNDERFLOWBINS function gets the list of bins which have simulation values that underflow if represented by dtContainerInfo
% given that simMin is the minimum observed simulation value. 
%
% dtContainerInfo - an instance of SimulinkFixedPoint.DTContainerInfo
% histogramBins - an array of int32 bins representing the histogram bins of
% simulation values of a given signal
% simMin - double representing the minimum simulation value of a given
% signal

%   Copyright 2016-2017 The MathWorks, Inc.

    underflowBins = [];
    
    % validate DTContainerInfo 
    if isempty(dtContainerInfo) || ~isprop(dtContainerInfo, 'evaluatedNumericType') ||  isempty(dtContainerInfo.evaluatedNumericType) ||  isdouble(dtContainerInfo.evaluatedNumericType)
        return;
    end
    
    % validate histogramBins
    if isempty(histogramBins) || ~isnumeric(histogramBins) 
       return;
    end
    
    % get EpsBin from dtContainerInfo
    epsBin = fxptds.HistogramUtil.getEpsBin(dtContainerInfo);
    
    if ~isempty(epsBin)
        % find all bins which are less than eps bin - indicating that those
        % values will underflow 
        underflowBins = histogramBins(histogramBins < epsBin);
        if isempty(underflowBins)
            if (~isempty(range.minExtremum) && range.minExtremum ~= 0 && abs(range.minExtremum) < dtContainerInfo.getEps)
                underflowBins = fxptds.HistogramUtil.computeHistogramBin(range.minExtremum);
            elseif (~isempty(range.maxExtremum) && range.maxExtremum ~= 0 && abs(range.maxExtremum) < dtContainerInfo.getEps)
                underflowBins = fxptds.HistogramUtil.computeHistogramBin(range.maxExtremum);
            end
        end
    end
end