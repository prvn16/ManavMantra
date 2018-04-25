classdef VectorDataConverter < internal.matlab.variableeditor.peer.editors.EditorConverter
    % This class is unsupported and might change or be removed without
    % notice in a future version.
    
    % Copyright 2017 The MathWorks, Inc.
    
    properties
        value;
        formatDataUtils;
    end
    
    methods
        function this = VectorDataConverter
            this.formatDataUtils = internal.matlab.variableeditor.FormatDataUtils;
        end
        
        % Called to set the server-side value
        function setServerValue(this, value, ~, ~)
            this.value = value;
        end
        
        % Called to set the client-side value
        function setClientValue(this, value)
            if isempty(value)
                this.value = [];
            else
                this.value = nan(1, length(value));

                for i = 1:length(value)
                    if iscell(value)
                        val = value{i};
                    else
                        val = value(i);
                    end
                    if isnumeric(val)
                        % Convert text to double
                        this.value(i) = double(val);
                    else
                        % try to eval the value (the user could have typed
                        % in 'pi')
                        try
                            this.value(i) = evalin('base', val);
                        catch
                            % Use the nan which is already in place
                        end
                    end
                end
            end
            
            if length(this.value) == 1 && isnan(this.value) && isempty(value{1})
                % Use [] for a single empty numeric input instead of NaN
                this.value = [];
            end
        end
        
        % Called to get the server-side representation of the value
        function value = getServerValue(this)
            value = this.value;
        end
        
        % Called to get the client-side representation of the value
        function value = getClientValue(this)
            if isempty(this.value)
                value = '';
            else
                value = this.formatDataUtils.formatSingleDataForMixedView(this.value);
            end 
        end
        
        function props = getEditorState(~)
            props = [];
        end
        
        function setEditorState(~, ~)
        end
    end
end
