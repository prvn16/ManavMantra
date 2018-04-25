function [cnt,pct] = getTotalOverflows(ntx)
% Add up the bins that are beyond the integer threshold setting.
% This indicates the number of data values that will not be representable
% in the word size, if this number of integer bits is chosen.
% This implies these values will overflow the data type.

%   Copyright 2010 The MathWorks, Inc.

x = ntx.BinEdges;  % holds exponents (N) -- not values (2^N)

% Count all values (pos and neg) with "large" magnitude
if ntx.IsSigned
    cnt = sum(ntx.BinCounts(x > ntx.LastOver)) + sum(ntx.PosBinCounts(x == ntx.LastOver)); 
else
    cnt = sum(ntx.BinCounts(x > ntx.LastOver)); % compare exponents
end

% If unsigned format, add some negative values to the overflow count
%   - some negatives are already counted in overflow
%     (ie, those negative values that have large magnitude)
%     no need to do anything more for those -- just be careful not to
%     double-count these values
%
%   - some negatives shouldn't be counted as overflow
%     if .SmallNegAreOverflow=false, then small neg are left as underflow
%      (this is set to false when, say, round to zero is selected,
%       in which case small negatives are simply zero and NOT overflow)
%
%   - if small negatives SHOULD be counted, we do that (carefully) here
if ~ntx.IsSigned && (ntx.DataNegCnt > 0)  % unsigned and neg values present
    if ntx.SmallNegAreOverflow 
        % Count negatives in the "normal" and "underflow" regions
        % (everywhere, really, but don't double-count negs in overflow
        % region)
        negSelect = (x < ntx.LastOver);
    else
        % Count negatives from lastOver to the 2^-1 bin.
        % note that x (bincenters) are exponents, not "2^N" values.
        negSelect = (x <= ntx.LastOver) & (x >= 0);
    end
    cnt = cnt + sum(ntx.NegBinCounts(negSelect));
end
if isempty(cnt)
    cnt = 0;
end
if ntx.DataCount == 0
    pct = 0;
else
    pct = 100*cnt/ntx.DataCount;
end
