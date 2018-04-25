classdef InspectorGroup < handle
    % This class is unsupported and might change or be removed without
    % notice in a future version.

    % InspectorGroup - a class representing a group of properties for a
    % property inspector view.  
    
    % Copyright 2015-2017 The MathWorks, Inc.
    
    properties
        % ID for this inspector group
        GroupID;
        
        % Description for the group, to be shown in a tooltip or detailed
        % information for a group.
        Description @ char
        
        % Whether the group should be expanded by default, or not.
        Expanded = false;
		
		% Display name of the group
		Title @ char
		
		% list of all items
		%
		% Each element can be:
		% - char					a single property
		% - InspectorSubGroup		a collection of sub properties
		% - InspectorEditorGroup    a collection of related properties
		PropertyList @ cell				
    end
    
    methods
        % Create an InspectorGroup instance
        function this = InspectorGroup(GroupID, Title, Description)            
			
			narginchk(3,3);
            
			this.GroupID = GroupID;
            if isempty(Title)
                this.Title = GroupID;
            else
                this.Title = Title;
            end
            this.Description = Description;
			
			this.PropertyList = {};					
        end
        
        % Add properties to this InspectorGroup
		%
		% varargin = list of properties in the group
        function addProperties(this, varargin)
            this.PropertyList = [this.PropertyList  varargin];
		end						
		
		% Add a subgroup to the list
		%
		% varargin = list of properties in the sub group
		function subGroup = addSubGroup(this, varargin)
			subGroup = internal.matlab.inspector.InspectorSubGroup;
			subGroup.addProperties(varargin{:});			
			
			this.PropertyList = [this.PropertyList  {subGroup}];
		end
		
		% Add editor group of properties to this InspectorGroup
		%
		% varargin = list of properties in the editor group
		function addEditorGroup(this, varargin)			
			editorGroup = internal.matlab.inspector.InspectorEditorGroup;
			editorGroup.addProperties(varargin{:});			
			
			this.PropertyList = [this.PropertyList  {editorGroup}];		
		end
    
        % Remove properties from this InspectorGroup
        function removeProperties(this, propertiesToRemove)
            if ~iscell(propertiesToRemove)
                propertiesToRemove = {propertiesToRemove};
            end
            idx = cellfun(@(x) ~ismember(x, propertiesToRemove), ...
                this.PropertyList);
            this.PropertyList = this.PropertyList(idx);
        end
    end
end
