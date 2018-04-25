classdef LineStyleOrderEditor < ...
        internal.matlab.variableeditor.peer.editors.EditorConverter
    
    % This class is unsupported and might change or be removed withoutc
    % notice in a future version.
        
    % Copyright 2015 The MathWorks, Inc.
    
    properties
        lineStyleOrder;
    end
        
    methods
        function setServerValue(this, value, ~, ~)
            % Store the line style order value as is
            this.lineStyleOrder = value;
        end
        
        function setClientValue(this, value)
            % Client value is a comma separated list, convert to semicolons
            % for the setData code, which converts it to a cell array
            this.lineStyleOrder = strrep(value, ',', ';');
        end
        
        function value = getServerValue(this)
            % Return the server value
            value = this.lineStyleOrder;
        end
        
        function value = getClientValue(this)
            % Returns the client value as a cell array
            if ~iscell(this.lineStyleOrder)
                % convert the char array into a cell array 
                value = num2cell(this.lineStyleOrder, 2);
            else
                value = this.lineStyleOrder;
            end
        end
        
        function props = getEditorState(~)
            props = [];
        end
        
        function setEditorState(~, ~)
            % Line style order editor has no editor state
        end
    end
end