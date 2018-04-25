function clear(this)
    % Copyright 2016 The MathWorks, Inc.
    % Clears the data in the maps
    this.clearResultListForAllSources;
    for i = 1:this.busObjectHandleMap.getCount
        busObjectHandle = this.busObjectHandleMap.getDataByIndex(i);
        delete(busObjectHandle);
    end
    this.busObjectHandleMap.Clear();
    
end