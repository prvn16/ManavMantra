classdef (Hidden) AbstractComponent < ...
        appdesservices.internal.interfaces.model.AbstractModel & ...
        matlab.ui.internal.componentframework.services.optional.HGCommonPropertiesInterface & ...
        matlab.ui.control.internal.model.mixin.ParentableComponent & ...
        matlab.mixin.CustomDisplay
    
    % AbstractComponent is the most basic "component" class.
    %
    % It is the parent of both App Windows and leaf components
    
    % Copyright 2014-2015 The MathWorks, Inc.
    
    % Controller methods / properties
    
    methods (Access = protected)
        
        % Components must return a cell array of strings that will be used
        % to create the property group for the custom display of components
        function names = getPropertyGroupNames(obj)
            % GETPROPERTYGROUPNAMES - This class can be customized in the
            % component subclasses
            
            names = setdiff(fields(obj), {'Position', 'InnerPosition', 'OuterPosition'}, 'stable')';
        end
        
        function str = getComponentDescriptiveLabel(obj)
            % GETCOMPONENTDESCRIPTIVELABEL - This function returns a
            % string that will represent this component when the component
            % is displayed in a vector of ui components.
            
            str = ''; 

        end       
    end
    
    
    % Model - related methods
    methods(Access = {...
            ?appdesservices.internal.interfaces.model.AbstractModel, ...
            ?appdesservices.internal.interfaces.model.AbstractModelMixin})
        
        function parsePVPairs(obj, varargin)
            % Helper method to be used by Model subclasses to:
            %
            % - handle PV Pairs
            % - after, mark the model as fully constructed
            
            % Generally speaking, the Value property of a component is
            % dependent on other settings of the component.  We will move
            % 'Value' property to the end so it will be set last. Most (but
            % not all) components have a Value property.  If a
            % component does not have a Value property, the shift will
            % have no affect.
            import matlab.ui.control.internal.model.*;
            orderDependentProperties = ["Parent"; "Value"];
            propertyList = string(properties(obj));
            
            pvPairs = PropertyHandling.shiftOrderDependentProperties(varargin, orderDependentProperties, propertyList);
            if ~isempty(pvPairs)
                % Call into the AbstractModel to do the property sets
                parsePVPairs@appdesservices.internal.interfaces.model.AbstractModel(obj, pvPairs{:});
            end
            
        end
        
    end
    
    methods(Sealed, Access = protected)
        % There's no need for this method to be implemented by subclasses
        % Subclasses can customize by implementing 'getPropertyGroupNames'
        function groups = getPropertyGroups(obj)
            % GETPROPERTYGROUPS - Used for custom display of UI Components.
            % This function returns a group containing the properties that
            % will show up by default when the component displays.
            names = getPropertyGroupNames(obj);
            
            names = [names, ...
                ... Position related properties should
                ... go on the end of all components
                {'Position'}];
            groups = matlab.mixin.util.PropertyGroup(names);
            
        end
        
        function str = getDescriptiveLabelForDisplay(obj)
            % GETDESCRIPTIVELABELFORDISPLAY - This function returns a
            % string that will represent this component when the component
            % is displayed in a vector of ui components.
            
            if ~isempty(obj.Tag)
                str = obj.Tag;
            else
                str = getComponentDescriptiveLabel(obj);
            end
        end
        
    end
end





