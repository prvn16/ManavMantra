classdef (Hidden) TextAreaController < ...
		matlab.ui.control.internal.controller.ComponentController
	% TextAreaController is the controller for TextArea
	
	% Copyright 2011-2015 The MathWorks, Inc.
	
	methods
		function obj = TextAreaController(varargin)
			obj@matlab.ui.control.internal.controller.ComponentController(varargin{:});
		end
	end
	
	methods(Access = 'protected')
		
		function handleEvent(obj, src, event)
			% Allow super classes to handle their events
			handleEvent@matlab.ui.control.internal.controller.ComponentController(obj, src, event);
			
			if(strcmp(event.Data.Name, 'ValueChanged'))
				% Handles when the user changes the text in the ui
				
				% Get the previous value
				previousValue = obj.Model.Value;
				
				% Get the new value
				newValue = event.Data.Value;
				
				% Create event data
				eventData = matlab.ui.eventdata.ValueChangedData(newValue, previousValue);
				
				% Update the model and emit 'ValueChanged' which in turn will
				% trigger the user callback
				obj.handleUserInteraction('ValueChanged', {'ValueChanged', eventData, 'PrivateValue', newValue});
			end
		end
		
		function changedPropertiesStruct = handlePropertiesChanged(obj, changedPropertiesStruct)
			% Handle specific property sets
			
			if(any(strcmp('Value', fieldnames(changedPropertiesStruct))))
				
				newValue = changedPropertiesStruct.Value;
				
				if(isempty(newValue))
					% Need to explicitly convert any empty value coming
					% from client to empty cell str
					%
					% g1416534
					newValue = {''};
				end
				
				% Apply to the model
				obj.Model.Value = newValue;
				
				% Remove the field from the struct since it has
				% been handled already
				changedPropertiesStruct = rmfield(changedPropertiesStruct, 'Value');
			end
			
			% Call the superclasses for unhandled properties
			handlePropertiesChanged@matlab.ui.control.internal.controller.ComponentController(obj, changedPropertiesStruct);
		end
	end
end

