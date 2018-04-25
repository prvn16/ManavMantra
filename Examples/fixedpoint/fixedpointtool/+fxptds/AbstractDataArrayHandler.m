classdef AbstractDataArrayHandler < handle
% ABSTRACTDATAARRAYHANDLER Abstract interface to help in constructing the correct result object for the data passed in.  
    
% Copyright 2012 MathWorks, Inc.
    
    properties (SetAccess=protected, GetAccess=protected)
        DataArray;
    end
    
    methods
        function this = AbstractDataArrayHandler(dataStructArray)
            if nargin > 0
                this.DataArray = dataStructArray;
            end
        end
        
        function dataArray = getDataArray(this)
            dataArray = this.DataArray;
        end
    end
    
    methods(Abstract)
        uniqueID = getUniqueIdentifier(this, data);
        result = createResult(this, data);
    end
end

