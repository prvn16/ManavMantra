function updateVisualFromHistogramLoggingData(ntx, ntxStruct)
% Update stored histogram with new data from Code Generation Report.

%   Copyright 2012 The MathWorks, Inc.

% The input ntxStruct must be in the below listed format
numberOfHistogramBins   = ntxStruct.NumberOfHistogramBins;
idxNonZeroHistValuesPos = ntxStruct.IdxNonZeroHistValuesPos;
nonZeroHistValuesPos    = ntxStruct.NonZeroHistValuesPos;
idxNonZeroHistValuesNeg = ntxStruct.IdxNonZeroHistValuesNeg;
nonZeroHistValuesNeg    = ntxStruct.NonZeroHistValuesNeg;
numberOfZeros           = ntxStruct.NumberOfZeros;
numberOfPositiveValues  = ntxStruct.NumberOfPositiveValues;
numberOfNegativeValues  = ntxStruct.NumberOfNegativeValues;
totalNumberOfValues     = ntxStruct.TotalNumberOfValues;
simMin                  = ntxStruct.SimMin;
simMax                  = ntxStruct.SimMax;
simSum                  = ntxStruct.SimSum;
defaultDTWL             = ntxStruct.DefaultDTWL;
defaultDTFL             = ntxStruct.DefaultDTFL;
wl                      = ntxStruct.WL;
fl                      = ntxStruct.FL;
proposedSignednessStr   = ntxStruct.ProposedSignednessStr;
proposedWL              = ntxStruct.ProposedWL;
proposedFL              = ntxStruct.ProposedFL;

if (numberOfPositiveValues + numberOfNegativeValues) ~= 0

    % If the data doesn't have any positive values, fill these variables
    % with dummy (& harmless) values, so that the edge and bin count
    % calculations further below do not error out.
    if (numberOfPositiveValues == 0)
        idxNonZeroHistValuesPos = idxNonZeroHistValuesNeg;
        nonZeroHistValuesPos    = zeros(1,numel(idxNonZeroHistValuesPos));
    end

    % If the data doesn't have any negative values, fill these variables
    % with dummy (& harmless) values, so that the edge and bin count
    % calculations further below do not error out.
    if (numberOfNegativeValues == 0)
        idxNonZeroHistValuesNeg = idxNonZeroHistValuesPos;
        nonZeroHistValuesNeg    = zeros(1, numel(idxNonZeroHistValuesNeg));
    end

    xData = min(idxNonZeroHistValuesPos(1), idxNonZeroHistValuesNeg(1)) : ...
            max(idxNonZeroHistValuesPos(end), idxNonZeroHistValuesNeg(end));
    yData = zeros(numel(xData),2);
    yData(idxNonZeroHistValuesNeg - xData(1) + 1, 1) = nonZeroHistValuesNeg;
    yData(idxNonZeroHistValuesPos - xData(1) + 1, 2) = nonZeroHistValuesPos;
    xData = xData - ((numberOfHistogramBins/2) - 1) -1;

    % The BinEdges and BinCounts have additional values at the ends to match
    % NumericTypeScope algorithm and output.
    ntx.BinEdges     = [xData(1)-1 xData];
    ntx.NegBinCounts = [0 yData(:,1)'];
    ntx.PosBinCounts = [0 yData(:,2)'];
    ntx.BinCounts    = ntx.NegBinCounts + ntx.PosBinCounts;
    ntx.DataPosCnt   = numberOfPositiveValues;
    ntx.DataNegCnt   = numberOfNegativeValues;
end

ntx.DataCount    = totalNumberOfValues;
ntx.DataZeroCnt  = numberOfZeros;
ntx.DataMin      = simMin;
ntx.DataMax      = simMax;
ntx.DataSum      = simSum;

if any(~isempty([wl fl proposedWL proposedFL]))
    % Set wl-fl info on the NTX scope
    % if proposedWL-proposedFL are present, use those as they take 
    % precedence over wl-fl
    dlg = ntx.hBitAllocationDialog;
    actWL = wl;
    actFL = fl;
    if ~isempty(proposedWL)
        actWL = proposedWL;
    end
    if ~isempty(proposedFL)
        actFL = proposedFL;
    end   
    if ~isempty(actWL)
        % Set the Word Length mode to "Specify" and update the word length
        % value.
        setBAWLMethod(dlg, 2);
        setBAWLBits(dlg, actWL);
    end
    if ~isempty(actFL)
        % Set "Specify constraint" to "Fractional bits" and specify the fraction
        % length.
        setBAILFLMethod(dlg, 5); % Fractional bits
        setBAFLBits(dlg, actFL);
    end

elseif ~isempty(defaultDTWL)
    % if neither proposedWL-proposedFL nor wl-fl are present, use default
    % WL-FL if present
    dlg = ntx.hBitAllocationDialog;
    % Set the Word Length mode to "Specify" and update the word length
    % value.
    setBAWLMethod(dlg, 2);
    setBAWLBits(dlg, defaultDTWL);
    if ~isempty(defaultDTFL)
        % Set "Specify constraint" to "Fractional bits" and specify the fraction
        % length.
        setBAILFLMethod(dlg, 5); % Fractional bits
        setBAFLBits(dlg, defaultDTFL);
    end

% else - nothing to be done; let NTX Scope use its default settings
end

if ~isempty(proposedSignednessStr)
    % Set Signedness info on the NTX scope
    dlg = ntx.hBitAllocationDialog;
    switch lower(proposedSignednessStr)
      case 'signed'
        setSignedMode(dlg, 2);
      case 'unsigned'
        setSignedMode(dlg, 3);
    end
end

updateSignedStatus(ntx);
performAutoBA(ntx);
updateVisual(ntx);

% [EOF]
