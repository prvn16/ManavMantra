classdef AbstractSLData < handle
% ABSTRACTSLDATA Abstract class to represent the Simulink element contanined the data. 

% Copyright 2012-2016 The MathWorks, Inc.

    properties (Access = protected)
        Data      % Raw data structure containing information.
        SLObject  % The Simulink object that owns the element in the data.
        Port      % Port number that the element represents.
        PathItem = '';  % PathItem that the element represents.
        Path = '';      % Simulink path for the element.
    end
        
    methods (Abstract)
        uniqueID = getUniqueIdentifier(this);
        result = createResult(this);
        actionHandler = createActionHandler(this, result)
    end
    
    methods 
        function this = AbstractSLData(data)
            this.Data = data;
        end
    end
    
    methods(Access = protected)
        function setSLObject(this, slObj)
            this.SLObject = slObj;
        end
    end
    
end
