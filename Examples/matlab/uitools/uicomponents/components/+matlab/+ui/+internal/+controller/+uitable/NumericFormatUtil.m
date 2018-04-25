classdef NumericFormatUtil < handle
    %NUMERICFORMATUTIL 
    % Format Numbers according to MATLAB FORMAT command rules.
    
    % @ToDo short-term ues 
    % only for web uitable's numeric values by column and keep char values
    % as is.
    % Probably refactor to VariableEditor code
    
    properties (Access='private')
        savedFormat = '';
        MATLAB_Formats = {'short', 'long', 'shorte', 'longe', ...
                        'shortg', 'longg', 'shorteng', 'longeng', ...
                        'hex', '+', 'bank', 'rat', 'compact', 'loose'};
    end
    
    methods
        % Currently format numeric data by column
        % Only format numeric values and keep characters as is.
        function formated = formatColumnNumbers(this, data, formatID)
            
            % empty cases
            if isempty(data)
                formated = {''};
                return;
            end
            
            this.savedFormat = get(0, 'format');
                         
            if this.isValidNumericFormat(formatID)
                % FORMAT numbers with given format ID.
                format(formatID);
            end % otherwise use the current MATLAB format.
            
            if isnumeric(data)
                %%%%%
                % a short term solution for g1439579 to minimize the risk
                % of regression during the end of 16b LCM.
                % TODO Need to refactor this code to use the utilities in 
                % internal.matlab.variableeditor.FormatDataUtils
                %%%%%
                formated = cell(size(data));
                
                for row = 1:size(data, 1)
                    formated{row, 1} = strtrim(evalc('disp(data(row))')); 
                end
            else            
            
                % Display and get column data in a particular format
                r=evalc('disp(data)');
                textformat = ['%s', '%*[\n]'];
                result=strtrim(textscan(r,textformat,'Delimiter',''));
                formated = result{1,1};

                if isnumeric(data) || islogical(data) 
                    % numeric column input - No need to post-process
                elseif iscell(data) % cell array column input
                    % post-process to peel off square brackets for numeric values
                    % and keep char values as is.
                    for row = 1:length(data)
                        value = data{row, 1};
                        if isempty(value)
                            formated{row, 1} = '';
                        elseif isnumeric(value) || islogical(value)
                            formated{row, 1} = formated{row, 1}(2:end-1);
                        elseif ischar(value)
                            formated{row, 1} = value;
                        end
                    end
                else    % only support numeric array and cell array for now
                    assert(false);
                end
            end
            
            formated = strtrim(formated);
            
            %teardown
            format(this.savedFormat);
        end
        
        % validate if input is a valid MATLAB numeric format as defined above.
        function isValid = isValidNumericFormat(this, format)
            isValid = false;
            
            if ischar(format)
                isValid = ismember(format, this.MATLAB_Formats);
            end
        end        
        
        % validate if a char string or cell array of formats HAS
        % valid MATLAB numeric formats as defined above.
        function hasValid = hasValidNumericFormat(this, format)
            hasValid = false;
            
            if ischar(format)
                hasValid = ismember(format, this.MATLAB_Formats);
            elseif iscell(format)
                for i = 1:numel(format)
                    hasValid = this.isValidNumericFormat(format{i});
                    if hasValid
                        return;
                    end
                end
            end
        end 
        
        function formats = getMATLABNumericFormats(this)
            formats = this.MATLAB_Formats;
        end
    end
end