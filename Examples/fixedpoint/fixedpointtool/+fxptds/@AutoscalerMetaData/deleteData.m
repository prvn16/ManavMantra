function deleteData(this)
    % Copyright 2016 The MathWorks, Inc.
    % Implementation of the Abstract API.
    this.clear;
    delete(this.ResultSetForSourceMap);
    delete(this.busObjectHandleMap);
    delete(this.InternalDerivedRangeMap);
end