classdef UITableCellEditingHandler < handle
    % UITABLECELLEDITINGHANDLER class is to handle cell editing from
    % UITable view. 
    
    properties (Access='private')
        Model;
        editableDataTypesInTable = {'double', 'logical', 'char', 'string', 'datetime', 'categorical'};
    end
        
    
    methods
        
        function this = UITableCellEditingHandler (model)
            this.Model = model;
        end
        
        function handleCellEditFromClient(this, editValue, row, column, varargin)            
            if istable(this.Model.Data)
                % cell edit on table data.
                this.handleCellEditOnTableData(editValue, row, column, varargin{1});
            else
                % cell edit on legacy data types 
                % - numeric array, logical array and cell array of numeric, logical and char,
                if ~isequal(str2double(editValue), this.Model.Data(row, column))
                    % Call Model to set data and trigger cell edit
                    % callback.
                    this.Model.setEditingCellFromClient([row column], editValue, [], [], []);                               
                end                    
            end
        end
        
        % cell edit handler for table data.
        % only following data types are editable in table.
        %   - numeric
        %   - logical
        %   - char
        %   - string
        %   - datetime
        %   - categorical
        function handleCellEditOnTableData (this, editValue, row, column, columnIndex)
            
            oldValue = this.getValueAt(row, column, columnIndex);
            newValue = [];
            err = [];
            
            if ~ismember(class(oldValue), this.editableDataTypesInTable)
                % not valid for editing.
                return;
            end
            
            % validate and conversion
            switch class(oldValue)
                case 'double'
                    newValue = str2double(editValue);
                case 'logical'
                    editValue = logical(str2double(editValue));
                    newValue = editValue;
                case 'char'
                    newValue = char(editValue);
                case 'string'
                    newValue = string(editValue);
                case 'datetime'
                    editValue = this.removeSingleQuotes(editValue);
                    [newValue, err] = this.constructDatetimeFromText(editValue, row, column);
                case 'categorical'
                    % char value from client.
                    editValue = this.removeSingleQuotes(editValue);
                    newValue = editValue;
                        
                otherwise
                    % no other data types is allowed to be edited.
                    assert(false);
            end
            
            % set newValue to model data.
            try
                newValue = this.setValueAt(newValue, row, column, columnIndex);
            catch e
                err = e;
            end

            
            % Fire cell edit callback in c++ model.
            if size(this.Model.Data.(column), 2) > 1
                % multi-column variables.
                multiNewValue = this.getValueAt(row, column);                
                multiOldValue = multiNewValue;
                multiOldValue(columnIndex) = oldValue;
                
                this.Model.setEditingCellFromClient([row column], editValue, multiOldValue, multiNewValue, err);
            else            
                this.Model.setEditingCellFromClient([row column], editValue, oldValue, newValue, err);
            end
        end
    end
    
    methods (Access='protected')
        
        function value = getValueAt(this, row, column, varargin)
            if isempty(varargin)
                % may get all cells of sub columns.
                if iscell(this.Model.Data.(column))
                    value = this.Model.Data.(column){row, :};
                else
                    value = this.Model.Data.(column)(row, :);
                end 
            else
                % get single cell using sub column index.
                columnIndex = varargin{:};
                if iscell(this.Model.Data.(column))
                    value = this.Model.Data.(column){row, columnIndex};
                else
                    value = this.Model.Data.(column)(row, columnIndex);
                end        
            end
        end
        
        function retValue = setValueAt(this, newValue, row, column, columnIndex)
            %%%%%%%%%%%%% g1714322 %%%%%%%%%%%%%
            % disable warning of 
            %   'MATLAB:uitable:NonEditableDataTypes' from ColumnEditable
            %   'MATLAB:uitable:ColumnFormatNotSupported' from ColumnFormat
            % as a short term solution for above warning triggered by cell
            % edit from view.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % disable warnings
            warning('off', 'MATLAB:uitable:ColumnFormatNotSupported');
            warning('off', 'MATLAB:uitable:NonEditableDataTypes');
            
            if iscell(this.Model.Data.(column))
                this.Model.Data.(column){row, columnIndex} = newValue;
            else
                this.Model.Data.(column)(row, columnIndex) = newValue;
            end  
            
            % restore warnings
            warning('on', 'MATLAB:uitable:ColumnFormatNotSupported');
            warning('on', 'MATLAB:uitable:NonEditableDataTypes');
            
            retValue = this.getValueAt(row, column, columnIndex);
        end
        
        function retval = removeSingleQuotes(this, value)
            retval = value;
            
            %remove single quotes.
            if startsWith(value, '''') && endsWith(value, '''')
                retval = value(2:end-1);
            end            
        end
        
        function retval = removeDoubleQuotes(this, value)
            retval = value;
            
            %remove single quotes.
            if startsWith(value, '"') && endsWith(value, '"')
                retval = value(2:end-1);
            end            
        end 
        
        % How uitable relies on datetime to construct a new value with text input.
        function [newValue, error] = constructDatetimeFromText(this, editValue, row, column, columnIndex)
            
            error = '';

            % save and clear warning
            [warn_msg, warn_id] = lastwarn;
            lastwarn('');
            
            try 
                % first, try common formats (without input format).
                % use evalc to set lastwarn but not display to command window.
                evalc('newValue = datetime(editValue)');
            catch 
                try 
                    % second, try with the current format.
                    if iscell(this.Model.Data.(column))
                        format = this.Model.Data.(column){row, columnIndex}.Format;
                    else
                        format = this.Model.Data.(column).Format;
                    end
                    
                    % set
                    % use evalc to set lastwarn but not display to command window.
                    evalc('newValue = datetime(editValue, ''InputFormat'', format)');
                    
                catch e
                    newValue = NaT;
                    error = e;                    
                end
            end  
            
            % if no errors, try to capture any warnings.
            if isempty(error) && ~isempty(lastwarn)
                error = ['Warning: ' lastwarn];
            end
            
            % restore lastwarn.
            lastwarn(warn_msg, warn_id);
        end
    end
end