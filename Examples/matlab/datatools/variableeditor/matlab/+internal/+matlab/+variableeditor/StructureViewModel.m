classdef StructureViewModel < ...
        internal.matlab.variableeditor.ArrayViewModel
    %STRUCTUREVIEWMODEL
    % Abstract Structure View Model
    
    % Copyright 2013-2014 The MathWorks, Inc.
    
    properties (SetObservable=false, SetAccess='protected', GetAccess='protected', Dependent=false, Hidden=false)
        MetaData = [];
    end
    
    properties (SetObservable=true, SetAccess='public', GetAccess='public', Dependent=false, Hidden=false)
        SortAscending = true;
       % SelectedFields = [];
    end
    methods
        function set.SortAscending(this, value)
            this.SortAscending = value;
            this.refresh([], struct('Range', []));
        end
    end
    
    properties (SetObservable=true, SetAccess='protected', GetAccess='public', Dependent=false, Hidden=false)
        SelectedFields = [];
    end
    
    % Public Abstract Methods
    methods(Access='public')
        % Constructor
        function this = StructureViewModel(dataModel)
            this@internal.matlab.variableeditor.ArrayViewModel(dataModel);
        end
        
        function [renderedData, renderedDims] = getRenderedData(...
                this, startRow, endRow, ~, ~)
            % This method always returns all columns of data, since there
            % is only a predefined number of columns.
            
            % Returns renderedData which is a cell array with each row
            % being a field in the structure, and the columns are:
            % 1 - field name
            % 2 - displayed value
            % 3 - size
            % 4 - class
            data = this.getData();
            fieldNames = this.getFields(data);
            
            if isstruct(data)
                cellData = struct2cell(data);
            else
                cellData = cellfun(@(x) data.(x), fieldNames, ...
                    'UniformOutput', false, ...
                    'ErrorHandler', @(~,~) []);
            end
            
            if ~this.SortAscending
                fieldNames = fieldNames(end:-1:1);
                cellData = flipud(cellData);
            end
            numRows = min(min(endRow,length(fieldNames))-startRow+1,length(fieldNames));
            whichRows = max(1, startRow):(min(endRow, length(fieldNames)));
            renderedData = cell([numRows ...
                internal.matlab.variableeditor.StructureDataModel.NumberOfColumns]);
            
            renderedData(:,1) = {fieldNames{whichRows}};
            [rd,~,metaData] = this.formatDataBlockForMixedView(startRow,endRow,1,1,cellData);
            renderedData(:,2) = rd;
            c = cell(length(whichRows),1);
            for i=1:length(whichRows);
                c{i} = this.getSizeString(cellData{whichRows(i)});
            end;
            renderedData(:,3) = c;
            renderedData(:,4) = cellfun(@(x)this.getClassString(x, false, true),cellData(whichRows),'UniformOutput',false);
            this.MetaData = metaData;
            renderedDims = size(renderedData);
        end
        
        % isEditable
        function editable = isEditable(this, row, ~)
            % The cell is not editable if it contains MetaData (like "10x10
            % double").
            editable = ~this.MetaData(row, 1);
        end
        
        % setData
        function varargout = setData(this,varargin)
            % Simple case, all of data replaced
            if this.SortAscending || nargin == 2
                varargout{1} = this.setData@internal.matlab.variableeditor.ArrayViewModel(varargin{:});
                return;
            end

            % Check for paired values.  varargin should be triplets, or 
            % triplets with an error message string at the end
            if rem(nargin-1, 3)~=0 && ...
                    (rem(nargin-2, 3)==0 && ~ischar(varargin{nargin-1}))
                error(message('MATLAB:codetools:variableeditor:UseNameRowColTriplets'));
            end

            s = this.getData();
            fn = this.getFields(s);
            numFields = length(fn);
            
            % Range(s) specified (value-range pairs)
            args = cell(nargin-1,1);
            for i=3:3:nargin
                newValue = varargin{i-2};
                row = varargin{i-1};
                column = varargin{i};
                
                % Reverse the row number
                row = numFields-row+1;

                args{i} = column;
                args{i-1} = row;
                args{i-2} = newValue;
            end
            args{end} = varargin{end};
            varargout{1} = this.setData@internal.matlab.variableeditor.ArrayViewModel(args{:});
        end
        
        function varargout = setSelection(this, varargin)
            varargout{1} = this.setSelection@internal.matlab.variableeditor.ArrayViewModel(varargin{:});
            this.setSelectedFields(this.SelectedRowIntervals);
        end

        function varargout = getFormattedSelection(this, varargin)
            selectionString = '';
            fields = this.getFields(this.DataModel.Data);

            % used to eval the expression below to make sure it is valid
            data = this.DataModel.Data; %#ok<NASGU>
            rowIntervals = this.SelectedRowIntervals;
            name = this.DataModel.Name;
            
            if ~isempty(fields)
                if ~this.SortAscending
                    for k=1:length(fields)
                        actualFields(k) = fields(length(fields) - (k - 1)); %#ok<AGROW>
                    end
                    fields = actualFields;
                end
                if ~isempty(rowIntervals)
                    for i=1:size(rowIntervals,1)
                        if i > 1
                            selectionString = [selectionString ';']; %#ok<AGROW>
                        end
                        % case when individual disjoint fields are selected
                        if (rowIntervals(i,1) == rowIntervals(i,2))
                            try
                                eval('data.(fields{rowIntervals(i,1)});');
                                selectionString = [selectionString name '.' ...
                                    char(fields(rowIntervals(i,1)))]; %#ok<AGROW>
                            catch
                            end
                        else
                            % case when a range of subsequent fields are selected
                            for j=(rowIntervals(i,1)):(rowIntervals(i,2))
                                try
                                    if j > rowIntervals(i,1)
                                        selectionString = [selectionString ';']; %#ok<AGROW>
                                    end
                                    eval('data.(fields{j});');
                                    selectionString = [selectionString name '.' ...
                                        char(fields(j))]; %#ok<AGROW>
                                catch
                                end
                            end
                        end
                    end
                end
            end
            varargout{1} = selectionString;
        end
    end
    
    methods (Access = protected)
        function fieldData = getFieldData(~, data, fn)
            try
                fieldData = data.(fn);
            catch
                fieldData = [];
            end
        end
        
        function fields = getFields(~, data)
            % Protected method to get the fields from the data.
            % Because objects reuse much of the structure code, they
            % can override this method to call properties instead of
            % fieldnames.
            fields = fieldnames(data);
        end
        
        function setSelectedFields(this, selectedRows)
            s = this.getData();
            fn = this.getFields(s);
            if ~this.SortAscending
                fn = fn(end:-1:1);
            end
            this.SelectedFields = {};
            for i=1:size(selectedRows,1)
                for j=selectedRows(i,1):selectedRows(i,2)
                    this.SelectedFields{end+1} = fn(j);
                end
            end
        end
    end
end


