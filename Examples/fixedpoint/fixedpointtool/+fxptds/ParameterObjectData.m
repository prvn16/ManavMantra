classdef ParameterObjectData < fxptds.AbstractSLData
    %ParameterObjectData Translates the data from a Parameter Object to a result object to be added to the Fixed-Point Tool's dataset
    
    % Copyright 2012-2017 The MathWorks, Inc.
    
    methods
        function this = ParameterObjectData(data)
            this@fxptds.AbstractSLData(data);
            this.setSLObject(this.Data.Object);
            if isfield(data,'ElementName')
                this.PathItem = this.Data.ElementName;
            else
                this.PathItem = this.SLObject.Name;
            end
            this.Path = this.PathItem;
        end
        
        function uniqueID = getUniqueIdentifier(this)
            uniqueID = fxptds.SimulinkDataObjectIdentifier(this.SLObject, this.PathItem);
        end
        
        function actionHandler = createActionHandler(~, result)
            actionHandler =  fxptds.SimulinkDataObjectActions(result);
        end
        
        function result = createResult(~, data)
            result = fxptds.ParameterObjectResult(data);
        end
    end
end