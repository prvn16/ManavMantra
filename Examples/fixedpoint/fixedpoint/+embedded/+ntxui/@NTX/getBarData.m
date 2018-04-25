function [posVal,negVal] = getBarData(ntx)
% Scale the bin counts for display

%   Copyright 2010 The MathWorks, Inc.

if ntx.HistVerticalUnits == 1
    % Convert from raw bin counts to a percentage, in range [0,100]
    sTot = ntx.DataCount;
    if sTot==0
        % Don't normalize - that will cause a divide-by-zero
        % For percent display, we show all-zero when there's no data
        posVal = 0;
        negVal = 0;
    else
        posVal = (100/sTot).*ntx.PosBinCounts;
        negVal = (100/sTot).*ntx.NegBinCounts;
    end
else
    % Display bin count
    posVal = ntx.PosBinCounts;
    negVal = ntx.NegBinCounts;
end
