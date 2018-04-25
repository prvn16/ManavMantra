function clearAllMemoizedCaches
% CLEARALLMEMOIZEDCACHES clears caches for currently memoized functions.
% See Also:
% MEMOIZE, MATLAB.LANG.MEMOIZEDFUNCTION

% Copyright 2016 The MathWorks, Inc.

memoizer = matlab.lang.internal.Memoizer.getInstance();
% clear caches for everything that has previously been memoized.
memoizer.clearCacheAll();



