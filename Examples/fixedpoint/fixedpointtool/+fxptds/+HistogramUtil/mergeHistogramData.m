function mergedHistogramData = mergeHistogramData(oldHistogramData, newHistogramData)
%% MERGEHISTOGRAMDATA merges two histogram logging datastructures
% Each logging datastructure is expected to be a struct of the following
% fields
%
% BinData - an [n x 3] integer array 
% where 
% (:,1) = Bins
% (:,2) = NumberOfPositiveValues 
% (:,3) = NumberOfNegative Values

% numZeros - number of zeros found while logging histogram data

%   Copyright 2016 The MathWorks, Inc.

mergedHistogramData = struct('BinData', [], 'numZeros', 0);
% verify if both inputs are not empty for merging
if ~isempty(oldHistogramData) && ~isempty(newHistogramData)
    % verify if histogramData objects have "BinData" field
    if isfield(oldHistogramData, 'BinData') && isfield(newHistogramData, 'BinData')
        oldBinData = oldHistogramData.BinData;
        newBinData = newHistogramData.BinData;

        %convert table to n-by-3 array where n = number of histogram bins
        %logged
        oldArray = oldBinData;
        newArray = newBinData;
        
        % HistogramData struct can be nonempty but binData can be empty.
        if ~isempty(oldArray) && ~isempty(newArray)
            % merged the old array and the new array
            mergedArray = mergeArrays(oldArray, newArray);

            %convert the merged array back to table object
            mergedHistogramData.BinData = mergedArray;
        else
            if ~isempty(oldArray)
                mergedHistogramData = oldHistogramData;
            elseif ~isempty(newArray)
                mergedHistogramData = newHistogramData;
            end
        end
    end
    % merge numZeros field
    if isfield(oldHistogramData, 'numZeros') && isfield(newHistogramData, 'numZeros')
        mergedHistogramData.numZeros = oldHistogramData.numZeros + newHistogramData.numZeros;
    end
else
    % return nonempty histogram data object as output
    if ~isempty(oldHistogramData)
        mergedHistogramData = oldHistogramData;
    elseif ~isempty(newHistogramData)
        mergedHistogramData = newHistogramData;
    end
end
mergedHistogramData.BinData = int32(mergedHistogramData.BinData);
end
function c = mergeArrays(a, b)
    assert(ismatrix(a) && ismatrix(b) && size(a,2)==size(b,2),...
        'The inputs must be matrices with the same number of columns');

    % The first column is the index.
    a1 = a(:,1);
    b1 = b(:,1);

    % Create the first column of the merged array from the first columns of
    % the inputs.
    c1 = union(a1,b1);
    c1 = reshape(c1, [numel(c1), 1]);

    % Initialize the output array such that the first column is merged and
    % the remaining columns are zeros.
    c = [c1,zeros(size(c1,1),size(a,2)-1)];

    % Find the indices where the output and inputs intersect.
    [~,ica,ia] = intersect(c1,a1);
    [~,icb,ib] = intersect(c1,b1);

    % Assign the first array into the output.
    c(ica,2:end) = a(ia,2:end);

    % Sum the second array into the output.
    c(icb,2:end) = c(icb,2:end)+b(ib,2:end);
end
