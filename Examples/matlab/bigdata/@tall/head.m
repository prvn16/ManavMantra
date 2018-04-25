function out = head(in, k)
%HEAD  Get first few rows of tall array.
%   TY = HEAD(TX) returns the first few rows of tall array TX. The result
%   is an unevaluated tall array TY.
%
%   TY = HEAD(TX,K) returns up to K rows from the beginning of tall array
%   TX. If TX contains fewer than K rows, then the entire array is
%   returned.
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
%      % Extract the first 10 rows of the variable ArrDelay. 
%      f10 = head(tt.ArrDelay,10)
%
%      % Collect the results into memory.
%      first10 = gather(f10)
%
%   See also: TALL, TALL/TAIL, TALL/GATHER, TALL/TOPKROWS.

% Copyright 2016-2017 The MathWorks, Inc.

if nargin<2
    k = matlab.bigdata.internal.util.defaultHeadTailRows();
else
    % Check that k is a non-negative integer-valued scalar
    validateattributes(k, ...
        {'numeric'}, {'real','scalar','nonnegative','integer'}, ...
        'head', 'k')
end

outPA = matlab.bigdata.internal.lazyeval.extractHead(in.ValueImpl, k);
outAdapt = resetTallSize(in.Adaptor);

out = tall(outPA, outAdapt);

% Try to cache the result so that we don't have to revisit the original
% data again in future.
out = markforreuse(out);

end
