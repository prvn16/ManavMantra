function result = getResultForClientResultID(resultUniqueID, objectClass)
% GETRESULTFORCLIENTRESULTID returns the result object that corresponds to
% the unique ID of the result provided by the client (web-app)

%Copyright 2016 The MathWorks, Inc.

result = [];
% Run name is separated by a '_' from the unique ID
idx = strfind(resultUniqueID, '_');
if ~isempty(idx)
    runName = resultUniqueID(idx(1)+1:end);
    uniqueKey = resultUniqueID(1:idx(1)-1);
    idx = strfind(uniqueKey,'::');
    elementName = uniqueKey(idx(1)+2:end);
    [~, blkObj] = fxptds.getBlockPathFromIdentifier(uniqueKey, objectClass);
    parentObj = blkObj;
    if isa(blkObj, 'Stateflow.Data')
        parentObj = blkObj.getParent;
    end
    if ~fxptds.isStateflowChartObject(parentObj)
        if isprop(parentObj,'Chart')
            parentObj = parentObj.Chart;
        end
    end
    dsSource = bdroot(parentObj.getFullName);
    rep = fxptds.FPTRepository.getInstance;
    ds = rep.getDatasetForSource(dsSource);
    runObj = ds.getRun(runName);
    result = runObj.getResult(blkObj, elementName);
end
