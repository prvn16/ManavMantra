classdef BusObjectData < fxptds.AbstractSLData
%SDOData Translates the data from a Signal Object to a result object to be added to the Fixed-Point Tool's dataset

% Copyright 2012-2017 The MathWorks, Inc.

    methods
        function this = BusObjectData(data)
            this@fxptds.AbstractSLData(data);
            this.setSLObject(this.Data.Object);           
            if isfield(this.Data,'ElementName')
                this.PathItem = this.Data.ElementName;
            end
        end
    
        function uniqueID = getUniqueIdentifier(this)
            uniqueID = fxptds.SimulinkDataObjectIdentifier(this.SLObject, this.PathItem);
        end
    
        function actionHandler = createActionHandler(~, result)
            actionHandler =  fxptds.SimulinkDataObjectActions(result);
        end
        
        function result = createResult(~, data)
            result = fxptds.BusObjectResult(data);
        end
    end
end
