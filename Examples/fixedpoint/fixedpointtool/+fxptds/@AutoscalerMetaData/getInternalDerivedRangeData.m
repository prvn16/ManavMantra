function res = getInternalDerivedRangeData(this, internalID)
    % Retrieves the value for the internal derived range
    % Copyright 2016 The MathWorks, Inc.
    try
        res = this.InternalDerivedRangeMap.getDataByKey(internalID);
    catch
        res = [];
    end
end