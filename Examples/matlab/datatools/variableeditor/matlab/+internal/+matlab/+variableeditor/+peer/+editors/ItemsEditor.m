classdef ItemsEditor < internal.matlab.variableeditor.peer.editors.EditorConverter
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

            % TODO: implmenet server side logic
            this.value = value;
        end

        % Called to get the server-side representation of the value
        function value = getServerValue(this, ~, ~, ~)

            % TODO: implmenet server side logic
            value = this.value;
        end


        % Called to set the server-side value
        function setServerValue(this, value, dataType, ~)

            % TODO: implmenet server side logic
            this.value = value;
            this.dataType = dataType;
            
        end

        % Called to get the client-side representation of the value
        function value = getClientValue(this)

            % TODO: implmenet server side logic
            value = this.value;
        end


        % Called to get the editor state.  Unused.
        function props = getEditorState(this)
            props = struct;
            props.richEditor = 'inspector/editors/ItemsEditor/ItemsEditor';
            props.richEditorDependencies = {'SelectedIndex', 'Items'};
            minNumber = eval([this.dataType.Name, '.MinNumber']);
            maxNumber = eval([this.dataType.Name, '.MaxNumber']);
            defaultNameKey = eval([this.dataType.Name, '.DefaultNameKey']);
            if ~isempty(minNumber)
                props.minNumber = minNumber;
            end
            
            if ~isempty(maxNumber)
                props.maxNumber = maxNumber;
            end
            
            if ~isempty(defaultNameKey)
                props.defaultNameKey = defaultNameKey;
            end

            props.outputType = 'array';

        end

        % Called to set the editor state.
        function setEditorState(this, props)
            this.dataType = props.dataType;
        end
    end
end
