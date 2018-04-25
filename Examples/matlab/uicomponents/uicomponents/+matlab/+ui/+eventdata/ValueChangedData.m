classdef ValueChangedData < matlab.ui.eventdata.internal.AbstractEventData
    % This class is for the user to be able differentiate between
    % different types of Value events Eg: ValueChanged, ValueOpened. for now, it does not need any special implmentation
    
    properties(SetAccess = 'private')
        Value;
        
        PreviousValue;
    end
    
    methods
        function obj = ValueChangedData(newValue, previousValue, varargin)
            % The new value is a required input.
            %
            % The previous value is a required input.
            %
            % Additional arguments can be passed in in the form of
            % 'propertyName', propertyValue pairs to be added dynamically
            % to the instance
            %
            % Example:
            % eventdata = ValueChangedEventData(newValue, ...
            %                   previousValue,...
            %                   'ValueData', valueData, ...
            %                   'PreviousValueData', previousValueData)
            %
            %  creates an event data with two properties: Value and
            %  OldValue
            
            narginchk(2,Inf);
            
            % Verify that additional arguments are passed in pairs
            if(mod(length(varargin),2)~=0)
                error('Additional arguments to EventData should be passed as PV pairs');
            end
                        
            % Call super which will take care of the additional inputs
            obj = obj@matlab.ui.eventdata.internal.AbstractEventData(varargin{:});
            
            obj.Value = newValue;
            
            obj.PreviousValue = previousValue;
            
        end
    end
    
    % ---------------------------------------------------------------------
    % Custom Display Functions
    % Properties in ValueChangedData may be added dynamically to the
    % ValueChangedData class.  When properties are added dynamically, the
    % order in which they display or are accessed is not guarenteed.
    % Because of this, this custom display will handle the ordering for all
    % possible property types, then filter out the properties so that only
    % the objects which require them display them.
    % ---------------------------------------------------------------------
    methods(Access = protected)
        
        function groups = getPropertyGroups(obj)
            % GETPROPERTYGROUPNAMES - This function returns common
            % properties for this class that will be displayed in the
            % curated list properties for all components implenenting this
            % class.
            
            % Identify the super class properties because they will go last
            superClass = ?event.EventData;
            superClassNames = {superClass.PropertyList(:).Name}';
            
            % Identify this class' properties because they will go first
            thisClass = meta.class.fromName(class(obj));
            thisClassNames = setdiff({thisClass.PropertyList(:).Name}', superClassNames, 'stable');
            
            % Dynamically added properties will go after the required
            % properties and before the super class properties (Source and
            % EventName)
            
            targetPropertyList = [...                
                thisClassNames;... Value, PreviousValue
                ... Other common properties that are added dynamically
                {'Edited'}]; % DropDown
            
            valueChangedDataProperties = fields(obj);
            
            % Find all properties in the target list that exist on the real
            % object
            namesToUseFirst = ismember(targetPropertyList, valueChangedDataProperties);
            namesInOrder = targetPropertyList(namesToUseFirst);
            
            % Find any additional properties that are not accounted for in
            % the prefered ordering defined by the targetPropertyList
            additionalNames = setdiff(valueChangedDataProperties, [namesInOrder;superClassNames]);
            
            % Add the super class properties to the end of the display
            names = [namesInOrder; additionalNames; superClassNames];
            
            % Return the PropertyGroup
            groups = matlab.mixin.util.PropertyGroup(names);
        end
        
    end
 
end

