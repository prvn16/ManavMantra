function HistogramData = getHistogramData(histogramArray)
% GETHISTOGRAMDATA converts an [256 x 1 ] each array of positive values and negative
% histogram values to a [n x 3] dynamic histogram bin array
% where 
% (:,1) = Bins
% (:,2) = NumberOfPositiveValues 
% (:,3) = NumberOfNegative Values

% Copyright 2016-2017 The MathWorks, Inc.
   HistogramData = struct('BinData', int32([]), 'numZeros', 0);
   if isempty(histogramArray) || size(histogramArray, 2) ~= 2 || size(histogramArray, 1)~=256
       return;
   end
   % histogramArray is expected to be a (256,2)  array of histgoram bin
   % values where the the first column denotes positive values logged and
   % second values contains bin values of negative values found.
   % histogram bins are calculated by ceil(log2(abs(value))). Hence, bins
   % are logged for both positive and negative data.
   positiveIndices = find(histogramArray(:,1) ~= 0);
   negativeIndices = find(histogramArray(:,2) ~= 0);
   % Bins contain the bin indices where either positive or negative values
   % are binned.
   Bins = unique([positiveIndices; negativeIndices]);
   if ~isempty(Bins)

    % histogram table needs three columns, bin numbers, the number of
    % positive values that were instrumented in a given bin and number of
    % negative values that were instrumented in a given bin
    % By fetching, Bins (non zero bin indices) from HistogramArray, we get
    % PositiveValues and NegativeValues column

    NumberOfPositiveValues = histogramArray(Bins, 1);
    NumberOfNegativeValues = histogramArray(Bins, 2);

    % BIn Indices in the array are in the range 0-256, While the histogram
    % actual bins are in the range -128:127. Offset bin indices found by
    % -128.
    Bins = Bins - 129;

    % Compute table object out of bins, positive values and negative values
    % collected.
    BinData = [Bins, NumberOfPositiveValues, NumberOfNegativeValues];
    HistogramData.BinData = int32(BinData);
   end
end