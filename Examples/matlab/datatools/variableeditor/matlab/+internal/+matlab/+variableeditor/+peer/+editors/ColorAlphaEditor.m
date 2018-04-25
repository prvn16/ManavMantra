classdef ColorAlphaEditor < internal.matlab.variableeditor.peer.editors.EditorConverter
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
            if(str2double(value)>=0 && str2double(value)<=1)
                this.value = str2double(value);
            else 
                this.value = value;
            end
        end
        
        % Called to get the server-side representation of the value
        function value = getServerValue(this)
             value = this.value;
        end
                
        % Called to set the server-side value
        function setServerValue(this, value, ~,~)
            this.value = value;
        end

        % Called to get the client-side representation of the value
        function value = getClientValue(this)
            if isnumeric(this.value)
              value = num2str(this.value);
            else
              value = this.value;
            end
        end
             
        % Called to get the editor state.  Unused.
        function props = getEditorState(~)
            props = struct;
        end
        
        function setEditorState(~, ~)
        end        
    end
end
