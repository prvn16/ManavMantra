function datasets = getAllDatasets(h)
%GETDATASET Get the dataset.

%   Copyright 2007 The MathWorks, Inc.

blkDgms = h.getBlkDgmNodes;
datasets = {};

for idx = 1:length(blkDgms)
    curBlkDgm = blkDgms(idx); 
    appdata = SimulinkFixedPoint.getApplicationData(curBlkDgm.getDAObject.getFullName);
    datasets{end+1} = appdata.dataset; %#ok<AGROW>
    if appdata.subDatasetMap.Count > 0
        submdlDS = appdata.subDatasetMap.values;
        datasets = {datasets{:}, submdlDS{:}};  %#ok<CCAT>
    end
end


% [EOF]