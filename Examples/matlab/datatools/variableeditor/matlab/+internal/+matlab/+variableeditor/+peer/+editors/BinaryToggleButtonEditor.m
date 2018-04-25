classdef BinaryToggleButtonEditor < ...
		internal.matlab.variableeditor.peer.editors.EditorConverter
	
	% This class is unsupported and might change or be removed without
	% notice in a future version.
	
	% This class provides the editor conversion needed for string
	% enumerated values to toggle buttons
	
	% Copyright 2017 The MathWorks, Inc.
	
	properties
		% Current value on the server
		value;
		
		% class path of the data type being edited
		dataType;
	end
	
	methods
		
		% Called to set the server-side value
		function setServerValue(this, value, dataType, ~)
			this.value = value;
			this.dataType = dataType;
		end
		
		% Called to get the server-side representation of the value
		function value = getServerValue(this)
			value = this.value;
		end
		
		
		% Called to set the client-side value
		function setClientValue(this, value)
			this.value = value;
		end			
		
		% Called to get the client-side representation of the value
		function varValue = getClientValue(this)
			varValue = this.value;
		end
		
		% Called to get the editor state, which contains properties
		% specific to the editor
		function props = getEditorState(this)
			% Returns the following properties
			%
			% enumeratedValues - list of programmatic values for the
			% enumerated type
			%
			% icons            - list of icon information, encoded in
			%                    base64 URls
			props = struct;
			
			% Get the possible values from the data type
			props.enumeratedValues = eval([this.dataType.Name, '.EnumeratedValues']);
			
			% Get the icon files from the data type
			iconPath = eval([this.dataType.Name, '.IconPath']);
			
			% Convert them to a base 64 URL
			props.icon = appdesservices.internal.peermodel.convertImageToBase64URL(iconPath);												
			
		end
		
		% Called to set the editor state.  Unused.
		function setEditorState(~, ~)
		end
	end
	
end

