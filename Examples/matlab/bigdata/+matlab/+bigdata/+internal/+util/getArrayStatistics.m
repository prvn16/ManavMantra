function lazyStats = getArrayStatistics(X)
% Compute descriptive statistics for tall X, omitting nan and +/-inf

%   Copyright 2016 The MathWorks, Inc.

lazyStats = [];
fX = X(isfinite(X));
lazyStats.max = max(fX, [], 'omitnan');
lazyStats.min = min(fX, [], 'omitnan');
lazyStats.numel = numel(fX);
lazyStats.std = std(fX, 'omitnan');
end
