function [result, newResults, numAdded] = findResultForBlockFromArrayOrCreate(this, allResults, blkObj)
    
    %   Copyright 2016-2017 The MathWorks, Inc.
    
    % Finds all existing results that correspond to a particular block object, irrespective of the element it contains,
    % This function replaces one instance from addToSrcList where it looks for results pertaining to a particular block.
    % NOTE: Method originally part of Application Data, see g1431153
    %Get all the pathitems for the block and loop over them to see if a result exists.
    ae = SimulinkFixedPoint.EntityAutoscalersInterface.getInterface();
    ascaler = ae.getAutoscaler(blkObj);
    pathItems = ascaler.getPathItems(blkObj);
    result = [];
    newResults = [] ;
    numAdded = 0;
    if isempty(pathItems)
        pathItems{1} = '1';
    end
    for pp = 1:numel(pathItems)
        data = struct('Object',blkObj,'ElementName',pathItems{pp});
        dHandler = fxptds.SimulinkDataArrayHandler;
        resForPathItem = this.getResultsWithCriteriaFromArray(allResults,{'UniqueIdentifier',dHandler.getUniqueIdentifier(data)});
        if isempty(resForPathItem)
            resForPathItem = this.createAndUpdateResult(fxptds.SimulinkDataArrayHandler(data));
            newResults = [ newResults resForPathItem];  %#ok<AGROW>
            numAdded = numAdded + 1;
        end
        result = [result resForPathItem]; %#ok<AGROW>
        
    end
end

