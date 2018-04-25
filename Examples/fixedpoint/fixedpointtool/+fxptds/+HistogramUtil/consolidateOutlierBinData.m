function histogramBinData = consolidateOutlierBinData(histogramBinData)
%% CONSOLIDATEOUTLIERBINDATA function trims histogram bin data to restrict bins within
% -128 to 127. All bins outside of this boundary will be trimmed out.

%   Copyright 2016 The MathWorks, Inc.

    % get histogram bins
    histogramBins = histogramBinData(:,1);
    
    % Trim bins less tha -128 and greater than 127
    largeBinIndices = find(histogramBins > 127);
    if ~isempty(largeBinIndices)
        histogramBinData = fxptds.HistogramUtil.addOutlierBinDataToBoundaryBin(histogramBinData, 127, largeBinIndices);
    end
    
    smallBinIndices = find(histogramBins < -128);
    if ~isempty(smallBinIndices)
        histogramBinData = fxptds.HistogramUtil.addOutlierBinDataToBoundaryBin(histogramBinData, -128, smallBinIndices);
    end
    
    % collect trimmeable outlier bins
    toTrimBins = [largeBinIndices; smallBinIndices];

    % trim bin data
    histogramBinData(toTrimBins, :) = [];
end
