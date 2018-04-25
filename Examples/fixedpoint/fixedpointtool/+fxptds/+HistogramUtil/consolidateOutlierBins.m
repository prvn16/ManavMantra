function consolidatedBins = consolidateOutlierBins(binsToConsolidate)
%% CONSOLIDATEOUTLIERBINS function trims the bins which are outside [-128 127] 
% and consolidates bins to -128 and 127 respectively

%   Copyright 2016 The MathWorks, Inc.

    consolidatedBins = binsToConsolidate;
    
    % Find bins > 127
    largeBinIndices = find(binsToConsolidate > 127);
    if ~isempty(largeBinIndices)
        
        % If binsToConsolidate donot already have 127
        if isempty(find(consolidatedBins == 127, 1))
            % Add 127 to consolidated bins
            consolidatedBins(end+1) = 127;
        end
    end
    
    % Find bins < -128
    smallBinIndices = find(binsToConsolidate < -128);
    if ~isempty(smallBinIndices)
        
        % If binsToConsolidate donot already have -128
        if isempty(find(consolidatedBins == -128, 1))
            
            % Add -128 to consolidated bins
            consolidatedBins(end+1) = -128;
        end
    end
    
    % collect trimmeable outlier bins
    toTrimBins = [largeBinIndices; smallBinIndices];

    % trim bin data
    consolidatedBins(toTrimBins) = [];
end