function tbl = countEachLabel(imds)
%COUNTEACHLABEL Count the number of times each unique label occurs.
%   TBL = COUNTEACHLABEL(IMDS) counts the number of times each unique labels
%   occurs in the ImageDatastore. In other words, it counts the number of
%   files with each unique label. The output TBL is a table with variable
%   names Label and Count.
%
%   Example:
%   --------
%      folders = fullfile(matlabroot,'toolbox','matlab',{'demos','imagesci'});
%      exts = {'.jpg','.png','.tif'};
%      imds = imageDatastore(folders,'LabelSource','foldernames','FileExtensions',exts)
%      tbl = countEachLabel(imds)
%
%   See also imageDatastore, splitEachLabel, shuffle, hasdata, readimage,
%   readall, preview, reset.

%   Copyright 2015 The MathWorks, Inc.
try
    if isempty(imds.Labels)
        tbl = table;
        return;
    end
    [u, c] = groupAndCountLabels(imds);
    tbl = table(u, c, 'VariableNames', {'Label', 'Count'});
catch e
    throw(e)
end
end
