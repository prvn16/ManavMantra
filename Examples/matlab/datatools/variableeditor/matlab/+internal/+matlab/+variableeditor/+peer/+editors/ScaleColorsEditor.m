classdef ScaleColorsEditor < internal.matlab.variableeditor.peer.editors.EditorConverter
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
            if iscell(value)
                this.value = cell2mat(value);
            else
                try
                    this.value = evalin('base', ['[' value ']']);
                    if ischar(this.value)
                        this.value = evalin('base', ['{' value '}']);
                    end
                catch
                    this.value = value;
                end

                if isequal(this.dataType, 'internal.matlab.variableeditor.datatype.ScaleColors') && ...
                        ((ischar(this.value) && isvector(this.value)) || (isstring(this.value) && isscalar(this.value)))
                    % Convert ' r, g b ' to {'r' 'g' 'b'} for colors
                    this.value = strsplit(strtrim(this.value), ',|;|\s*', ...
                        'DelimiterType', 'RegularExpression');
                elseif isequal(this.dataType, 'internal.matlab.variableeditor.datatype.ScaleColorLimits') && ...
                        isvector(this.value) && length(this.value) > 2 && isnumeric(this.value)
                    % Convert [1 2 3 4] to [1 2; 2 3; 3 4] for limits
                    lims = ones(length(this.value) - 1, 2);
                    for i = 1:length(this.value) - 1
                        lims(i, :) = this.value(i:i+1);
                    end
                    this.value = lims;
                end
            end
        end

        % Called to get the server-side representation of the value
        function value = getServerValue(this)
            value = feval(this.dataType, this.value);
        end


        % Called to set the server-side value
        function setServerValue(this, value, ~, ~)
            if isa(value, 'internal.matlab.variableeditor.datatype.ScaleColors')
                this.value = value.getColors;
            elseif isa(value, 'internal.matlab.variableeditor.datatype.ScaleColorLimits')
                this.value = value.getLimits;
            else
                this.value = value;
            end
        end

        % Called to get the client-side representation of the value
        function value = getClientValue(this)
            value = this.value;
        end


        % Called to get the editor state.  Unused.
        function props = getEditorState(~)
            props = struct;
            props.richEditor = 'inspector/editors/ScaleColorsEditor/ScaleColorsEditor';
            props.richEditorDependencies = {'ScaleColors', 'ScaleColorLimits', 'Limits'};
        end

        % Called to set the editor state.
        function setEditorState(this, props)
            this.dataType = props.dataType;
        end
    end
end
