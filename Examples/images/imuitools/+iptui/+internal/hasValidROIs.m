function TF = hasValidROIs(hFig, ROICollection)
% hasValidROIs - Does specified figure have any ROIs?
% Utility function for Color Thresholder app

%   Copyright 2016 The MathWorks, Inc.    

TF = false;
if isempty(ROICollection)
    return
end
idx = iptui.internal.findFigureIndexInCollection(hFig,ROICollection);
if isempty(idx)
    return
end
hROIs = ROICollection{idx,2};
TF = any(isvalid(hROIs));

end

