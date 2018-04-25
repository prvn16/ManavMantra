classdef PeerCategoricalViewModel < ...
        internal.matlab.variableeditor.peer.PeerArrayViewModel & ...
        internal.matlab.variableeditor.CategoricalViewModel
    % PeerCategoricalViewModel Peer Model Table View Model for categorical
    % variables
    
    % Copyright 2014-2016 The MathWorks, Inc.
    
    properties(Constant, GetAccess=protected)
        widgets = internal.matlab.variableeditor.peer.WidgetRegistry.getInstance().getWidgets(...
            '', 'categorical');
    end

    methods
        function this = PeerCategoricalViewModel(parentNode, variable)
            % Setup the table properties, including the categories and
            % whether the categorical variable is protected or not.
            % Include this in the PeerArrayViewModel constructor so the
            % properties are set when the ViewModel is created
            m = struct();
            m.categories = variable.DataModel.Categories;
            m.isProtected = variable.DataModel.Protected;
            m.renderer = internal.matlab.variableeditor.peer.PeerCategoricalViewModel.widgets.CellRenderer;
            m.editor = internal.matlab.variableeditor.peer.PeerCategoricalViewModel.widgets.Editor;
            m.inplaceeditor = internal.matlab.variableeditor.peer.PeerCategoricalViewModel.widgets.InPlaceEditor;
            m.class = 'categorical';
            % Categoricals do not have header labels
            m.ShowColumnHeaderLabels = false;
            tableProperties = internal.matlab.variableeditor.peer.PeerUtils.toJSON(true, m);
            
            this = this@internal.matlab.variableeditor.peer.PeerArrayViewModel(...
                parentNode, variable, 'TableModelProperties', tableProperties);
            
            this@internal.matlab.variableeditor.CategoricalViewModel(variable.DataModel);
            
            if ~isempty(this.DataModel.Data)
                s = this.getSize();
                this.StartRow = 1;
                this.StartColumn = 1;
                this.EndColumn = min(30, s(2));
                this.EndRow = min(80,s(1));
            end
            
            % Assign the class TableModelProperties to the properties set
            % above.
            this.TableModelProperties = m;
            
            % Build the ArrayEditorHandler for the new Document
            import com.mathworks.datatools.variableeditor.web.*;
            if ~isempty(variable.DataModel.Data)
                this.PagedDataHandler = ArrayEditorHandler(variable.Name,this.PeerNode.Peer,this,this.getRenderedData(1,80,1,30));
            else
                this.PagedDataHandler = ArrayEditorHandler(variable.Name,this.PeerNode.Peer,this);
            end
            
        end
        
        function varargout = handleClientSetData(this, varargin)
            % Overriding PeerArrayViewModel version to handle text input
            data = this.getStructValue(varargin{1}, 'data');
            row = this.getStructValue(varargin{1}, 'row');
            column = this.getStructValue(varargin{1}, 'column');
            varargout{1} = '';
            try
                if ~isempty(row)
                    if ischar(row)
                        row = str2double(row);
                    end
                    if ischar(column)
                        column = str2double(column);
                    end
                    
                    % Check for empty value passed from user and replace
                    % with valid "empty" value
                    if isempty(data)
                        data = this.getEmptyValueReplacement(row,column);
                    else
                        % accept non-empty string as a valid enum
                        if isempty(data) || ~ischar(data)
                            error(message('MATLAB:codetools:variableeditor:InvalidInputType'));
                        end
                        
                        % Single quotes are treated as literals, so wrap
                        % with extra quotes to escape them
                        data = strrep(data, '''', '''''');
                    end

                    varargout{1} = this.executeCommandInWorkspace(data, row, column);
                else
                    error(message('MATLAB:codetools:variableeditor:UseNameRowColTriplets'));
                end
            catch e
                % Send data change event.
                this.PeerNode.dispatchEvent(struct('type','dataChangeStatus', ...
                   'source', 'server','status', 'error', 'message', e.message));
                varargout{1} = '';       
            end
        end
    end

    methods(Access='public')
        % getRenderedData
        % returns a cell array of strings for the desired range of values
        function [renderedData, renderedDims] = getRenderedData(this, ...
                startRow, endRow, startColumn, endColumn)
            
            data = this.getRenderedData@internal.matlab.variableeditor.CategoricalViewModel(...
                startRow, endRow, startColumn, endColumn);
            
            % Update categories table model property to make sure the
            % categories are up to date on the client.
            this.TableModelProperties.categories = this.getCategories;
            this.updateTableModelInformation();
            
            renderedData = cell(size(data));
            this.StartRow = startRow;
            this.EndRow = endRow;
            this.StartColumn = startColumn;
            this.EndColumn = endColumn;
            
            f=get(0,'format');
            format('long');
            longData = this.getRenderedData@internal.matlab.variableeditor.CategoricalViewModel(startRow,endRow,startColumn,endColumn);
            format(f);

            rowStrs = strtrim(cellstr(num2str((startRow-1:endRow-1)'))');
            colStrs = strtrim(cellstr(num2str((startColumn-1:endColumn-1)'))');

            for row=1:size(renderedData,1)
                for col=1:size(renderedData,2)
                   jsonData = internal.matlab.variableeditor.peer.PeerUtils.toJSON(true, struct('value',data{row,col},...
                                    'longValue',longData{row,col},'row',rowStrs{row},'col',colStrs{col}));

                   renderedData{row,col} = jsonData;
                end
            end
            renderedDims = size(renderedData);
        end
    end
end
