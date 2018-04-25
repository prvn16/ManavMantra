classdef TextTypeEditor < ...
        internal.matlab.variableeditor.peer.editors.EditorConverter
    
    % This class is unsupported and might change or be removed without
    % notice in a future version.
    
    % Copyright 2017 The MathWorks, Inc.
    
    properties
        value;
    end
    
    methods
        % Called to set the server-side value
        function setServerValue(this, value, ~, ~)
            this.value = value;
        end
        
        % Called to set the client-side value
        function setClientValue(this, value)
            this.value = value;
        end
        
        % Called to get the server-side representation of the value
        function value = getServerValue(this)
            if isempty(this.value)
                value = '''''';
            else
                value = this.value;
                if ~startsWith(value, "'") && ~endsWith(value, "'")
                    value = "'" + value + "'";
                end
                value = char(value);
            end
        end
        
        % Called to get the client-side representation of the value
        function value = getClientValue(this)
            value = this.value;
        end
        
        % Called to get the editor state, which contains properties
        % specific to the editor
        function props = getEditorState(~)
            props = [];
        end
        
        % Called to set the editor state, which are properties specific to
        % the editor
        function setEditorState(~, ~)
        end
    end
end