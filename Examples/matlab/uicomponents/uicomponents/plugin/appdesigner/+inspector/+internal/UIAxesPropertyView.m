classdef UIAxesPropertyView < matlab.graphics.internal.propertyinspector.views.AxesPropertyView
    
    % These properties are ones that exist on UIAxes on top of what is
    % already defines for Axes
    
    properties
        BackgroundColor@matlab.graphics.datatype.RGBAColor
    end   
    
    methods
        function obj = UIAxesPropertyView(componentObject)
            obj = obj@matlab.graphics.internal.propertyinspector.views.AxesPropertyView(componentObject);
            
            % How UIAxesPropertyView works
            %
            % This class subclasses Axes property view to get all groupings
            % defined for base MATLAB.  To accomodate App Designer, it
            % makes a few changes to the groups, either by removing the
            % groups entirely or removing specific properties from the
            % group.
            
            % Remove these groups
            obj.GroupList(obj.GroupList == obj.IdentifiersGroup) = [];
            obj.GroupList(obj.GroupList == obj.LabelsGroup) = [];
            % Remove Units
            unitsIndex = cellfun(@(property) isstr(property) && strcmp(property, 'Units'), obj.PositionGroup.PropertyList);
            obj.PositionGroup.PropertyList(unitsIndex) = [];
            
            % Add BackgroundColor after Color (Axes does not have BackgroundColor)            
            colorIndex = find(cellfun(@(property) isstr(property) && strcmp(property, 'Color'), obj.ColorAndStylingGroup.PropertyList));
            
            % expose all properties of this group, and additionally the
            % BackgroundColor property which does not exist on axes
            obj.ColorAndStylingGroup.PropertyList = [obj.ColorAndStylingGroup.PropertyList {'BackgroundColor'}];     
            
            % Expose only the Visible property from the Interactivity group
            obj.InteractivityGroup.PropertyList = {'Visible'};
        end
    end
end