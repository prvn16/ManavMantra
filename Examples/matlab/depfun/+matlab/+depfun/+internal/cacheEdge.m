function tf = cacheEdge(src, tgt, addKey)
% cacheEdge caches edges in the graph (higher performance)
%
% w = cacheEdge(edgeVector, addKey)
%
%   cacheEdge()
%     Clear the cache (by creating a new, empty one).

persistent edgeCache

if nargin == 0
    edgeCache = containers.Map('KeyType', 'char', 'ValueType', 'any');
else
    edgePair = [num2str(src) '_' num2str(tgt)];
    if addKey == false
        if isKey(edgeCache, edgePair)
            tf = true;
        else
            tf = false;
        end
    else
        edgeCache(edgePair) = true;
        tf = true;
    end
end