classdef OnOffSwitchStateEditor < internal.matlab.variableeditor.peer.editors.EditorConverter
    % This class is unsupported and might change or be removed without
    % notice in a future version.
    
    % OnOffSwitchStateEditor EditorConverter class. This converts between
    % 'false'/'true' from/for the client and server-side 'on','off'
    % values
    
    % Copyright 2017 The MathWorks, Inc.

    properties
        value;
    end

    methods
        % Called to set the client-side value
        function setClientValue(this, value)
            if(strcmp(value,'false'))
                this.value = 'off';
            else 
                this.value = 'on';
            end
        end
        
        % Called to get the server-side representation of the value
        function value = getServerValue(this)
             value = matlab.lang.OnOffSwitchState(this.value);
        end
                
        % Called to set the server-side value
        function setServerValue(this, value, ~, ~)
            this.value = value;
        end

        % Called to get the client-side representation of the value
        function value = getClientValue(this)
            value = this.value;
        end
             
        % Called to get the editor state.  Unused.
        function props = getEditorState(~)
            props = struct;
        end
        
        function setEditorState(~, ~)
        end        
    end
end
