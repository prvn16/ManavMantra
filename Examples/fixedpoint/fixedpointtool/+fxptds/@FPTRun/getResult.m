function [result, numAdded, dHandler] = getResult(this, blkObj, pathitem)
    %GETRESULT returns a result if it exists and creates one if it doesn't
    % Number of created results is also returned.
    % Get the dataset record of all signals on a block.
    % If specified pathItems, return only one signal;
    % otherwise, return all records of the block.
    % Input arguments: blkObj, SignalName, all in string format
    % NOTE: Method originally part of Application Data, see g1431153
    %   Copyright 2016-2017 The MathWorks, Inc.
    
    numAdded = 0;
    
    % returns empty result for blkObj = []
    if isempty(blkObj)
        result = [];
        return;
    end
    % Support variable input argument list length
    data = struct('Object',blkObj, 'ElementName',pathitem);
    
    dHandler = fxptds.SimulinkDataArrayHandler(data);
    result = this.getResultByID(dHandler.getUniqueIdentifier(data));
end