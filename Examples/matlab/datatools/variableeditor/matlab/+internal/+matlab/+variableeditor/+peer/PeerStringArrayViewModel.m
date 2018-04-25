classdef PeerStringArrayViewModel < ...
        internal.matlab.variableeditor.peer.PeerArrayViewModel & ...
        internal.matlab.variableeditor.StringArrayViewModel
    % PeerStringArrayViewModel Peer Model View Model for string array
    % variables
    
    % Copyright 2015-2016 The MathWorks, Inc.
    
    properties(Constant, GetAccess=protected)
        widgets = internal.matlab.variableeditor.peer.WidgetRegistry.getInstance().getWidgets('', 'string');
    end
    
    methods
        function this = PeerStringArrayViewModel(parentNode, variable)
            this = this@internal.matlab.variableeditor.peer.PeerArrayViewModel(parentNode, variable);
            this@internal.matlab.variableeditor.StringArrayViewModel(variable.DataModel);
            
            % Build the ArrayEditorHandler for the new Document
            import com.mathworks.datatools.variableeditor.web.*;
            this.PagedDataHandler = ArrayEditorHandler(variable.Name,this.PeerNode.Peer,this,this.getRenderedData(1,80,1,30));
            
            % Set the renderer types on the table
            this.setTableModelProperties(...
                'renderer', internal.matlab.variableeditor.peer.PeerStringArrayViewModel.widgets.CellRenderer,...
                'editor', internal.matlab.variableeditor.peer.PeerStringArrayViewModel.widgets.Editor,...
                'inplaceeditor', internal.matlab.variableeditor.peer.PeerStringArrayViewModel.widgets.InPlaceEditor,...
                'ShowColumnHeaderLabels', false,...
                'ShowRowHeaderLabels', false,...
                'RemoveQuotedStrings',true,...
                'class', 'string');
        end
        
        % getRenderedData
        % returns a cell array of strings for the desired range of values
        function [renderedData, renderedDims, shortenedValues] = getRenderedData(this,startRow,endRow,startColumn,endColumn)
            [data, ~, shortenedValues, metaData] = this.getRenderedData@internal.matlab.variableeditor.StringArrayViewModel(startRow,endRow,startColumn,endColumn);
            renderedData = cell(size(data));
            [startRow, endRow, startColumn, endColumn] = internal.matlab.variableeditor.FormatDataUtils.resolveRequestSizeWithObj(...
                startRow, endRow, startColumn, endColumn, size(this.getData));

            % Use metadata determined from getRenderedData.  It is limited to the same
            % range as the data
            missingStr = metaData; 
            
            this.setCurrentPage(startRow, endRow, startColumn, endColumn, false);
            
            rowStrs = strtrim(cellstr(num2str((startRow-1:endRow-1)'))');
            colStrs = strtrim(cellstr(num2str((startColumn-1:endColumn-1)'))');
            
            for row=1:min(size(renderedData,1),size(data,1))
                for col=1:min(size(renderedData,2),size(data,2))
                    dataValue = data{row,col};
                    shortValue = shortenedValues{row,col};
                        
                    jsonData = internal.matlab.variableeditor.peer.PeerUtils.toJSON(true,...
                        struct('value',shortValue,...
                        'editValue',dataValue,...
                        'isMetaData', missingStr(row,col), ...
                        'row',rowStrs{row},...
                        'col',colStrs{col}));
                    
                    renderedData{row,col} = jsonData;
                end
            end
            renderedDims = size(renderedData);
        end
    end
    
    methods(Access='protected')
        function replacementValue = getEmptyValueReplacement(~, ~, ~) 
            replacementValue = '';
        end
        
        function classType = getClassType(this, ~, ~)
            classType = class(this.DataModel.Data);
        end  
    end
end
