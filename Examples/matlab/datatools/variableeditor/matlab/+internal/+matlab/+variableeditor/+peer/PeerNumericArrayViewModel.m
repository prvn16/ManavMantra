classdef PeerNumericArrayViewModel < internal.matlab.variableeditor.peer.PeerArrayViewModel & ...
        internal.matlab.variableeditor.NumericArrayViewModel & ...
        internal.matlab.variableeditor.VEColumnConstants
    %PEERNUMERICARRAYVIEWMODEL Peer Model Numeric Array View Model

    % Copyright 2013-2017 The MathWorks, Inc.

    properties(Constant, GetAccess=protected)
        widgets = internal.matlab.variableeditor.peer.WidgetRegistry.getInstance().getWidgets('','double');
    end

    properties
        perfSubscription;
        usercontext;
        scalingFactorString;
    end

    methods
        function this = PeerNumericArrayViewModel(parentNode, variable, usercontext)
            this = this@internal.matlab.variableeditor.peer.PeerArrayViewModel(parentNode,variable);
            this@internal.matlab.variableeditor.NumericArrayViewModel(variable.DataModel);
            fullData = this.DataModel.Data;
            if nargin <=2 
                this.usercontext = '';
            else
                this.usercontext = usercontext;
            end
            
            if ~isempty(fullData)
                s = this.getSize();
                this.StartRow = 1;
                this.StartColumn = 1;
                this.EndColumn = min(30, s(2));
                this.EndRow = min(80,s(1));
                
                if ~internal.matlab.variableeditor.peer.PeerUtils.isLiveEditor(this.usercontext)
                  w = internal.matlab.variableeditor.peer.WidgetRegistry.getInstance();
                  w.registerWidgets('internal.matlab.variableeditor.peer.PeerNumericArrayViewModel','', 'variableeditor/views/NumericArrayView','','')
                  this.perfSubscription = message.subscribe('/VELogChannel', @(es) internal.matlab.variableeditor.FormatDataUtils.loadPerformance(es));
                else
                  this.EndColumn = min(30, s(2));
                  this.EndRow = 1;
				  w = internal.matlab.variableeditor.peer.WidgetRegistry.getInstance();
                  w.registerWidgets('internal.matlab.variableeditor.peer.PeerNumericArrayViewModel','', 'variableeditor_peer/PeerArrayViewModel','','')
                end
            end

            % Set the renderer types on the table
            this.setTableModelProperties(...
                'renderer', internal.matlab.variableeditor.peer.PeerNumericArrayViewModel.widgets.CellRenderer,...
                'editor', internal.matlab.variableeditor.peer.PeerNumericArrayViewModel.widgets.Editor,...
                'inplaceeditor', internal.matlab.variableeditor.peer.PeerNumericArrayViewModel.widgets.InPlaceEditor,...
                'ShowColumnHeaderLabels', false,...
                'ShowRowHeaderLabels', false,...
                'class','double');

            this.updateColumnModelInformation(1, min(30,size(this.DataModel.getData,2)));
            
            if ~isempty(fullData)
                this.scalingFactorString = internal.matlab.variableeditor.peer.PeerDataUtils.getScalingFactor(fullData);  
                if ~isempty(this.scalingFactorString) 
                    exponent = internal.matlab.variableeditor.peer.PeerDataUtils.getScalingFactorExponent(this.scalingFactorString);
                    this.setProperty('ScalingFactor', num2str(exponent));
                end
            else
                this.scalingFactorString = strings(0,0);
            end            

            % Build the ArrayEditorHandler for the new Document. Note: This
            % is to be built only for mgg tables
            if ~internal.matlab.variableeditor.peer.PeerUtils.isLiveEditor(this.usercontext)
                import com.mathworks.datatools.variableeditor.web.*;
                if ~isempty(variable.DataModel.Data)
                    this.PagedDataHandler = ArrayEditorHandler(variable.Name,this.PeerNode.Peer,this,this.getRenderedData(this.StartRow,this.EndRow,this.StartColumn,this.EndColumn));
                    if ~isreal(variable.DataModel.Data)
                        % Set larger column widths by default for complex numbers
                        this.setDefaultColumnWidths(variable.DataModel.Data, ...
                            internal.matlab.variableeditor.VEColumnConstants.complexNumDefaultWidth);
                    end
                else
                    this.PagedDataHandler = ArrayEditorHandler(variable.Name,this.PeerNode.Peer,this);
                end
            end            
        end
    end

    methods(Access='public')
        % getRenderedData
        % returns a cell array of strings for the desired range of values
        function [renderedData, renderedDims] = getRenderedData(this,startRow,endRow,startColumn,endColumn)
            fullData = this.DataModel.Data;
            if ~isreal(fullData)
                % Set larger column widths by default for complex numbers
                this.setDefaultColumnWidths(this.DataModel.Data, ...
                    internal.matlab.variableeditor.VEColumnConstants.complexNumDefaultWidth);
            end
            
            this.setCurrentPage(startRow, endRow, startColumn, endColumn, false);
            dataSubset = this.getData(startRow,endRow,startColumn,endColumn);

            [renderedData, renderedDims] = internal.matlab.variableeditor.peer.PeerNumericArrayViewModel.getJSONForNumericData(fullData, dataSubset, startRow, endRow, startColumn, endColumn, this.usercontext, this.scalingFactorString);
        end
        
        function delete(this)
            if ~internal.matlab.variableeditor.peer.PeerUtils.isLiveEditor(this.usercontext)
                message.unsubscribe(this.perfSubscription);
            end
        end
    end
    
    methods(Static)
        function [renderedData, renderedDims, scalingFactorString] = getJSONForNumericData(fullData, dataSubset, startRow, endRow, startColumn, endColumn, usercontext, scalingFactorString)
            longData = dataSubset;
            [dataSubset, ~, scalingFactorString] = internal.matlab.variableeditor.peer.PeerDataUtils.getFormattedNumericData(fullData, dataSubset, usercontext, scalingFactorString);
            
            if ~strcmp(usercontext, 'liveeditor')
                f=get(0,'format');
                format('long');
                [longData, ~, scalingFactorString] = internal.matlab.variableeditor.peer.PeerDataUtils.getFormattedNumericData(fullData, longData, usercontext, scalingFactorString);
                format(f);
            end
            
            rowStrs = strtrim(cellstr(num2str([startRow-1:endRow-1]'))');
            colStrs = strtrim(cellstr(num2str([startColumn-1:endColumn-1]'))');
            renderedData = cell(size(dataSubset));
            
            try
                if ~strcmp(usercontext, 'liveeditor')
                for row=1:min(size(renderedData,1),size(dataSubset,1))
                    for col=1:min(size(renderedData,2),size(dataSubset,2))
                            jsonData = internal.matlab.variableeditor.peer.PeerUtils.toJSON(false, struct('value',dataSubset{row,col},...
                                'editValue',longData{row,col},'row',rowStrs{row},'col',colStrs{col}));

                       renderedData{row,col} = jsonData;
                    end
                end
                else
                renderedData = cellstr("{""value"":""" + dataSubset + """}");
                end
            catch
                a = 10;
                disp('helloworld');
            end
            
            renderedDims = size(renderedData);
        end

    end

    methods(Access='protected')
        function result = evaluateClientSetData(~, data, ~, ~)
            % In case of numerics, if the user types a single character in
            % single quotes, it is converted to its equivalent ascii value
            result = [];
            if (isequal(length(data), 3) && isequal(data(1),data(3),''''))
                result = double(data(2));
            end
        end

        function isValid = validateInput(this,value,row,column) %#ok<INUSL>
            % The only valid input types are 1x1 doubles
            isValid = isnumeric(value) && size(value, 1) == 1 && size(value, 2) == 1;
        end

        function replacementValue = getEmptyValueReplacement(this,row,column) %#ok<INUSL>
			replacementValue = 0;
        end
    end
end
