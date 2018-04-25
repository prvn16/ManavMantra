classdef BlockData < fxptds.AbstractSLData
% SLBLOCKDATA Translates the data from a Simulink block into a result object to be added to the Fixed-Point Tool's dataset

%  Copyright 2012-2017 The MathWorks, Inc.
        
    methods
        function this = BlockData(data)
            this@fxptds.AbstractSLData(data);
            this.setSLObject(this.Data.Object);            
            if isfield(this.Data,'Port')
                if ischar(this.Data.Port) && ~isempty(regexp(this.Data.Port,'^[0-9]','ONCE'))
                    this.Data.Port = str2double(this.Data.Port);
                end
                this.PathItem = int2str(this.Data.Port);
            end
            if isfield(this.Data,'PathItem')
                if ~ischar(this.Data.PathItem)
                    this.Data.PathItem = num2str(this.Data.PathItem);
                end
                this.PathItem = this.Data.PathItem;
            end
            if isfield(this.Data,'ElementName')
                if ~ischar(this.Data.ElementName)
                    this.Data.ElementName = num2str(this.Data.ElementName);
                end
                this.PathItem = this.Data.ElementName;
            end
            if isempty(this.PathItem) 
                if isfield(this.Data,'SignalName')
                    if ~ischar(this.Data.SignalName)
                        this.Data.SignalName = num2str(this.Data.SignalName);
                    end
                    this.PathItem = this.Data.SignalName;
                else
                    this.PathItem = '1';
                end
            end

            % Get the name of the object if the path item is a number which
            % indicates an output port.
            if ~isempty(regexp(this.PathItem,'^[0-9]','ONCE'))
                this.PathItem = this.getNameForPort(str2double(this.PathItem));
            end
        end
        
        function uniqueID = getUniqueIdentifier(this)
        % Return an unique identifier that describes the Simulink element.
            uniqueID = fxptds.SimulinkIdentifier(this.SLObject, this.PathItem);
        end
       
        
        function actionHandler = createActionHandler(~, result)
            actionHandler = fxptds.SimulinkActions(result);
        end
        
        function result = createResult(~, data)
        % Create the result object based on the Simulink element.
            result = fxptds.BlockResult(data);
        end
    end
    
    methods(Access = private)
        function pathitem = getNameForPort(this, port)
            autoscaleExtensions =  SimulinkFixedPoint.EntityAutoscalersInterface.getInterface();
            autoscaler = autoscaleExtensions.getAutoscaler(this.SLObject);
            pathitem = autoscaler.getPortMapping(this.SLObject, [], port);
            if iscell(pathitem)
                pathitem = [pathitem{:}];
            end
            if isempty(pathitem)
                pathitem = int2str(port);
            end
        end
    end
end

