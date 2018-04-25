classdef (Hidden) MultilineTextComponentController <  appdesservices.internal.interfaces.controller.AbstractControllerMixin
	% Mixin Controller Class for Multiline Text Components
	
	% Copyright 2011-2015 The MathWorks, Inc.
	
	methods
		
		function viewPvPairs = getTextPropertiesForView(obj, propertyNames)
			% Gets all properties for view based on 'Text'
			
			viewPvPairs = {};
			
			if(any(strcmp('Text', propertyNames)))
				modelData = obj.Model.Text;
				if(iscell(modelData))
					%do nothing since the text is already in multiple arrays
				else
					modelData = regexp(modelData,'\n','split'); %split into muliple arrays for each line of text
				end
				viewPvPairs = [viewPvPairs, ...
					{'Text', modelData} ...
					];
			end
		end				
	end
	methods(Access = 'protected')
		function changedPropertiesStruct = handlePropertiesChanged(obj, changedPropertiesStruct)			
			
			if(isfield(changedPropertiesStruct, 'Text'))
				newText = changedPropertiesStruct.Text;
				
				% some parts of the client (specifically the Inspector in
				% this case) can send [] when the user typed in a blank
				% value
				%
				% Want to explicitly convert to ''
				%
				% This could be removed if Inspector is no longer going
				% through controllers to update properties.
				%
				% g1475502
				if(isempty(newText))
					newText = '';
				end
				
				obj.Model.Text = newText;
				
				changedPropertiesStruct = rmfield(changedPropertiesStruct, 'Text');
			end			
		end
	end
end

