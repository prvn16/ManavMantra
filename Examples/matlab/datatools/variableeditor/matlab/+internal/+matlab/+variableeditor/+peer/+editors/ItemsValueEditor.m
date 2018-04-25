classdef ItemsValueEditor < internal.matlab.variableeditor.peer.editors.EditorConverter
    % This class is unsupported and might change or be removed without
    % notice in a future version.

    % Copyright 2017 The MathWorks, Inc.

    properties
        value;
        dataType;
    end

    methods
        % Called to set the client-side value
        function setClientValue(this, value)
            this.value = value;
        end

        % Called to get the server-side representation of the value
        function value = getServerValue(this, ~, ~, ~)
            value = this.value;
        end


        % Called to set the server-side value
        function setServerValue(this, value, dataType, ~)
            this.value = value;
            this.dataType = dataType;
            
        end

        % Called to get the client-side representation of the value
        function value = getClientValue(this)
            value = this.value;
        end

        % Called to get the editor state.  Unused.
        function props = getEditorState(this)
            props = struct;
            props.outputType = 'array';

        end

        % Called to set the editor state.
        function setEditorState(this, props)
            this.dataType = props.dataType;
        end
    end
end
