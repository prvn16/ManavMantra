function idx = findFigureIndexInCollection(hFig, ROICollection)
% findFigureIndexInCollection - Find specified figure in collection.
% Utility function for Color Thresholder app

% Copyright 2016 The MathWorks, Inc.    

figuresWithROIs = [ROICollection{:,1}];
idx = find(figuresWithROIs == hFig, 1);
end