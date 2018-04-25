classdef (Hidden) IconableComponentController < ...
		appdesservices.internal.interfaces.controller.AbstractControllerMixin
	
	% IconableComponentController class is the controller class for
	% matlab.ui.control.internal.model.mixin.IconableComponent object.
	
	% Copyright 2011-2015 The MathWorks, Inc.
	
	methods(Access = 'protected')
		
		function handleEvent(obj, src, event)
			
			if(strcmp(event.Data.Name, 'PropertyEditorEdited'))
				% Handle changes in the property editor that needs a
				% server side validation
				
				propertyName = event.Data.PropertyName;
				propertyValue = event.Data.PropertyValue;
				
				if(strcmp(propertyName, 'Icon'))
                    
					% Button.Icon should not have any path
					% messes up packaging, so truncate any path
					% from the filename.
					[~, file, ext] = fileparts(propertyValue);
					imageFileName = [file ext];
					
					% Just after stripping the path / directory from the file
					% Explicitly check, If the file exists on the MATLAB PATH
					%
					% AppDesigner accepts the files (icon / image in this case) on
					% the Matlab path ONLY. The reason for for not
					% accepting files which are not on the path is problems during packaging the app.
					%
					% Therefore, if it does not exists on the MATLAB path ,
					% send message to the user " Add the file on the path "
					% g1515118
					
					isEmptyFileName = isempty(propertyValue) && isa(propertyValue,'char');
					
					if (~isEmptyFileName)
						if ~exist(imageFileName, 'file')
							
							ex = MException(message('MATLAB:ui:components:fileNotFoundOnMatlabPath'));
							
							propertySetFail(obj, ...
								propertyName, ...
								event.Data.CommandId, ...
								ex);
							
						end
					end
					
					setModelProperty(obj, ...
						propertyName, ...
						imageFileName, ...
						event ...
						);
				end
			end
		end
		
		function unhandledPropertyValuesStruct = handlePropertiesChanged(obj, changedPropertiesStruct)
			% Handles Icon property changing
			
			% Initialize struct
			unhandledPropertyValuesStruct = changedPropertiesStruct;
			
			% Handle Icon property from peer node
			% handlePropertiesChanged() for this class gets called in two cases:
			% 1. when a component with an icon property gets dragged and
			% dropped off the palette.  In this case, the Icon property
			% is not set
			% 2. when an app that contains an iconable component is opened.
			% The Icon property may be set.
			if(isfield(changedPropertiesStruct, 'Icon'))
				try
					obj.Model.Icon = changedPropertiesStruct.Icon;
				catch ex
					% Turn off callstack for warning: by default the
					% warning will include the callstack
					w = warning('off', 'backtrace');
					
					% Exception happens for the possible reasons:
					% 1) Image file not in the MATLAB search path;
					% 2) Image file is deleted;
					% 3) Image file is damaged and not a valid image
					% format.
					% At such a case, load an app as possible as App Designer
					% could, and so set Icon to PrivateIcon directly to
					% avoid value validation, and warn the user
					obj.Model.PrivateIcon = changedPropertiesStruct.Icon;
					
					warning(ex.identifier, ex.message);
					% Restore warning state
					warning(w);
				end
				
				% Give others the chance to handle the remaining properties
				unhandledPropertyValuesStruct = rmfield(changedPropertiesStruct, 'Icon');
			end
		end
	end
	
	methods
		
		function viewPvPairs = getIconPropertiesForView(obj, propertyNames)
			% GETPICONROPERTIESFORVIEW(OBJ, PROPERTYNAME) returns view-specific
			% properties related to displaying an icon, given the PROPERTYNAMES
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
			
			if(any(strcmp('Icon', propertyNames)))
			    model = obj.Model;
                
                if ~isempty(model.PrivateCachedImageFileInfo) &&...
                        isempty(model.PrivateCachedImageContent)
                    % Read file if it has never been read, otherwise, use
                    % cached version
                    model.PrivateCachedImageContent = appdesservices.internal.peermodel.convertImageToBase64URL(model.PrivateCachedImageFileInfo);
                
                end
                
                if isempty(model.PrivateCachedImageContent)
                    
                    iconPvPairs = {...
							'IconURL', '', ...
							'IconWidth', 0, ...
							'IconHeight', 0 ...
							};
                        
                else
                    
                    pID = model.PrivateCachedImageContent;
                    iconPvPairs = {
                        'IconURL', pID.IconURL, ...
                        'IconWidth', pID.IconWidth, ...
                        'IconHeight', pID.IconHeight, ...
                    };	
                end
                               				
                
				viewPvPairs = [viewPvPairs, ...
					iconPvPairs, ...
					];
			end
			
		end
	end
	
end


