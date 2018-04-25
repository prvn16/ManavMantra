classdef ColorOrderEditor < ...
        internal.matlab.variableeditor.peer.editors.EditorConverter
    
    % This class is unsupported and might change or be removed without
    % notice in a future version.
    
    % ColorOrder EditorConverter class.  This class is used to provide a way
    % to convert from server-side color order representation of RGB color, where
    % RGB are 0:1, and client-side, which is represented in hex, where each
    % color is between 1:255.
    
    % Copyright 2015-2017 The MathWorks, Inc.
    
    properties
        colorOrder = ones(1,4);
        dataType;
    end
    
    methods
        function setServerValue(this, value, dataType, ~)
            if (~isempty(value))
                this.colorOrder = value;
            else
                this.colorOrder = ones(1,4);
            end
            this.dataType = dataType;
        end
        
        function setClientValue(this, value)
            if ischar(value)
                value = str2num(value); %#ok<ST2NM>
            end
            this.colorOrder = value;
        end
        
        function value = getServerValue(this)
            value = this.colorOrder;
        end
        
        function value = getClientValue(this)
            s = size(this.colorOrder);
            strs = cell(1, s(1));
            for r=1:s(1)
                cols = cell(1, s(2));
                for c=1:s(2)
                    cols{c} = num2str(this.colorOrder(r,c), 20);
                end
                strs{r} = strjoin(cols(:), ',');
            end
            value = ['[' strjoin(strs(:), ';') ']'];
        end
        
        function props = getEditorState(~)
            % Set metadata to false as we do not want contents to be cleared on click
            props = struct('isMetaData', false, ...
                'DnDSupported', false);
        end
        
        function setEditorState(~, ~)
        end
    end
end
