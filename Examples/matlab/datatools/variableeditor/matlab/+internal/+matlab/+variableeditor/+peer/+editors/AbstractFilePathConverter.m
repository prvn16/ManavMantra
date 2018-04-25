classdef AbstractFilePathConverter < ...
        internal.matlab.variableeditor.peer.editors.EditorConverter
    % This class is unsupported and might change or be removed without
    % notice in a future version.
    
    % AbstractFilePathConverter EditorConverter class. This class allows 
    % the client to trigger file browsing on the server side
    
    % Copyright 2017 The MathWorks, Inc.

    properties
        value;
        dataType;
    end
    
    % invalid path characters used for signals
    properties(Constant = true)
        BROWSE_CHAR = '?';
    end
    
    methods (Abstract)
        % Called to set the client-side value
        setClientValue(this, value)
    end

    methods
        % Called to get the server-side representation of the value
        function value = getServerValue(this)
            % converts char to file path datatype
            value = feval(this.dataType, this.value);
        end
        
        
        % Called to set the server-side value
        function setServerValue(this, value, dataType, ~)
            if isa(value, dataType.Name)
                this.value = value.getPath;
            else
                this.value = value;
            end
        end
        
        % Called to get the client-side representation of the value
        function value = getClientValue(this)
            % adding an extra whitespace to force client value change
            value = [this.value ' '];
        end

        
        % Called to get the editor state.  Unused.
        function props = getEditorState(~)
            props = struct;
        end

        % Called to set the editor state.
        function setEditorState(this, props)
            this.dataType = props.dataType;
            if isa(props.currentValue, this.dataType)
                this.value = props.currentValue.getPath;
            else
                this.value = props.currentValue;
            end
            if isempty(this.value)
                this.value = '';
            end
        end
    end
    
    methods(Access = protected)
        % extracts the args for uigetfile from the browse message
        function args = getArgs(this, value)
            filter = '*';
            title = '';
            % set name to the editor's current value
            name = which(this.value);
            if isempty(name)
                name = this.value;
            end
            
            if length(value) > 1
                % valueParts = [ filter[, title] ]
                valueParts = split(value(2:end), ':');
                
                filter = split(valueParts{1}, ',');
                if length(filter) > 1
                    filter = reshape(filter, 2, [])';
                end
                
                if length(valueParts) > 1
                    title = valueParts{2};
                end
            end
            
            args = {filter title name};
        end
    end
end
