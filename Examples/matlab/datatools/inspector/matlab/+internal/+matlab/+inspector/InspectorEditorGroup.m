classdef InspectorEditorGroup < handle
    % This class is unsupported and might change or be removed without
    % notice in a future version.

    % InspectorEditorGroup - a class representing a set of properties
    % sharing a common rich editor
    
    % Copyright 2015 The MathWorks, Inc.
    
    properties                      		
		% list of all properties
		%
		% A cell array of strings
		PropertyList @ cell				
    end
    
    methods        
        function this = InspectorEditorGroup()            			
			narginchk(0,0);            
			
			this.PropertyList = {};
        end
        
        
        function addProperties(this, varargin)
			% Add Properties to this group
			
            this.PropertyList = [this.PropertyList  varargin];
		end           
    end
end
