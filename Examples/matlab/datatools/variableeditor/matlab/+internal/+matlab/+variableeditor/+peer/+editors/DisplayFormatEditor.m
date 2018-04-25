classdef DisplayFormatEditor < internal.matlab.variableeditor.peer.editors.EditorConverter
    % This class is unsupported and might change or be removed without
    % notice in a future version.
    
    % Display Format EditorConverter class.
    
    % Copyright 2017 The MathWorks, Inc.

    properties
        value;
    end

    methods
        % Called to set the client-side value
        function setClientValue(this, value)
            this.value = char(value);
        end
        
        % Called to get the server-side representation of the value
        function value = getServerValue(this)
            try
                value = internal.matlab.variableeditor.datatype.DisplayFormat(evalin('base', this.value));
            catch
                value = internal.matlab.variableeditor.datatype.DisplayFormat(this.value);
            end
        end
        
        
        % Called to set the server-side value
        function setServerValue(this, value, dataType, ~)
            if isa(value, 'internal.matlab.variableeditor.datatype.DisplayFormat')
                this.value = value.getFormat;
            else
                this.value = value;
            end
        end

        % Called to get the client-side representation of the value
        function value = getClientValue(this)
            value = this.value;
        end

        
        % Called to get the editor state.  Unused.
        function props = getEditorState(~)
            props = struct;
            props.richEditor = 'inspector/editors/DisplayFormatEditor/DisplayFormatEditor';
        end

        % Called to set the editor state.  Unused.
        function setEditorState(~, ~)
        end
    end
end
