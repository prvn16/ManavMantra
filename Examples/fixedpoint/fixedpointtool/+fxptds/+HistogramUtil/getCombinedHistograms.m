function histogramBinData = getCombinedHistograms(histogramBinData)
%% GETCOMBINEDHISTOGRAMS function combines positive and negative counts of histogram bin data

%   Copyright 2016 The MathWorks, Inc.

    [~, numCols] = size(histogramBinData);
    
    if (numCols == 3)
        % combine second and third columns indicating positive bin counts
        % and negative bin counts.
        histogramBinData(:,4) = histogramBinData(:,2) + histogramBinData(:,3);
    end
end