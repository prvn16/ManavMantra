function out = tail(in, k)
%TAIL  Get last few rows of tall array.
%   TY = TAIL(TX) returns the last few rows of tall array TX. The result is
%   an unevaluated tall array TY.
%
%   TY = TAIL(TX, K) returns up to K rows from the end of tall array TX. If
%   TX contains fewer than K rows, then the entire array is returned.
%
%   Example:
%      % Create a datastore.
%      varnames = {'ArrDelay', 'DepDelay', 'Origin', 'Dest'};
%      ds = datastore('airlinesmall.csv', 'TreatAsMissing', 'NA', ...
%            'SelectedVariableNames', varnames)
%
%      % Create a tall table from the datastore.
%      tt = tall(ds);
%
%      % Extract the last 10 rows of the variable ArrDelay. 
%      l10 = tail(tt.ArrDelay,10)
%
%      % Collect the results into memory.
%      last10 = gather(l10)
%
%   See also: TALL, TALL/HEAD, TALL/GATHER, TALL/TOPKROWS.

% Copyright 2016-2017 The MathWorks, Inc.


if nargin<2
    k = matlab.bigdata.internal.util.defaultHeadTailRows();
else
    % Check that k is a non-negative integer-valued scalar
    validateattributes(k, ...
        {'numeric'}, {'real','scalar','nonnegative','integer'}, ...
        'tail', 'k')
end

outPA = matlab.bigdata.internal.lazyeval.extractTail(in.ValueImpl, k);
outAdapt = resetTallSize(in.Adaptor);

out = tall(outPA, outAdapt);

% Try to cache the result so that we don't have to revisit the original
% data again in future.
out = markforreuse(out);

end

