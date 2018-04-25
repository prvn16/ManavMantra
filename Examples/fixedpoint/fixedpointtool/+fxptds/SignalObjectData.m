classdef SignalObjectData < fxptds.AbstractSLData
%SignalObjectData Translates the data from a Signal Object to a result object to be added to the Fixed-Point Tool's dataset

% Copyright 2012-2017 The MathWorks, Inc.

    methods
        function this = SignalObjectData(data)
            this@fxptds.AbstractSLData(data);
            this.setSLObject(this.Data.Object);
            this.Path = this.SLObject.Name;
            this.PathItem = this.SLObject.Name;
        end
    
        function uniqueID = getUniqueIdentifier(this)
            uniqueID = fxptds.SimulinkDataObjectIdentifier(this.SLObject, this.PathItem);
        end
    
        function actionHandler = createActionHandler(~, result)
            actionHandler =  fxptds.SimulinkDataObjectActions(result);
        end
        
        function result = createResult(~, data)
            result = fxptds.SignalObjectResult(data);
        end
    end
end