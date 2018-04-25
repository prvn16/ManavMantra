classdef TicksEditorConverter < internal.matlab.variableeditor.peer.editors.EditorConverter
    
    % Copyright 2017 The MathWorks, Inc.
    
    properties
        dataType
        value
        Name
        format
        limitsValue
    end
    
    methods
        function setServerValue(this, value, dataType, propName)
            % Store the value and dataType
            this.value = value;
            this.dataType = dataType.Name;
            this.Name = propName;
        end
        
        function setClientValue(this, value)
            % If the value is a char, then the user typed in a value into the inspector text field, so we'll try to evaluate it (something like 1:10).
            if ischar(value)
                value = evalin('base',value);
            elseif iscell(value) && ~strcmp(this.dataType, 'internal.matlab.variableeditor.datatype.TicksLabelType')
                if isnumeric(this.value)
                    %If the value is a cell, then its coming from the ticks editor table.  If it is not tick labels, use cell2mat to convert it to numeric.
                    value = cell2mat(value);
                elseif isdatetime(this.value)
                    if ~isempty(value) % empty will result in NaT
                        value = datetime(char(value), ...
                            'InputFormat', this.format);
                    end
                elseif isduration(this.value)
                    if ~isempty(value) % empty will result in NaT
                        v = [];
                        for i=1:numel(value)  
                            iFormat = this.format;
                            if isempty(this.value)
                                % the value could be empty, meaning that there are no ticks. In this case
                                % rely on the limits format because the first tick to be added is calculated based on the lowest limit
                                iFormat = this.limitsValue.Format;
                            end
                            v =[v internal.matlab.datatoolsservices.VariableConversionUtils.getDurationFromText(value{i},iFormat)]; %#ok<AGROW>
                        end
                        value = v;
                    end
                end
            end
            
            this.value = value(:)';
        end
        
        function value = getServerValue(this)
            value = this.value;
        end
        
        function value = getClientValue(this)
            % Get the client value, using FormatDataUtils since it is
            % typically a cellstr                        
            if iscell(this.value)
                % cell array is sent for labels
                fdu = internal.matlab.variableeditor.FormatDataUtils;
                value = fdu.formatSingleDataForMixedView(this.value);
            elseif isnumeric(this.value)                
                fdu = internal.matlab.variableeditor.FormatDataUtils;
                value = fdu.formatSingleDataForMixedView(this.value);
                value = value{1};
            else
                value = char("[" + strjoin("""" + cellstr(this.value) + """", ',') + "]");
            end
        end
        
        function props = getEditorState(this)
            
            props = struct;
            props.richEditor = 'inspector/editors/TicksEditor/TicksDialogEditor';
            props.isNumeric = isnumeric(this.value);
            props.readOnlyTicks = iscategorical(this.value);
            % This property ensures that empty metaData value for
            % X/Y/ZTickLabel property is not committed by TextBoxEditor g1675346
            props.doCommitEmptyMetaData = false;
            
            val = this.value;
            
            if ~props.isNumeric
                val =  char("[" + strjoin("""" + cellstr(this.value) + """", ',') + "]");
            end
            
            props.editValue = val;
            % There is no clear way to know what the Tick - related
            % properties are for a component, so we will need to explicitly
            % look for MajorTicks.  if present, assume it is gauge.
            % Otherwise, it is an axes
            %
            % Should genericize this so it can ask the component what the
            % properties are, or consider a different converter / data type
            % for the different objects
            if(strcmp(this.Name, 'MajorTicks'))
                % Assume its Gauge or Slider
                props.richEditorDependencies = {'Limits', 'MajorTicksMode', 'MajorTickLabelsMode', 'MajorTicks', 'MajorTickLabels'};
            elseif startsWith(this.Name, {'x','y','z','r','theta'},'IgnoreCase',1)
                % Assume its XTick, YTick, ZTick, etc...                                
                if startsWith(this.Name,'Theta')
                    prefix = 'Theta';
                else                
                    prefix = this.Name(1); % X,Y,Z,R                                
                end
                props.richEditorDependencies = {[prefix,'Lim'], [prefix,'TickMode'], [prefix,'TickLabelMode'], [prefix,'Tick'], [prefix,'TickLabel']};
            else
                %colorbar
                 props.richEditorDependencies = {'Limits', 'TicksMode', 'TickLabelsMode', 'Ticks', 'TickLabels'};
                
            end
        end
        
        function setEditorState(this, props)
            this.value = props.currentValue;
            this.dataType = props.dataType;
            
            % Only duration plots need to store the limits value.
            %
            % For duration rulers we need to store dependent property in
            % order to query the format of its limits when there are no
            % ticks
            if isfield(props,[this.Name(1),'Lim'])
                this.limitsValue = props.([this.Name(1),'Lim']);
            end
            
            if isdatetime(props.currentValue) || ...
                    isduration(props.currentValue)
                this.format = props.currentValue.Format;
            end
            
        end
    end
    
end
