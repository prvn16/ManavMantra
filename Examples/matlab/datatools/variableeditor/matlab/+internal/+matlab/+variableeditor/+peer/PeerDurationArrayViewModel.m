classdef PeerDurationArrayViewModel < internal.matlab.variableeditor.peer.PeerArrayViewModel & ...
        internal.matlab.variableeditor.DurationArrayViewModel
    %PEERDURATIONARRAYVIEWMODEL Peer Model Duration Array View Model
    
    % Copyright 2015 The MathWorks, Inc.

    properties(Constant, GetAccess=protected)
        widgets = internal.matlab.variableeditor.peer.WidgetRegistry.getInstance().getWidgets('','duration');        
    end
    
    properties
        dataPropertyChangedListener;
    end
    
    methods
        function this = PeerDurationArrayViewModel(parentNode, variable)
            this = this@internal.matlab.variableeditor.peer.PeerArrayViewModel(parentNode,variable);
            this@internal.matlab.variableeditor.DurationArrayViewModel(variable.DataModel);
            
			if ~isempty(this.DataModel.Data)
			   s = this.getSize();
			   this.StartRow = 1;
			   this.StartColumn = 1;
			   this.EndColumn = min(30, s(2));
			   this.EndRow = min(80,s(1));
		    end
			
			% Set the renderer types on the table
            this.setTableModelProperties(...
                'renderer', internal.matlab.variableeditor.peer.PeerDurationArrayViewModel.widgets.CellRenderer,...
                'ShowColumnHeaderLabels', false,...
                'ShowRowHeaderLabels', false,...
                'editable', false,...
                'class','duration');
			
            % Build the ArrayEditorHandler for the new Document
            import com.mathworks.datatools.variableeditor.web.*;
            if ~isempty(variable.DataModel.Data)
                this.PagedDataHandler = ArrayEditorHandler(variable.Name,this.PeerNode.Peer,this,this.getRenderedData(1,80,1,30));
            else
                this.PagedDataHandler = ArrayEditorHandler(variable.Name,this.PeerNode.Peer,this);
            end

        end
    end
    
    methods(Access='public')
        % getRenderedData
        % returns a cell array of strings for the desired range of values
        function [renderedData, renderedDims] = getRenderedData(this,startRow,endRow,startColumn,endColumn)
            data = this.getRenderedData@internal.matlab.variableeditor.DurationArrayViewModel(startRow,endRow,startColumn,endColumn);
            renderedData = cell(size(data));
            this.setCurrentPage(startRow, endRow, startColumn, endColumn, false);

            rowStrs = strtrim(cellstr(num2str((startRow-1:endRow-1)'))');
            colStrs = strtrim(cellstr(num2str((startColumn-1:endColumn-1)'))');

            for row=1:min(size(renderedData,1),size(data,1))
                for col=1:min(size(renderedData,2),size(data,2))
                    jsonData = internal.matlab.variableeditor.peer.PeerUtils.toJSON(false, struct('value',data{row,col},...
                        'editValue',data{row,col},'row',rowStrs{row},'col',colStrs{col}));

                   renderedData{row,col} = jsonData;
                end
            end
            renderedDims = size(renderedData);
        end
    end
    
    methods(Access='protected')
        function isValid = validateInput(~,value,~,~)
            % The only valid input types are 1x1 durations.
            % This may change in the future when there is a duration 
            % constructor that accepts a string as input.
            isValid = isduration(value) && size(value, 1) == 1 && size(value, 2) == 1;
        end
    end
end
