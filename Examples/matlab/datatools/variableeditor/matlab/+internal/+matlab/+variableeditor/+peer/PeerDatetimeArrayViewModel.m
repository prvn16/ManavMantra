classdef PeerDatetimeArrayViewModel < internal.matlab.variableeditor.peer.PeerArrayViewModel & ...
        internal.matlab.variableeditor.DatetimeArrayViewModel &...
        internal.matlab.variableeditor.VEColumnConstants
    %PEERDATETIMEARRAYVIEWMODEL Peer Model Datetime Array View Model

    % Copyright 2015-2017 The MathWorks, Inc.

    properties(Constant, GetAccess=protected)
        widgets = internal.matlab.variableeditor.peer.WidgetRegistry.getInstance().getWidgets('','datetime');
    end

    methods
        function this = PeerDatetimeArrayViewModel(parentNode, variable)
            this = this@internal.matlab.variableeditor.peer.PeerArrayViewModel(parentNode,variable);
            this@internal.matlab.variableeditor.DatetimeArrayViewModel(variable.DataModel);

			 if ~isempty(this.DataModel.Data)
			   s = this.getSize();
			   this.StartRow = 1;
			   this.StartColumn = 1;
			   this.EndColumn = min(30, s(2));
			   this.EndRow = min(80,s(1));
		    end

			% Set the renderer types on the table
            this.setTableModelProperties(...
                'renderer', internal.matlab.variableeditor.peer.PeerDatetimeArrayViewModel.widgets.CellRenderer,...
                'editor', internal.matlab.variableeditor.peer.PeerDatetimeArrayViewModel.widgets.Editor,...
                'inplaceeditor', internal.matlab.variableeditor.peer.PeerDatetimeArrayViewModel.widgets.InPlaceEditor,...
                'ShowColumnHeaderLabels', false,...
                'ShowRowHeaderLabels', false,...
                'EditorConverter', 'datetimeConverter',...
                'class','datetime');

			% Build the ArrayEditorHandler for the new Document
            import com.mathworks.datatools.variableeditor.web.*;

            if ~isempty(variable.DataModel.Data)
                this.setDefaultColumnWidths(variable.DataModel.Data, internal.matlab.variableeditor.VEColumnConstants.datetimeColumnWidth);
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
            data = this.getRenderedData@internal.matlab.variableeditor.DatetimeArrayViewModel(startRow,endRow,startColumn,endColumn);
            renderedData = cell(size(data));

            rowStrs = strtrim(cellstr(num2str((startRow-1:endRow-1)'))');
            colStrs = strtrim(cellstr(num2str((startColumn-1:endColumn-1)'))');

            for row=1:min(size(renderedData,1),size(data,1))
                for col=1:min(size(renderedData,2),size(data,2))
                       jsonData = internal.matlab.variableeditor.peer.PeerUtils.toJSON(true, struct('value',data{row,col},...
                                    'editValue',data{row,col},'row',rowStrs{row},'col',colStrs{col}));

                   renderedData{row,col} = jsonData;
                end
            end
            renderedDims = size(renderedData);
        end
    end

    methods(Access='protected')
        function isValid = validateInput(this,value,row,column)
            % Since the client is sending characters we need to try to
            % convert them to a valid datetime object. This requires
            % getting a copy of the actual datetime data and trying an
            % assignment of the form data(row, column) = value. If the
            % result is a datetime, then the value is valid. If an
            % exception occurs, throw a datetime specific error instead of
            % the error sent from handleClientSetData. (g1239590)
            if ischar(value) && size(value, 1) == 1
                try
                    dt = this.getData();
                    dt(row, column) = value;
                    isValid = isdatetime(dt);
                catch
                    error(message('MATLAB:datetime:InvalidFromVE'));
                end
            else
                isValid = false;
            end
        end

        function replacementValue = getEmptyValueReplacement(~,~,~)
            % Empty values should be replaced with NaT.
            replacementValue = datetime('NaT');
        end
    end
end
