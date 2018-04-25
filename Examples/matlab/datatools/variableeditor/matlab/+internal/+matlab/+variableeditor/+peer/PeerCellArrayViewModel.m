classdef PeerCellArrayViewModel < internal.matlab.variableeditor.peer.PeerArrayViewModel & internal.matlab.variableeditor.CellArrayViewModel
    %PEERCellARRAYVIEWMODEL Peer Model Cell Array View Model
    
    % Copyright 2015 The MathWorks, Inc.

     
    properties(Constant, GetAccess=protected)
        widgets = internal.matlab.variableeditor.peer.WidgetRegistry.getInstance().getWidgets('', 'cell');
    end
    
	properties
        perfSubscription;
    end
    
    methods
        function this = PeerCellArrayViewModel(parentNode, variable)
            this = this@internal.matlab.variableeditor.peer.PeerArrayViewModel(parentNode,variable);
            this@internal.matlab.variableeditor.CellArrayViewModel(variable.DataModel);    
            if isprop(this, 'usercontext') && ~internal.matlab.variableeditor.peer.PeerUtils.isLiveEditor(this.usercontext)
                this.perfSubscription = message.subscribe('/VELogChannel', @(es) internal.matlab.variableeditor.FormatDataUtils.loadPerformance(es));
            end
            
            this.StartRow = 1;
            this.EndRow = 80;
            this.StartColumn = 1;
            this.EndColumn = 30;
            
            this.setTableModelProperties('ShowColumnHeaderLabels', false);
            
            if ~isempty(this.DataModel.Data)
                 this.updateCellMetaInfo();
            end  
            
            % Build the ArrayEditorHandler for the new Document
            import com.mathworks.datatools.variableeditor.web.*;
            if ~isempty(variable.DataModel.Data)
                this.PagedDataHandler = ArrayEditorHandler(variable.Name,this.PeerNode.Peer,this,this.getRenderedData(1,80,1,30));
            else
                this.PagedDataHandler = ArrayEditorHandler(variable.Name,this.PeerNode.Peer,this);
            end          
        end
        
        function [renderedData, renderedDims] = getRenderedData(this, startRow, endRow, ...
            startColumn, endColumn)

            data = this.getRenderedData@internal.matlab.variableeditor.CellArrayViewModel(...
                startRow, endRow, startColumn, endColumn);
            rawData = this.DataModel.Data;
            isMetaData = this.MetaData;
            
            sRow = max(1,startRow);
            eRow = min(size(rawData,1),endRow);
            sCol = max(startColumn,1);
            eCol = min(endColumn,size(rawData,2));
            
            rowStrs = strtrim(cellstr(num2str([sRow-1:eRow-1]'))');
            colStrs = strtrim(cellstr(num2str([sCol-1:eCol-1]'))');
            
            colStrsIndex = 1;
            renderedData = cell(size(data));
            for col = 1:size(renderedData,2)
                colStr = colStrs{col};
                rowStrsIndex = 1;
                for row = 1:size(renderedData,1)
                    rowStr = rowStrs{row};
                    editorValue = '';
                    if isMetaData(row,col) || ...
                            ischar(rawData{row+sRow-1,col+sCol-1}) && size(rawData{row+sRow-1,col+sCol-1},1) > 1
                        editorValue = sprintf('%s{%d,%d}', this.DataModel.Name,row+sRow-1,col+sCol-1);
                    end
                                        
                    % only numerics need to have an editvalue which is in
                    % long format
                    % other data types have their edit value same as data
                    % value                    
                    if isnumeric(rawData{row+sRow-1,col+sCol-1}) && ~isMetaData(row,col) && isscalar(rawData{row+sRow-1,col+sCol-1})
                        format('long');
                        cellVal = strtrim(evalc('disp(rawData(row+sRow-1,col+sCol-1))'));
                        longData = strtrim(regexprep(cellVal, '(^[)|(^{)|(}$)|(]$)',''));
                        format;
                    % This does not take the toJSON path. Adding this logic in formatDataUtils affects other
                    % scalar structs as well. 
                    else  
                        % Escape \ and " , Handle \n and \t for strings                        
                        % alone.
                        data{row,col} = internal.matlab.variableeditor.peer.PeerUtils.formatGetJSONforCell( rawData{row+sRow-1,col+sCol-1}, data{row,col});                                                    
                        longData = data{row,col};
                     end
                    
                    renderedData{row,col} = this.getJSONforCell(data{row,col}, longData,... 
                            this.MetaData(row,col), editorValue, rowStr, colStr);
                    rowStrsIndex = rowStrsIndex + 1;
                end
                colStrsIndex = colStrsIndex + 1;
            end
            renderedDims = size(renderedData);
        end
        
        function updateCellMetaInfo(this)
            this.CellModelChangeListener.Enabled = false;
            currentData = this.DataModel.Data;
            widgetRegistry = internal.matlab.variableeditor.peer.WidgetRegistry.getInstance();
            
            startRow = max(1,this.StartRow);
            endRow = min(size(currentData,1),this.EndRow);
            startCol = max(this.StartColumn,1);
            endCol = min(this.EndColumn,size(currentData,2));
            
            for col=endCol:-1:startCol
                for row = endRow:-1:startRow

                    % Set Renderers and Editors
                    val = currentData{row,col};
                    className = class(val);
                    [widgetsLocal,~,matchedVariableClass] = widgetRegistry.getWidgets(class(this),className);

                    % if className is different from matchedVariableClass then
                    % it means that the current data type is unsupported or it 
                    % is a custom object. In this case, the metadata of the 
                    % unsupported object should be displayed in the table column.
                    if ~strcmp(className,matchedVariableClass) 
                        if isobject(val)
                            widgetsLocal = widgetRegistry.getWidgets(class(this),'object');
                        else
                            widgetsLocal = widgetRegistry.getWidgets(class(this),'default');
                        end
                        className = matchedVariableClass;
                    end
                    
                    this.setCellModelProperties(row, col,...
                    'renderer', widgetsLocal.CellRenderer,...
                    'editor', widgetsLocal.Editor,...
                    'inplaceeditor', widgetsLocal.InPlaceEditor,...
                    'class', className);
                
                end
            end
            this.CellModelChangeListener.Enabled = true;
            
            this.updateCellModelInformation(startRow, endRow, startCol, endCol);
        end
        
        function updateCurrentPageModels(this)
            this.updateCellMetaInfo();
            this.updateCurrentPageModels@internal.matlab.variableeditor.peer.PeerArrayViewModel();
        end
        
        function delete(this)
            if isprop(this, 'usercontext') && ~internal.matlab.variableeditor.peer.PeerUtils.isLiveEditor(this.usercontext)
                message.unsubscribe(this.perfSubscription);
            end
        end
    end
    
    methods(Access = 'protected')
        function varargout = refresh(this, es ,ed)
            varargout = this.refresh@internal.matlab.variableeditor.peer.PeerArrayViewModel(es,ed);
            this.updateCurrentPageModels();
        end
        
        function classType = getClassType(~, ~, ~)
            % Return container class type (cell), not the individual cell
            % from the specified row/col.  Decisions made on the class type
            % returned here only depend on the container type.
            classType = 'cell';
        end                
    end
end
