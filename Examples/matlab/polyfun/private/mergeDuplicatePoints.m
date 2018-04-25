function [X, dupesfound, idxmap] = mergeDuplicatePoints(X)
%MergeDuplicatePoints Merge out points that have coincident location.

%   Copyright 2009 The MathWorks, Inc.

dupesfound = false;
numinitpoints = size(X, 1);
[~,idxmap] = unique(X,'first','rows');
numuniquepoints = length(idxmap);
if (numinitpoints > numuniquepoints)
    % Undo the sort to preserve the ordering of points
    idxmap = sort(idxmap)';
    X = X(idxmap,:);    
    dupesfound = true;
end