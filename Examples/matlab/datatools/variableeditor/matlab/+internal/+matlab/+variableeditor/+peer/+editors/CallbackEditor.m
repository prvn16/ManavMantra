classdef CallbackEditor < ...
        internal.matlab.variableeditor.peer.editors.EditorConverter
    
    % This class is unsupported and might change or be removed without
    % notice in a future version.
    
    % Copyright 2017 The MathWorks, Inc.
    
    properties
        value;
        formatDataUtils = internal.matlab.variableeditor.FormatDataUtils;
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
            if ~isempty(this.value)
                if startsWith(this.value, "@")
                    % Convert to function handle
                    value = str2func(this.value);
                elseif startsWith(this.value, "{") && endsWith(this.value, "}")
                    % User entered older-style callback, as a cell array.
                    % For example: {@cbfunc, val1, val2}
                    value = eval(this.value);
                else
                    % Use the value the user entered
                    value = this.value;
                end
            else
                % Apply no function handle as empty char ''
                value = '';
            end
        end
        
        % Called to get the client-side representation of the value
        function value = getClientValue(this)
            if iscell(this.value)
                % Before anonymous functions, callbacks were often
                % specified as cell arrays, for example:
                % obj.Fcn = {@mycallback val1 val2}
                % This will display as 1xN cell array
                value = this.formatDataUtils.formatSingleDataForMixedView(this.value);
            else
                % Otherwise, convert the function handle to text to display
                % in the inspector
                value = char(this.value);
                
                if isempty(value)
                    value = '';
                elseif ~startsWith(value, "@") && isa(this.value, 'function_handle')
                    % Non-anonymous function handles should still show with
                    % the '@' symbol to indicate they are function handles
                    value = ['@' value];
                end
            end
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