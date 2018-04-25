classdef DesignTimeGBTComponentController < ...		
		appdesigner.internal.controller.DesignTimeController & ...
		matlab.ui.internal.DesignTimeGBTControllerPositionMixin & ...
		matlab.ui.internal.DesignTimeGBTControllerFontMixin & ...
		matlab.ui.internal.DesignTimeGBTControllerViewPropertiesMixin
	%DESIGNTIMEGBTCOMPONENTCONTROLLER This is the super class for all
	%Visual Components' design time controllers.  It will act as a bridge
	%between the DesignTimeController which is the interface for all
	%components integrated with AppDesigner and each indivual visual
	%component.
	
	%  Copyright 2016-2017 The MathWorks, Inc.
	
	
	methods
		function obj = DesignTimeGBTComponentController(varargin)
			model = varargin{1};
			parentController = varargin{2};
			proxyView = varargin{3};
			
			if ~isempty(proxyView) && isempty(proxyView.PeerNode)
				% PeerNode is empty, and it's the case of loading an app.
				% Set proxyView back to empty because it's a no-op
				% proxyview
				% Todo: after moving design time logic out of VC
				% AbstractController, no need to check if ProxyView is
				% empty or not to determin design-time or runtime for
				% creating ProxyView, an empty ProxyView could be passed
				% into here without doing this weird setting back to empty
				proxyView = [];
			end
			
			obj = obj@matlab.ui.internal.DesignTimeGBTControllerPositionMixin(model, proxyView);
			obj = obj@matlab.ui.internal.DesignTimeGBTControllerFontMixin(model, proxyView);
			obj = obj@matlab.ui.internal.DesignTimeGBTControllerViewPropertiesMixin(model);
			
			obj = obj@appdesigner.internal.controller.DesignTimeController(model, proxyView);			

			obj.setParentController(parentController);
			obj.ProxyView = proxyView;
			
			% Now, inject the controller before calling update model from
			% view
			model.setControllerHandle(obj);
			
			if ~isempty(obj.ProxyView)
				% When ProxyView is not empty, it's in the design time
				obj.getEventHandlingService().attachView(obj.ProxyView);
				
				if ~proxyView.HasSyncedToModel
					% Initialize the model from the view upon creation of
					% component from client side
					obj.updateModelFromView(obj.ProxyView);
				end
			end
		end
	end
	
	methods(Access = 'protected')
		
		function model = getModel(obj)
			% GETMODEL( obj )
			% Method providing access to the model.
			model = obj.Model;
		end
		
		function handleDesignTimePropertiesChanged(obj, peerNode, valuesStruct)
			% This is required by the DesignTimeComponentController. This method
			% will take the data given by the DesignTimeController and form
			% data that can be used by the Tab and Tab Group controllers
			%
			% peerNode - The peerNode associated with this controller's
			%            component
			%
			% valuesStruct - This is a MATLAB struct with two fields 'oldValues'
			%            and 'newValues'.  Each of these fields contains a
			%            struct.  For this struct, each field is a changed
			%            property which contains it's appropriate value.
			
            % Filter out the properties which should not be set to the
            % component model
            % value not changed for those properties with corresponding
            % 'xxxMode' property
            % if the value passed in is the same as the value on the model 
            % object, and the corresponding 'xxxMode' value is 'auto'
            % Remove it to avoid unncessary setting to the model object. 
            % Otherwise a side effect is that during drag/drop creating a 
            % new component, 'xxxMode' property would be updated from 'auto'
            % to 'manual' regardless the value is the same as default value
            % or not. see g1627559
            includeHiddenProperty = true;
            priorModePropertyOnModel = false;
            valuesStruct = obj.handleChangedPropertiesWithMode(obj.Model, valuesStruct, includeHiddenProperty, priorModePropertyOnModel);
            
            % Start to handle property updating
			valuesStruct = handleSizeLocationPropertyChange(obj, valuesStruct);
			
			propertyList = fields(valuesStruct);			
			% Iterate over properties and update the component one property
			% at a time.
			for index = 1:numel(propertyList)
				propertyName = propertyList{index};
				updatedValue = valuesStruct.(propertyName);
				
				switch (propertyName)
					% For property updates that are common between run time
					% and design time, this method delegates to the
					% corresponding run time controller.
					case {'FontSize', 'FontName', 'FontAngle', 'FontWeight', 'FontUnits'}
						obj.handleFontUpdate(propertyName, updatedValue);
						
					case 'HandleVisibility'
						obj.handleCommonHGPropertyUpdated(propertyName, updatedValue);
                    case 'BusyAction'
                        obj.handleCommonHGPropertyUpdated(propertyName, updatedValue);
                    case 'Interruptible'
                        obj.handleCommonHGPropertyUpdated(propertyName, updatedValue);
					otherwise
						% set the property with propertySetData struct
						propertySetData.newValue = updatedValue;
						propertySetData.key = propertyName;
						
						obj.handleDesignTimePropertyChanged(peerNode, propertySetData);
				end
			end
		end
		
		function handleDesignTimeEvent(~, ~, ~)
			% Handler for 'peerEvent' from the Peer Node
			
			% no-op for GBT component by default
			% GBT components, except UIAxes don't have design time
			% 'peerEvent' to handle.
			% UIAxes uses server-side to set property value through
			% 'peerEvent', instead of client-side driven 'propertiesSet'
			% event.
		end
		
		function handleDesignTimePropertyChanged(obj, ~, data)
			
			% handleDesignTimePropertyChanged( obj, peerNode, data )
			% Controller method which handles property updates in design time.
			% This is a default implementation for updating value to the
			% property on the server model directly, and the individual
			% subclass of each component could overrid it to handle
			% specific properties, and then call base class to deal with
			% others
			
			% Handle property updates from the client
			
			updatedProperty = data.key;
			updatedValue = data.newValue;
			
			if isprop(obj.Model, updatedProperty)
				% Checking to filter DesignTime property out, e.g.
				% CodeName, GroupId
				obj.Model.(updatedProperty) = updatedValue;
			end
		end
		
		function handleCommonHGPropertyUpdated(obj, propertyName, updatedValue)
			% Handle common HG property updating
			switch (propertyName)
				case 'HandleVisibility'
					obj.Model.HandleVisibility = updatedValue;
                case 'BusyAction'
                    obj.Model.BusyAction = updatedValue;
                case 'Interruptible'
                    obj.Model.Interruptible = updatedValue;    
					
				otherwise
					% no-op
			end
        end
        
		function updateModelFromView(obj, proxyView)
			% UPDATEMODELFROMVIEW( obj, model, proxyView )
			% Updates the model from view for relevant design-time/run-time properties.
			% this only called when we drag and drop the component to the
			% canvas
			
			% Apply the state of the view to the model
			%
			% This is done in a view-driven workflow where the model
			% needs to be hooked up to the view
			viewPropertyStruct = proxyView.getProperties();
            
			% leverages controllers logic of handling property changes
			% to update the model
			obj.handleDesignTimePropertiesChanged(proxyView.PeerNode, viewPropertyStruct);
		end
		
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
			
			% Size, Location, OuterSize, OuterLocation, AspectRatioLimits, Parent
			viewPvPairs = [viewPvPairs, ...
				getPositionPropertiesForView(obj, propertyNames);
				];
		end
		
		function additionalPropertyNames = getAdditionalPropertyNamesForView(obj)
			% Get the list of additional properties to be sent to the view
			
			additionalPropertyNames = {};
			
			% Position related properties
			additionalPropertyNames = [additionalPropertyNames; ...
				obj.getAdditonalPositionPropertyNamesForView();...
				];
		end
		
		function excludedPropertyNames = getExcludedPropertyNamesForView(obj)
			excludedPropertyNames = {};
			
			excludedPropertyNames = [excludedPropertyNames; ...
				obj.getExcludedPositionPropertyNamesForView(); ...
				];
		end
    end
end

