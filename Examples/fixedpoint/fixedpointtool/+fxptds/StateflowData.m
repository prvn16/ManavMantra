classdef StateflowData < fxptds.AbstractSLData
% STATEFLOWDATA Translates the data from stateflow to a result object to be added to the dataset

% Copyright 2012-2017 The MathWorks, Inc.

   
    methods
        function this = StateflowData(data)
            this@fxptds.AbstractSLData(data);            
            this.setSLObject(data.Object);
            
            if isfield(data,'Path')
                this.Path = [data.Path '/' this.SLObject.Name];
            end
            
            if isfield(data,'ElementName')
                this.PathItem = data.ElementName;
            else
                this.PathItem = '1';                
            end            
        end
    
        function uniqueID = getUniqueIdentifier(this)
            uniqueID = fxptds.StateflowIdentifier(this.SLObject, this.PathItem);
        end
        
        function actionHandler = createActionHandler(~, result)
            actionHandler =  fxptds.StateflowActions(result);
        end
        
        function result = createResult(this, data)
            if fxptds.isStateflowChartObject(this.SLObject)
                result = fxptds.StateflowChartResult(data);
            elseif isa(this.SLObject,'Stateflow.State')
                result = fxptds.StateflowStateResult(data);
            else
                result = fxptds.StateflowResult(data);
            end
        end
    end
    
    
end

