function hROIs = findROIs(hFig, ROICollection)
% findROIs - Get handles to ROIs in specified figure.
% Utility function for Color Thresholder app

% Copyright 2016 The MathWorks, Inc.  

idx = iptui.internal.findFigureIndexInCollection(hFig, ROICollection);
if isempty(idx)
    hROIs = [];
else
    hROIs = ROICollection{idx,2};
    hROIs = hROIs(isvalid(hROIs));
end

end