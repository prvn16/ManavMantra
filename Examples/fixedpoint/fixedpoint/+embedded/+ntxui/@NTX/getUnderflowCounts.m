function bcnt = getUnderflowCounts(ntx)
% Return histogram of underflow counts
% (only those data items that contribute to underflow)

%   Copyright 2010 The MathWorks, Inc.

% Sum the bins starting from the "bottom" (low index),
% which represent bins with smallest bin centers.
% Create vector with underflow-only opportunities
% Range:
%    [0.5,inf) -> only count pos values, since neg values are
%                 always overflow in these bins
%    (0,0.5) -> pos values are always underflow
%               neg values depend on SmallNegAreOverflow
%               ~AreOverflow->count small negs in underflow
%               AreOverflow->don't count small negs
% Start with .PosBinCounts, which handles (0.5,inf) properly,
% and is correct for (0,0.5) if .SmallNegAreOverflow=true
% (that is, the condition where we don't count negs)
bcnt = ntx.BinCounts;

% Remove negative counts that are overflow in range [0.5,inf)
% This is only done for unsigned data
if ~ntx.IsSigned && (ntx.DataNegCnt > 0)
    % NOTE: BinCenters has exponents, not values,
    %   so -1 means 2^-1 which is 0.5.  For the
    %   negative numbers considered here, this means negative
    %   values with magnitude < 0.5.
    negVals = ntx.NegBinCounts;
    if ntx.SmallNegAreOverflow
        bcnt = bcnt - negVals;
    else
        negVals(ntx.BinEdges < -1) = 0;
        bcnt = bcnt - negVals;
    end
end
