function map = getChildParentCacheMap(this)
% GETCHILDPARENTCACHEMAP Retuns the mapping between child uniqueIDs and
% parent uniqueIDs for a given top model. 
% The discoverHierarchy needs to be invoked before this API can be called
% for meaningful results.

% Copyright 2017 The MathWorks, Inc.

map = this.ChildParentMap;