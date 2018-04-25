function sortDim = findSortDimension(allPatientPositions)
% Copyright 2017 The MathWorks, Inc.

if isempty(allPatientPositions)
    sortDim = 1;
else
    displacementWithinDimension = abs(diff(allPatientPositions, 1, 1));
    averageDisplacementWithinDimension = mean(displacementWithinDimension, 1);
    [~, sortIndices] = sort(averageDisplacementWithinDimension, 2, 'descend');
    sortDim = sortIndices(1);
end

end
