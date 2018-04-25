function histogramBinData = addOutlierBinDataToBoundaryBin(histogramBinData, boundaryBinToAdd, outlierBinsToConsolidate)
%% ADDOUTLIERBINDATATOBOUNDARYBIN function consilidates histogram data from outlier bins and adds 
% data to boundary bins -128 or 127th bin (as indicated by binToAdd). 

%   Copyright 2016 The MathWorks, Inc.

    % histogramBins 
    histogramBins = histogramBinData(:,1);
    
    % Collect data values from outlier bins
    outlierBinData = sum(histogramBinData(outlierBinsToConsolidate,:), 1);
    
    % Check if the bin to be added already exists
    binToAddIndex = find(histogramBins == boundaryBinToAdd, 1); 
    
    % Otherwise, add to the end of histogram bin data
    if isempty(binToAddIndex)
        binToAddIndex = size(histogramBinData, 1) + 1;
        histogramBinData(binToAddIndex, :) = [ boundaryBinToAdd 0 0];
    end
    histogramBinData(binToAddIndex, 2:3) = int32(histogramBinData(binToAddIndex, 2:3)) + int32(outlierBinData(1, 2:3));    
end