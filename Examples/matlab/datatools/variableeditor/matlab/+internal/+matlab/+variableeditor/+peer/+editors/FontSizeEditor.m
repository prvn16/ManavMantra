classdef FontSizeEditor < ...
        internal.matlab.variableeditor.peer.editors.EditorConverter
    
    % This class is unsupported and might change or be removed without
    % notice in a future version.
    
    % This class provides the editor conversion needed for categoricals and
    % enumerations.
    
    % Copyright 2015 The MathWorks, Inc.

    properties
        value;
        dataType;
    end
    
    methods
        
        % Called to set the server-side value
        function setServerValue(this, value, dataType, ~)
            this.value = value;
            this.dataType = dataType;
        end
        
        % Called to set the client-side value
        function setClientValue(this, value)
            % Add back the quotes for
            % enumeration/categoricals
            this.value = ['''' value ''''];
        end
        
        % Called to get the server-side representation of the value
        function value = getServerValue(this)
            value = this.value;
        end
        
        % Called to get the client-side representation of the value
        function varValue = getClientValue(this)
            % Remove quotes from value if scalar (otherwise its a
            % summary value like 1x5 categorical)
            varValue = this.value;
            if isscalar(this.value) || ischar(this.value)
                if ~ischar(this.value)
                    varValue = char(this.value);
                end
                
                varValue = strrep(varValue, '''', '');
            end
        end
        
        % Called to get the editor state, which contains properties
        % specific to the editor
        function props = getEditorState(this)
            props = struct;
            props.categories = {'8';'9';'10';'11';'12';'14';'16';'18';'20';'22';'24';'26';'28';'36';'48';'72'};
            props.isProtected = false;
            props.showUndefined = false;
        end
        
        % Called to set the editor state.  Unused for the combobox editor.
        function setEditorState(~, ~)
        end
    end
end