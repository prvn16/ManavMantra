classdef NumericOrStringEditor < ...
        internal.matlab.variableeditor.peer.editors.EditorConverter
    
    % This class is unsupported and might change or be removed withoutc
    % notice in a future version.
        
    % Copyright 2015-2017 The MathWorks, Inc.
    
    properties
        value;
        propName;
    end
        
    methods
        function setServerValue(this, value, ~, propName)
            % Store the value as is
            this.value = value;
            this.propName = propName;
        end
        
        function setClientValue(this, value)
            % Store the value as is
            this.value = value;
        end
        
        function value = getServerValue(this)
            % Return the server value
            value = this.value;
            try
                c = eval(this.value);
                if iscell(c) && isscalar(c)
                    % treat scalar cell arrays as chars
                    value = c{1};
                end
            catch
            end
        end
        
        function value = getClientValue(this)
            if ischar(this.value)
                value = this.value;
            elseif iscellstr(this.value) && length(this.value) <= 1
                if isempty(this.value)
                    value = '';
                else
                    value = this.value{1};
                end
            else
                fdu = internal.matlab.variableeditor.FormatDataUtils;
                value = fdu.formatSingleDataForMixedView(this.value);
            end
        end
        
        function props = getEditorState(this)
            props = struct;
            props.editValue = this.value;
            if any(this.propName == ["String", "Title", "XLabel", "YLabel"]) && isempty(this.value)
                props.outputType = 'cell';
            end
        end
        
        function setEditorState(~, ~)
        end
    end
end