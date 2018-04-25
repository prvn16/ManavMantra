function HistogramData = getHistogramFromTimeseriesData(result)
% GETHISTOGRAMFROMTIMESERIESDATA converts an array of timeseries data from SDI for
% results with signal logging on and converts them to HistogramData 
% ~~ struct('BinData', [nx 3] array, 'numZeros', int)
% and updates HistogramData field of the result
    
% Copyright 2016-2017 The MathWorks, Inc.
    HistogramData = struct('BinData', int32([]), 'numZeros', 0);
    rawData = result.getTimeseriesData();
    
    % find bin indices where positive values were logged 
    posIdces = find(rawData > 0);
    posData = rawData(posIdces);%#ok
    posBins = fxptds.HistogramUtil.computeHistogramBin(posData);
    
    % find bin indices where negative values were logged 
    negIdces = find(rawData < 0);
    negData = rawData(negIdces);%#ok
    negBins = fxptds.HistogramUtil.computeHistogramBin(negData);
    
    if ~isempty(posBins) || ~isempty(negBins)
        % create unique bins 
        Bins = unique([posBins; negBins]);
        
        % collect number of positive values logged per bin using histc
        % function
        NumberOfPositiveValues = histc(posBins, Bins);
        
        % collect the number of negative values logged per bin using histc
        % function
        NumberOfNegativeValues = histc(negBins, Bins);

        if isempty(NumberOfPositiveValues)
            NumberOfPositiveValues = zeros(numel(Bins), 1);
        end
        % columnize vector which holds on the number of positive values per
        % bin
        NumberOfPositiveValues = getColumnVector(NumberOfPositiveValues);
        
        if isempty(NumberOfNegativeValues)
            NumberOfNegativeValues = zeros(numel(Bins), 1);
        end
        % columnize vector which holds on the number of negative values per
        % bin
        NumberOfNegativeValues = getColumnVector(NumberOfNegativeValues);
        
        % columnize vector which holds on the bin information
        Bins = getColumnVector(Bins);
        
        % create an n x 3 matrix as BinData
        HistogramData.BinData = int32([Bins, NumberOfPositiveValues, NumberOfNegativeValues]);    
    end
    % update number of zeros field in HistogramData. 
    HistogramData.numZeros = numel(find(rawData == 0));
end
function colVector = getColumnVector(inputVector)
% Given an input vector, this function reshapes it to a column vector
    colVector = reshape(inputVector, numel(inputVector), 1);
end
