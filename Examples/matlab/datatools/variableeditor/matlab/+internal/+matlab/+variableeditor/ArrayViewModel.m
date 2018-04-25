classdef ArrayViewModel < internal.matlab.variableeditor.ViewModel & internal.matlab.variableeditor.BlockSelectionModel & internal.matlab.variableeditor.FormatDataUtils
    %ARRAYVIEWMODEL
    %   Abstract Array View Model

    % Copyright 2013-2014 The MathWorks, Inc.

    properties
        CellModelProperties = [];
        TableModelProperties = [];
        ColumnModelProperties = [];
        RowModelProperties = [];
    end
    
    events
        CellModelChanged;
        TableModelChanged;
        ColumnModelChanged;
        RowModelChanged;
    end

    % Public Abstract Methods
    methods(Access='public')
        % Constructor
        function this = ArrayViewModel(dataModel)
            this@internal.matlab.variableeditor.ViewModel(dataModel);
            this.TableModelProperties = struct();
        end
        
        % isSelectable
        function selectable = isSelectable(~)
            selectable = true;
        end
        
        % isEditable
        function editable = isEditable(varargin)
            editable = true;
        end

        % getData
        function varargout = getData(this,varargin)
			varargout{1} = this.DataModel.getData(varargin{:});
        end

        % setData
        function varargout = setData(this,varargin)
            varargout{1} = this.DataModel.setData(varargin{:});
        end

        % getSize
        function s = getSize(this)
			s=this.DataModel.getSize();
        end

        % updateData
        function data = updateData(this, varargin)
            data = this.DataModel.updateData(varargin{:});
        end

        % getCellPropertyValue
        function value = getCellPropertyValue(this, row, col, property)
            value = this.getCellModelProperty(row, col, property);
            if isempty(value) || (iscell(value) && all(all(cellfun(@isempty,value))))
                value = this.getColumnModelProperty(col, property);
                if isempty(value) || (iscell(value) && all(all(cellfun(@isempty,value))))
                    value = this.getRowModelProperty(row, property);
                    if isempty(value) || (iscell(value) && all(all(cellfun(@isempty,value))))
                        value = this.getTableModelProperty(property);
                        if ~iscell(value)
                            value = {value};
                        end
                    end
                end
            end
        end

        % getCellModelProperties
        function varargout = getCellModelProperties(this, row, column, varargin)
            varargout = {};
            if (nargin == 0)
                return;
            end

            % Grow the cell model properties array if necessary
            if size(this.CellModelProperties, 1) < max(row) || ...
                    size(this.CellModelProperties, 2) < max(column)
                this.CellModelProperties{max(row), max(column)} = struct();
            end

            vals = this.getModelProperties(this.CellModelProperties(row,column), varargin{:});
            if isempty(vals) || (iscell(vals) && all(all(cellfun(@isempty,vals))))
                varargout{1} = [];
                return;
            end
            varargout{1} = vals;
        end

        % getCellModelProperty
        function varargout = getCellModelProperty(this, row, column, name)
            varargout{1} = this.getCellModelProperties(row, column, name);
        end
        
        % getTableModelProperties
        function varargout = getTableModelProperties(this, varargin)
            vals = this.getModelProperties(this.TableModelProperties, varargin{:});
            if isempty(vals)
                varargout{1} = [];
                return;
            end
            varargout = vals;
        end
        
        % getTableModelProperty
        function varargout = getTableModelProperty(this, name)
            varargout{1} = this.getTableModelProperties(name);
        end

        % getColumnModelProperties
        function varargout = getColumnModelProperties(this, column, varargin)
            varargout = {};
            if (nargin == 0)
                return;
            end

            % Grow the column model properties array if necessary
            if numel(this.ColumnModelProperties) < max(column)
                this.ColumnModelProperties{max(column)} = struct();
            end

            vals = this.getModelProperties(this.ColumnModelProperties(column), varargin{:});
            if isempty(vals)
                varargout{1} = [];
                return;
            end
            varargout{1} = vals;
        end

        % getColumnModelProperty
        function varargout = getColumnModelProperty(this, column, name)
            varargout{1} = this.getColumnModelProperties(column, name);
        end
        
        % getRowModelProperties
        function varargout = getRowModelProperties(this, row, varargin)
            varargout = {};
            if (nargin == 0)
                return;
            end

            % Grow the row model properties array if necessary
            if numel(this.RowModelProperties) < max(row)
                this.RowModelProperties{max(row)} = struct();
            end
            
            vals = this.getModelProperties(this.RowModelProperties(row), varargin{:});
            if isempty(vals)
                varargout{1} = [];
                return;
            end
            varargout{1} = vals;
        end

        % getRowModelProperty
        function varargout = getRowModelProperty(this, row, name)
            varargout{1} = this.getRowModelProperties(row, name);
        end

        % setTableModelProperty
        function [valueUpdated, oldValue] = setTableModelProperty(this, key, value, fireUpdate)
            valueUpdated = false;
            if nargin<4
                fireUpdate = true;
            end
            
            % Get old value
            oldValue = this.getTableModelProperties(key);

            % Check to see if the old and new values are equal
            if isequal(oldValue, value)
                return;
            end
            
            valueUpdated = true;
            % Set new value
            this.TableModelProperties.(key) = value;

            % Notify listeners of change
            if (fireUpdate)
                eventData = internal.matlab.variableeditor.ModelChangeEventData;
                eventData.Key = key;
                eventData.OldValue = oldValue;
                eventData.NewValue = value;
                this.notify('TableModelChanged', eventData);
            end
        end

        % setTableModelProperties
        function setTableModelProperties(this, varargin)
            if mod(nargin-1, 2) ~= 0
                error(message('MATLAB:codetools:variableeditor:PropertyValuePairsExpected'));
            end

            valueUpdated = false;
            for i=1:2:(nargin-1)
                valueUpdated = this.setTableModelProperty(varargin{i},varargin{i+1}, false) || valueUpdated;
            end
            
            if valueUpdated
                eventData = internal.matlab.variableeditor.ModelChangeEventData;
                eventData.Key = '';
                eventData.OldValue = '';
                eventData.NewValue = '';
                this.notify('TableModelChanged', eventData);
            end
        end
        
        % setColumnModelProperty
        function [valueUpdated, oldValue]= setColumnModelProperty(this, column, key, value, fireUpdate)
            valueUpdated = false;
            if nargin<5
                fireUpdate = true;
            end

            % Get old value
            oldValue = this.getColumnModelProperties(column, key);

            % Check to see if the old and new values are equal
            if ~isempty(oldValue) && ~any(any((cellfun(@(x)~isequal(x,value),oldValue))))
                return;
            end

            valueUpdated = true;
            % Set the new value
            for c = column
                if isempty(this.ColumnModelProperties{c})
                    this.ColumnModelProperties{c} = struct();
                end
                this.ColumnModelProperties{c}.(key) = value;
            end

            % Notify listeners of change
            if (fireUpdate)
                eventData = internal.matlab.variableeditor.ModelChangeEventData;
                eventData.Key = key;
                eventData.Column = column;
                eventData.OldValue = oldValue;
                eventData.NewValue = value;
                this.notify('ColumnModelChanged', eventData);
            end
        end

        % setColumnModelProperties
        function setColumnModelProperties(this, column, varargin)
            if mod(nargin-2, 2) ~= 0
                error(message('MATLAB:codetools:variableeditor:PropertyValuePairsExpected'));
            end

            valueUpdated = false;
            oldValues = cell(1, mod(nargin-3, 2));
            keys = cell(1, mod(nargin-3, 2));
            newValues = cell(1, mod(nargin-3, 2));
            for i=1:2:(nargin-2)
                key = varargin{i};
                newValue = varargin{i+1};
                [updated, oldValue] = this.setColumnModelProperty(column, key, newValue, false);
                if (updated)
                    j = int32(i/2);
                    keys{j} = key;
                    oldValues{j} = oldValue;
                    newValues{j} = newValue;
                end
                valueUpdated = updated || valueUpdated;
            end
            
            if valueUpdated
                % Use keys to find the non-empty because oldValue or
                % newValue could be empty
                oldValues = oldValues(~cellfun(@isempty,keys));
                newValues = newValues(~cellfun(@isempty,keys));
                keys = keys(~cellfun(@isempty,keys));
                eventData = internal.matlab.variableeditor.ModelChangeEventData;
                eventData.Key = keys;
                eventData.Column = column;
                eventData.OldValue = oldValues;
                eventData.NewValue = newValues;
                this.notify('ColumnModelChanged', eventData);
            end
        end

        % setRowModelProperty
        function [valueUpdated, oldValue] = setRowModelProperty(this, row, key, value, fireUpdate)
            valueUpdated = false;
            if nargin<5
                fireUpdate = true;
            end

            % Get old value
            oldValue = this.getRowModelProperties(row, key);

            % Check to see if the old and new values are equal
            if ~isempty(oldValue) && ~any(any((cellfun(@(x)~isequal(x,value),oldValue))))
                return;
            end

            valueUpdated = true;
            % Set the new value
            for r = row
                if isempty(this.RowModelProperties{r})
                    this.RowModelProperties{r} = struct();
                end
                this.RowModelProperties{r}.(key) = value;
            end

            % Notify listeners of change
            if (fireUpdate)
                eventData = internal.matlab.variableeditor.ModelChangeEventData;
                eventData.Key = key;
                eventData.Row = row;
                eventData.OldValue = oldValue;
                eventData.NewValue = value;
                this.notify('RowModelChanged', eventData);
            end
        end

        % setRowModelProperties
        function setRowModelProperties(this, row, varargin)
            if mod(nargin-2, 2) ~= 0
                error(message('MATLAB:codetools:variableeditor:PropertyValuePairsExpected'));
            end

            valueUpdated = false;
            oldValues = cell(1, mod(nargin-3, 2));
            keys = cell(1, mod(nargin-3, 2));
            newValues = cell(1, mod(nargin-3, 2));
            for i=1:2:(nargin-2)
                key = varargin{i};
                newValue = varargin{i+1};
                [updated, oldValue] = this.setRowModelProperty(row, key, newValue, false);
                if (updated)
                    j = int32(i/2);
                    keys{j} = key;
                    oldValues{j} = oldValue;
                    newValues{j} = newValue;
                end
                valueUpdated = updated || valueUpdated;
            end
            
            if valueUpdated
                % Use keys to find the non-empty because oldValue or
                % newValue could be empty
                oldValues = oldValues(~cellfun(@isempty,keys));
                newValues = newValues(~cellfun(@isempty,keys));
                keys = keys(~cellfun(@isempty,keys));
                eventData = internal.matlab.variableeditor.ModelChangeEventData;
                eventData.Key = keys;
                eventData.Row = row;
                eventData.OldValue = oldValues;
                eventData.NewValue = newValues;
                this.notify('RowModelChanged', eventData);
            end
        end
        
        % setCellModelProperty
        function [valueUpdated, oldValue] = setCellModelProperty(this, row, column, key, value, fireUpdate)
            valueUpdated = false;
            if nargin<6
                fireUpdate = true;
            end
            
            % Get old value
            oldValue = this.getCellModelProperties(row, column, key);

            % Check to see if the old and new values are equal
            if ~isempty(oldValue) && ~any(any((cellfun(@(x)~isequal(x,value),oldValue))))
                return;
            end

            valueUpdated = true;
            % Set the new value
            for r = row
                for c = column
                    if isempty(this.CellModelProperties{r, c})
                        this.CellModelProperties{r, c} = struct();
                    end
                    this.CellModelProperties{r, c}.(key) = value;
                end
            end

            % Notify listeners of change
            if (fireUpdate)
                eventData = internal.matlab.variableeditor.ModelChangeEventData;
                eventData.Key = key;
                eventData.Row = row;
                eventData.Column = column;
                eventData.OldValue = oldValue;
                eventData.NewValue = value;
                this.notify('CellModelChanged', eventData);
            end
        end
        
        % setCellModelProperties
        function setCellModelProperties(this, row, column, varargin)
			if mod(nargin-3, 2) ~= 0
				error(message('MATLAB:codetools:variableeditor:PropertyValuePairsExpected'));
			end

			valueUpdated = false;
			oldValues = cell(1, mod(nargin-3, 2));
			keys = cell(1, mod(nargin-3, 2));
			newValues = cell(1, mod(nargin-3, 2));
			for i=1:2:(nargin-3)
				key = varargin{i};
				newValue = varargin{i+1};
				[updated, oldValue] = this.setCellModelProperty(row, column, key, newValue, false);
				if (updated)
					j = int32(i/2);
					keys{j} = key;
					oldValues{j} = oldValue;
					newValues{j} = newValue;
				end
				valueUpdated = updated || valueUpdated;
			end

			if valueUpdated
				% Use keys to find the non-empty because oldValue or
				% newValue could be empty
				oldValues = oldValues(~cellfun(@isempty,keys));
				newValues = newValues(~cellfun(@isempty,keys));
				keys = keys(~cellfun(@isempty,keys));
				eventData = internal.matlab.variableeditor.ModelChangeEventData;
				eventData.Key = keys;
				eventData.Row = row;
				eventData.Column = column;
				eventData.OldValue = oldValues;
				eventData.NewValue = newValues;
				this.notify('CellModelChanged', eventData);
			end              
        end
        
        % getRenderedData
        % returns a cell array of strings for the desired range of values
        function [renderedData, renderedDims] = getRenderedData(this,startRow,endRow,startColumn,endColumn)
            data = this.getData(startRow,endRow,startColumn,endColumn);

            vals = cell(size(data,2),1);
            for column=1:size(data,2)
                r=evalc('disp(data(:,column))');
                if ~isempty(r)
                    textformat = ['%s', '%*[\n]'];
                    vals{column}=strtrim(textscan(r,textformat,'Delimiter',''));
                end
            end
            renderedData=[vals{:}];

            if ~isempty(renderedData)
                renderedData=[renderedData{:}];
            end

            renderedDims = size(renderedData);
        end
    end
    
    methods (Access='protected')
        % getModelProperties
        function varargout = getModelProperties(~, map, varargin)
            varargout = {};
            if (nargin < 3) || isempty(map)
                varargout{1} = {};
                return;
            end

            if isstruct(map)
                output = cell(1,nargin-2);
                for i=3:nargin
                    key = varargin{i-2};
                    if isfield(map, key)
                        output{i-2} = map.(key);
                    else
                        output{i-2} = '';
                    end;
                end
            else
                if (size(map,1) == 1)
                    output = cell(nargin-2,size(map,2));
                    for i=3:nargin
                        key = varargin{i-2};
                        for c=1:size(map,2)
                            m = map{c};
                            if ~isempty(m) && isfield(m, key)
                                output{i-2,c} = m.(key);
                            else
                                output{i-2,c} = '';
                            end
                        end
                    end
                else
                    output = cell(nargin-2,size(map,1),size(map,2));
                    for i=3:nargin
                        key = varargin{i-2};
                        for r=1:size(map,1)
                            for c=1:size(map,2)
                                m = map{r,c};
                                if ~isempty(m) && isfield(m, key)
                                    output{i-2,r,c} = m.(key);
                                else
                                    output{i-2,r,c} = '';
                                end
                            end
                        end
                    end
                end
            end
            
            varargout{1} = output;
        end
        
        % Replace new lines and carriage returns with white space in a cell
        % array of strings.
        function vals = replaceNewLineWithWhiteSpace(~, r)
            % First replace the new line with white space.
            vals = cellfun(@(dt) strrep(dt, char(10), ' '), r, 'UniformOutput', false);
            
            % Now replace the carriage return with white space.
            vals = cellfun(@(dt) strrep(dt, char(13), ' '), vals, 'UniformOutput', false);
        end
    end   
end
            

