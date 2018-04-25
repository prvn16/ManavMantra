classdef PeerLogicalArrayViewModel < ...
        internal.matlab.variableeditor.peer.PeerArrayViewModel & ...
        internal.matlab.variableeditor.LogicalArrayViewModel
    % PEERLOGICALARRAYVIEWMODEL
    % Peer Model Logical Array View Model
    
    % Copyright 2015-17 The MathWorks, Inc.
    
    properties
        usercontext;
    end
   
    methods
        % Constructor - creates a new PeerLogicalArrayViewModel
        function this = PeerLogicalArrayViewModel(parentNode, variable, usercontext)
            this = this@internal.matlab.variableeditor.peer.PeerArrayViewModel(...
                parentNode,variable);
            this@internal.matlab.variableeditor.LogicalArrayViewModel(...
                variable.DataModel);
            
            if nargin <=2 
                this.usercontext = '';
            else
                this.usercontext = usercontext;
            end
            
            if ~isempty(this.DataModel.Data)
                % Initialize the start/end rows/columns
                s = this.getSize();
                this.StartRow = 1;
                this.StartColumn = 1;
                this.EndColumn = min(30, s(2));
                this.EndRow = min(80, s(1));
            end
            
            % This is a temporary fix for Live Editor use case. Will be
            % modified when the widget registry allows registration per
            % application
            if ~internal.matlab.variableeditor.peer.PeerUtils.isLiveEditor(this.usercontext)
                  w = internal.matlab.variableeditor.peer.WidgetRegistry.getInstance();
                  w.registerWidgets('internal.matlab.variableeditor.peer.PeerLogicalArrayViewModel','', 'variableeditor/views/NumericArrayView','','')
            else
                  this.EndColumn = 1;
				  w = internal.matlab.variableeditor.peer.WidgetRegistry.getInstance();
                  w.registerWidgets('internal.matlab.variableeditor.peer.PeerLogicalArrayViewModel','', 'variableeditor_peer/PeerArrayViewModel','','')
            end
            
            % Logical arrays are homogeneous, so we can set the renderer,
            % editor and inPlaceEditor as Table Model properties.
            
            % First, get the widgets from the WidgetRegistry to use for
            % logical arrays
            widgets = internal.matlab.variableeditor.peer.WidgetRegistry.getInstance().getWidgets(...
                '','logical');
            
            % Next, setup the table model properties with the the renderer,
            % editor and inPlaceEditor.
            this.setTableModelProperties(...
                'renderer', widgets.CellRenderer,...
                'editor', widgets.Editor,...
                'inplaceeditor', widgets.InPlaceEditor,...
                'ShowColumnHeaderLabels', false,...
                'ShowRowHeaderLabels', false,...
                'class', 'logical');
            
            this.updateColumnModelInformation(...
                1, min(30, size(this.DataModel.getData, 2)));
            
            % Build the ArrayEditorHandler for the new Document. Note: This
            % is to be built only for mgg tables
            if ~internal.matlab.variableeditor.peer.PeerUtils.isLiveEditor(this.usercontext)
                % Build the ArrayEditorHandler for the new Document
                import com.mathworks.datatools.variableeditor.web.*;
                if ~isempty(variable.DataModel.Data)
                    this.PagedDataHandler = ArrayEditorHandler(...
                        variable.Name, this.PeerNode.Peer, this, ...
                        this.getRenderedData(1, 80, 1, 30));
                else
                    this.PagedDataHandler = ArrayEditorHandler(...
                        variable.Name, this.PeerNode.Peer,this);
                end
           end
        end
    end
    
    methods (Access = public)
        % getRenderedData - returns a cell array of strings for the desired
        % range of values
        function [renderedData, renderedDims] = getRenderedData(...
                this, startRow, endRow, startColumn, endColumn)
            % Get the data from the LogicalArrayViewModel.  This is a cell
            % array of the values, with '1' or '0' in each cell
            data = this.getRenderedData@internal.matlab.variableeditor.LogicalArrayViewModel(...
                startRow, endRow, startColumn, endColumn);
            this.setCurrentPage(startRow, endRow, startColumn, ...
                endColumn, false);
            
            renderedData = internal.matlab.variableeditor.peer.PeerLogicalArrayViewModel.getJSONForLogicalData(data, startRow, endRow, startColumn, endColumn);
            renderedDims = size(renderedData);
        end
    end

    methods (Access = protected)
        function result = evaluateClientSetData(~, data, ~, ~)
            % In case of logicals, if the user types a single character in 
            % single quotes, it is converted to its equivalent ascii value
            result = [];
            if (isequal(length(data), 3) && isequal(data(1),data(3),''''))
                result = double(data(2));
            end
        end
        
        % Called to validate input when the user makes changes
        function isValid = validateInput(~, value, ~, ~)
            if ischar(value)
                % Accept the text true and false
                isValid = strcmp(value, 'true') || strcmp(value, 'false');
            else
                % Also accept numeric and logical values
                isValid = (isnumeric(value) || islogical(value)) ...
                    && size(value, 1) == 1 && size(value, 2) == 1;
            end
        end
        
        % getEmptyValueReplacement - returns false for logicals
        function replacementValue = getEmptyValueReplacement(~, ~, ~)
            replacementValue = false;
        end
    end
    
    methods (Static)         
        function renderedData = getJSONForLogicalData(data, startRow, endRow, startColumn, endColumn)
            renderedData = cell(size(data));
            
            % Create the row and column strings to use in the JSON data
            % below
            rowStrs = strtrim(cellstr(...
                num2str((startRow-1:endRow-1)'))');
            colStrs = strtrim(cellstr(...
                num2str((startColumn-1:endColumn-1)'))');
            
            % Loop through the data, and create the JSON representation
            for row = 1:min(size(renderedData, 1), size(data, 1))
                for col = 1:min(size(renderedData, 2), size(data, 2))
                    jsonData = internal.matlab.variableeditor.peer.PeerUtils.toJSON(...
                        false, ...
                        struct('value', data(row, col),...
                        'editValue', data(row, col), ...
                        'row', rowStrs{row}, ...
                        'col',colStrs{col}));
                    
                    renderedData{row, col} = jsonData;
                end
            end
        end
    end
end
