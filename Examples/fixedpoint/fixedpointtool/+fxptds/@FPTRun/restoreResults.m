function restoreFailedResults = restoreResults(this, savableResults)
%% RESTORERESULTS function restores the run object using the results given as input

% Copyright 2016-2017 The MathWorks, Inc.
        restoreFailedResults = {};
        metaData = fxptds.AutoscalerMetaData;
        this.setMetaData(metaData);
        for rsIdx = 1:length(savableResults)
            currResult = savableResults(rsIdx);

            % currResult is restored already by loadobj when loading
            % from the file

            if currResult.isResultValid
                this.addResult(currResult);

                % restore ResultSetForSourceMap
                if ~isempty(currResult.getActualSourceIDs)
                    actualSrcIDs = currResult.getActualSourceIDs;
                    for srcIDsIdx = 1:length(actualSrcIDs)
                        srcID = actualSrcIDs{srcIDsIdx};
                        % case 1: insert srcID and this result -- addToSrcList.m  
                        currSetRSForSrc = metaData.getResultSetForSource(srcID);
                        if ~isa(currResult,'fxptds.AbstractSimulinkObjectResult')
                            currSetRSForSrc(currResult.getUniqueIdentifier.UniqueKey) = currResult;
                            metaData.setResultSetForSource(srcID,currSetRSForSrc);
                        end
                    end
                end
                % case 2: insert this.UniqueIdentifier and this result into
                % the map if this result is referred by the ActualSourceIDs of
                % another result 
                if currResult.getIsReferredByOtherActualSourceID
                    currSetRSForSrcSelf = metaData.getResultSetForSource(currResult.getUniqueIdentifier);
                    if ~isa(currResult,'fxptds.AbstractSimulinkObjectResult')
                        currSetRSForSrcSelf(currResult.getUniqueIdentifier.UniqueKey) = currResult;
                        metaData.setResultSetForSource(currResult.getUniqueIdentifier,currSetRSForSrcSelf);
                    end                    
                end  

                % restore busObjectHandleMap
                if isa(currResult, 'fxptds.BusObjectResult')
                    busMap = metaData.getBusObjectHandleMap;
                    busHandle = currResult.getUniqueIdentifier.getObject;
                    if ~busMap.isKey(busHandle.busName)
                        busMap.insert(busHandle.busName,busHandle);
                    end
                end
            end
        end
end 