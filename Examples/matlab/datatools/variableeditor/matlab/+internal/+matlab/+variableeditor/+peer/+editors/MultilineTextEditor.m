classdef MultilineTextEditor < internal.matlab.variableeditor.peer.editors.EditorConverter
    % This class is unsupported and might change or be removed without
    % notice in a future version.
    
    % MultilineText EditorConverter class. This converts between
    % Java String arrays from/for the client and server-side cellstrs
    
    % Copyright 2017 The MathWorks, Inc.

    properties
        value;
    end

    methods
        % Called to set the client-side value
        function setClientValue(this, value)
            this.value = cell(value);
        end
        
        % Called to get the server-side representation of the value
        function value = getServerValue(this)
            value = internal.matlab.variableeditor.datatype.MultilineText(this.value);
        end
        
        
        % Called to set the server-side value
        function setServerValue(this, value, ~, ~)
            if isa(value, 'internal.matlab.variableeditor.datatype.MultilineText')
                this.value = value.getLines;
            else
                this.value = value;
            end
        end

        % Called to get the client-side representation of the value
        function value = getClientValue(this)
            % Avoid cell array processing by PeerInspectorViewModel, which
            % adds commas
            value = internal.matlab.variableeditor.peer.PeerUtils.toJSON(true, this.value);
        end

        
        % Called to get the editor state.  Unused.
        function props = getEditorState(~)
            props = struct;
        end

        % Called to set the editor state.  Unused.
        function setEditorState(~, ~)
        end
    end
end
