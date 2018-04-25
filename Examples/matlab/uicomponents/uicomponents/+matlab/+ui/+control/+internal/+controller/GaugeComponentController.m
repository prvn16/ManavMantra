classdef (Hidden) GaugeComponentController < matlab.ui.control.internal.controller.TickComponentController
	% GaugeComponentController This is controller class for all the gauges
	
	% Copyright 2011-2012 The MathWorks, Inc.
	
	methods
		function obj = GaugeComponentController(varargin)
			obj@matlab.ui.control.internal.controller.TickComponentController(varargin{:});
		end
	end
	
	methods(Access = 'protected')
		
		function viewPvPairs = getPropertiesForView(obj, propertyNames)
			% GETPROPERTIESFORVIEW(OBJ, PROPERTYNAME) returns view-specific
			% properties, given the PROPERTYNAMES
			%
			% Inputs:
			%
			%   propertyNames - list of properties that changed in the
			%                   component model.
			%
			% Outputs:
			%
			%   viewPvPairs   - list of {name, value, name, value} pairs
			%                   that should be given to the view.
			
			viewPvPairs = {};
			
			% Tick Properties from super
			viewPvPairs = [viewPvPairs, ...
				getPropertiesForView@matlab.ui.control.internal.controller.TickComponentController(obj, propertyNames), ...
				];
			
			% Convert ValueDisplayVisible to true/false
			if(any(strcmp('ValueDisplayVisible', propertyNames)))
				
				% Convert on/off to true/false
				newValue = matlab.ui.control.internal.model.PropertyHandling.convertOnOffToTrueFalse(obj.Model.ValueDisplayVisible);
				
				viewPvPairs = [viewPvPairs, ...
					{'ValueDisplayVisible', newValue}, ...
					];
			end
			
		end
		
		% Handle Gauge specific property sets
		function changedPropertiesStruct = handlePropertiesChanged(obj, changedPropertiesStruct)
			
			% Figure out what properties changed
			changedProperties = fieldnames(changedPropertiesStruct);			
			
			if(isfield(changedPropertiesStruct, 'ValueDisplayVisible'))
				newValue = changedPropertiesStruct.ValueDisplayVisible;
				
				% Convert true/false to on/off
				newValue = matlab.ui.control.internal.model.PropertyHandling.convertTrueFalseToOnOff(newValue);
				
				obj.Model.ValueDisplayVisible = newValue;
				
				% Mark the property as handled
				changedPropertiesStruct = rmfield(changedPropertiesStruct, 'ValueDisplayVisible');
			end
			
			% Call the superclass for unhandled properties
			handlePropertiesChanged@matlab.ui.control.internal.controller.TickComponentController(obj, changedPropertiesStruct);
			
        end
        
	end
	
end
