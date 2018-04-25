classdef (Hidden) AbstractEventData < event.EventData & ...
                                    dynamicprops  & ...
                                    matlab.mixin.CustomDisplay
    
    % Copyright 2011-2012 The MathWorks, Inc.
    
    
    
    % ---------------------------------------------------------------------
    % Constructor
    % ---------------------------------------------------------------------
    methods
        function obj = AbstractEventData(varargin)            
            % Optional arguments passed in in the form of
            % 'propertyName', propertyValue pairs.
            % The PV pairs are added as dynamic properties on the event
            % data object.
            % This allow creating event data of the same class but with
            % different properties. 
            % 
            % Example: 
            %
            %   For the drop down, ValueChangedEventData has a Value
            %   property only
            %
            %   For the editable drop down, ValueChangedEventData has the
            %   properties Value, Edited, OldValue
                        
            % Verify that additional arguments are passed in pairs
            if(mod(length(varargin),2)~=0)
                error('Optional arguments to EventData should be passed as PV pairs');
            end                
            
            % Add any dynamic properties to the object
            if(length(varargin) >= 1)
                for k = 1:2:length(varargin)
                    propertyName = varargin{k};
                    propertyValue = varargin{k+1};
                    obj.addPrivateProperty(propertyName, propertyValue);
                end
            end
        end                
    end
    
    methods(Access = 'private')
        
        function addPrivateProperty(obj, propertyName, propertyValue)
            % Adds a property dynamically to the object instance.
            % The object class must derive from dynamicprops for the method
            % 'addprop' to work
                        
            % Add the property to the event data
            property = obj.addprop(propertyName);            
            
            % Set its value
            obj.(propertyName) = propertyValue;
            
            % Set the SetAccess to private after setting its value so the
            % user cannot change the property 
            property.SetAccess = 'private';
            
        end
    end
    
    % ---------------------------------------------------------------------
    % Custom Display Functions
    % This class inherits from event.EventData so this class will always
    % have the two properties 'Source' and 'Event'
    % These properties will be filtered so they always appear at the bottom
    % of the properties list.
    % ---------------------------------------------------------------------
    methods(Access = protected)
        
        function groups = getPropertyGroups(obj)
            % GETPROPERTYGROUPNAMES - This function returns common
            % properties for this class that will be displayed in the
            % curated list properties for all components implenenting this
            % class.
            superClassProperties = properties(event.EventData);
            
            % Filter out the super class properties from the property list
            names = setdiff(fields(obj), superClassProperties, 'stable');
            
            % Add the super class properties to the end of the display
            names = [names; superClassProperties];
            
            % Return the PropertyGroup
            groups = matlab.mixin.util.PropertyGroup(names);
        end
        
    end
        
end

