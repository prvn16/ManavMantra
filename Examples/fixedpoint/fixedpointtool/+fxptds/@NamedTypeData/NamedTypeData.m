classdef NamedTypeData < fxptds.AbstractSLData
    %NAMEDTYPEDATA translates the data to a fxptds.NamedTypeResult object to be added to
    %the Fixed-Point Tool's dataset
    
    % Copyright 2016-2017 The MathWorks, Inc.
    
    methods
        function this = NamedTypeData(data)
            this@fxptds.AbstractSLData(data);
            this.setSLObject(this.Data.Object);
            this.Path = this.SLObject.Name;
            this.PathItem = this.SLObject.Name;
        end
        
        function uniqueID = getUniqueIdentifier(this)
            uniqueID = fxptds.SimulinkDataObjectIdentifier(this.SLObject, this.PathItem);
        end
        
        function actionHandler = createActionHandler(~, result)
            % Get the corresponding actions class from an object of the result class
            % corresponding to this data class
            actionHandler =  fxptds.SimulinkDataObjectActions(result);
        end
        
        function result = createResult(~, data)
            % Obtain an instance of the result class corresponding to data
            result = fxptds.NamedTypeResult(data);
        end
    end
    
end