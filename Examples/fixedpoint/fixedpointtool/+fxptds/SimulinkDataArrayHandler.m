classdef SimulinkDataArrayHandler < fxptds.AbstractDataArrayHandler
% SIMULINKDATAARRAYHANDLER Implements the interface to handle data from
% Simulink and create result objects to add to the Fixed-Point Tool's
% dataset.

% Copyright 2012-2017 The MathWorks, Inc.

    methods
        function this = SimulinkDataArrayHandler(dataStructArray)
        % Process the dataStructArray and extract some additional
        % information about the entity being added.
            if nargin == 0
                dataArray = {};
            else
                for i = 1:length(dataStructArray)
                    DTInfo = fxptds.getDataTypeInfo(dataStructArray(i));
                    if ~isempty(DTInfo.SimDT)
                        dataStructArray(i).DataTypeName = DTInfo.SimDT;
                    end
                    if ~isempty(DTInfo.IsScaledDouble)
                        dataStructArray(i).IsScaledDouble = DTInfo.IsScaledDouble;
                    end
                    if ~isempty(DTInfo.RangeMax)
                        dataStructArray(i).RangeMax = DTInfo.RangeMax;
                    end
                    if ~isempty(DTInfo.RangeMin)
                        dataStructArray(i).RangeMin = DTInfo.RangeMin;
                    end
                    if ~isempty(DTInfo.BlkStatus)
                        dataStructArray(i).BlkExecStatus = DTInfo.BlkStatus;
                        if strcmpi(DTInfo.BlkStatus, 'Did not Execute')
                            % fxptds.getDataTypeInfo sets the BlkExecStatus property of dataStructArray to
                            % 'Did not Execute' if its MinValue > MaxValue.
                            % Using this property to clear the min, max information from the dataArray
                            % which is eventually added to the result downstream
                            invalidRangeFieldSets = DTInfo.InvalidRangeFields;
                            for j=1:length(invalidRangeFieldSets)
                                invalidRangeFieldSet = invalidRangeFieldSets{j};
                                dataStructArray(i).(invalidRangeFieldSet{1}) = [];
                                dataStructArray(i).(invalidRangeFieldSet{2}) = [];
                            end
                        end
                    end
                    if ~isempty(DTInfo.DataTypeObj)
                        dataStructArray(i).DataTypeObject = DTInfo.DataTypeObj;
                    end
                end
                dataArray = dataStructArray;
            end
            this@fxptds.AbstractDataArrayHandler(dataArray);
        end

        function [uniqueId, dataObj] = getUniqueIdentifier(this, data)
        % Return a unique ID to identiy the element in the data structure.
        % Return dataObj used to create the unique ID for performance.
            dataObj = this.createDataObj(data);
            if ~isempty(dataObj)
                uniqueId = dataObj.getUniqueIdentifier;
            else
                uniqueId = [];
            end
        end

        function [result, dataObj] = createResult(this, data)
        % Return a result object that represents the data being added.
        % Return dataObj used to create the result for performance.
            dataObj = this.createDataObj(data);
            % Add the data object to the data structure when creating a
            % result to improve performance. This data object will be used
            % when creating the unique identifier and action handlers for
            % the created result. Cannot pass this as a separate input to
            % the result constructor because the superclass layer is very
            % abstract and only expects 1 input. The methods that require
            % the data object are called from the superclass constructor and
            % will not have access to this dataobject unless passed via the
            % data structure.
            data.SLDataObject = dataObj;
            result = dataObj.createResult(data);
        end

        function [actionHandler, dataObj] = createActionHandler(this, data)
        % Return the action handler for the element being added
        % Return dataObj used to create the action handler ID for performance.
            dataObj = this.createDataObj(data);
            if ~isempty(dataObj)
                actionHandler = dataObj.createActionHandler(data);
            else
                actionHandler = [];
            end
        end

        function dataObject = getDataObject(this, data)
            dataObject = this.createDataObj(data);
        end
    end

    methods(Access=private)
        function dataObj = createDataObj(~, data)
        % Create the appropriate data object based on the data being passed
        % in. This object will then perform the required tasks.
            if isfield(data,'Object')
                object = data.Object;
                if isa(object, 'Simulink.SubSystem') && ... 
                    fxptds.isSFMaskedSubsystem(object)
                    object = fxptds.getSFChartObject(object);
                end			
            elseif isfield(data,'isStateflow') && ~isempty(data.isStateflow) && data.isStateflow
                object = find(sfroot, '-isa', 'Stateflow.Object', 'ID', data.dataID);  %#ok<GTARG>
            elseif isfield(data,'Path')
                blkPath = data.Path;
                try
                    object = get_param(blkPath,'Object');
                    if fxptds.isSFMaskedSubsystem(object)
                        object = fxptds.getSFChartObject(object);
                    end
                catch e %#ok
                    object = fxptds.getSFObjFromPath(blkPath);
                end
            else
                object = [];
            end

            % Factory for getting the right fxptds data class
            data.Object = object;
            if isa(object, 'Stateflow.Object')
                if isa(object,'Stateflow.Junction')|| ...
                        isa(object,'Stateflow.Transition')
                    DAStudio.error('FixedPointTool:fixedPointTool:unsupportedObjectClass', class(object));
                end
                dataObj = fxptds.StateflowData(data);
            elseif isa(object, 'SimulinkFixedPoint.DataObjectWrapper')
                dataObj = fxptds.(object.DataClassType)(data);
            elseif isa(object,'Simulink.Object')
                dataObj = fxptds.BlockData(data);
            elseif isa(object,'SimulinkFixedPoint.BusObjectHandle')
                dataObj = fxptds.BusObjectData(data);
            else
                dataObj = [];
            end
        end
    end
end

% LocalWords:  daobject
