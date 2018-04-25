function modelLevelSettings = readFPTDataFromPartFile(xmlFileName)
% READFPTDATAFROMXMLFILE Reads the preferences data stored in the FPT parts
% file in the model SLX file

% Copyright 2014 The MathWorks, Inc

if ~isequal(exist(xmlFileName, 'file'),2);
    modelLevelSettings = struct([]);
    return;
end
xmlDocument = xmlread(xmlFileName);
allSettingItems = xmlDocument.getElementsByTagName('FPTSettings');
% The first child is the FPT settings block
fptSettings = allSettingItems.item(0);
%Note that the item list index is zero-based.
for i=0:fptSettings.getLength-1
    thisSetting = fptSettings.item(i);
    propName = reshape(thisSetting.getNodeName.toCharArray,1,[]);
    % Each property tag has only one child.
    child = thisSetting.getFirstChild;
    if isempty(child)
        continue;
    else
        modelLevelSettings.(propName) = reshape(child.getData.toCharArray,1,[]);
    end
end
end
