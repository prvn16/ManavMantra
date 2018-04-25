function finalSourceList = getLargestCommonRootsFromSourceFolders(foldersList)
% This function is undocumented and may change in a future release.

% Copyright 2017 MathWorks Inc.

uniqueFoldersList = unique(foldersList);
uniqueFoldersList = strip(uniqueFoldersList,'right',filesep);
strMatrix = createStringMatrix(uniqueFoldersList);
finalSourceList = createFinalSourceListFromMatrix(strMatrix);
end
 
function strMatrix = createStringMatrix(uniqueFoldersList)
numOfRows = numel(uniqueFoldersList);
folderPartsList = cell(1,numOfRows);
counts = zeros(1,numOfRows);

for k = 1:numOfRows
    folder = uniqueFoldersList(k);
    folderParts = split(folder,filesep)+filesep;
    folderParts = fixFilesepRoots(folderParts);
    folderPartsList{k} = folderParts;
    counts(k) = numel(folderParts);
end

numOfCols = max(counts)+1; % +1 so that "left to right check" algorithm will stop
strMatrix(numOfRows,numOfCols) = string(missing);
for k=1:numOfRows
    strMatrix(k,1:counts(k)) = folderPartsList{k};
end
end
 
function finalSourceList = createFinalSourceListFromMatrix(strMatrix)
% Find first and last index of each unique root folder
startRows = find([true; strMatrix(2:end,1) ~= strMatrix(1:end-1,1)]);
endRows = [startRows(2:end)-1;size(strMatrix,1)];

count = numel(startRows);
finalSourceList(1,count) = string(missing);

for k=1:count
    startRow = startRows(k);
    endRow = endRows(k);
    
    colIdx = findFirstNonMatchingIndex(strMatrix(startRow,:),strMatrix(endRow,:));
    colIdx = colIdx-1;
    finalSourceList(k) = join(strMatrix(startRow,1:colIdx),'');
end
end
 
function folderParts = fixFilesepRoots(folderParts)
firstIndWithoutFileSep = findFirstNonMatchingIndex(folderParts,filesep);
if firstIndWithoutFileSep > 1
    folderParts(firstIndWithoutFileSep) = join(folderParts(1:firstIndWithoutFileSep),'');
    folderParts(1:firstIndWithoutFileSep-1) = [];
end
end
 
function idx = findFirstNonMatchingIndex(strArray,matchStr)
% assumes there is at least one element does not match
idx = find(strArray ~= matchStr,1);
end