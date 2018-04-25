classdef InspectorSubGroup < handle
    % This class is unsupported and might change or be removed without
    % notice in a future version.

    % InspectorSubGroup - a class representing a sub group within a group.  
    
    % Copyright 2017 The MathWorks, Inc.
    
    properties              
        % Whether the group should be expanded by default, or not.
        Expanded = false;
		
		% list of all properties
		%
		% Cell array of strings
		PropertyList @ cell				
    end
    
    methods        
        function this = InspectorSubGroup()            			
			narginchk(0,0);            
			
			this.PropertyList = {};
        end
        
        
        function addProperties(this, varargin)
			% Add Properties to this group.  Subgroups can be created as
			% empty, but don't add an empty property to the list.
            if nargin >= 2 && ~isempty(varargin{1})
                this.PropertyList = [this.PropertyList  varargin];
            end
        end 
        
        % Allows adding editor group (kebob button) to the subgroup
        function addEditorGroup(this, varargin)
            editorGroup = internal.matlab.inspector.InspectorEditorGroup;
            editorGroup.addProperties(varargin{:});
            
            this.PropertyList = [this.PropertyList  {editorGroup}];
        end
    end
end