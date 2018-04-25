classdef PeerUITableViewModelMixin < handle
    
    properties
        backgroundColor = [];
    end
    
    properties(Constant)
        % Define cell widget used in UITable view
        % follow the structure of VaraibleEditor's WidgetRegistry or reuse
        % one (e.g. combobox widget)
        
        % for all text cells. 
        text_widget = struct('CellRenderer', 'variableeditor/views/editors/UITableEditor', ...
                                'Editor', '', ...
                                'InPlaceEditor', 'variableeditor/views/editors/UITableEditor'); 
        % for string data
        string_widget = struct('CellRenderer', 'variableeditor/views/editors/UITableStringEditor', ...
                                'Editor', '', ...
                                'InPlaceEditor', 'variableeditor/views/editors/UITableStringEditor');                               
        % for logical data showing 'true'/'false'
        charLogical_widget = struct('CellRenderer', 'variableeditor/views/editors/UITableLogicalEditor', ...
                                    'Editor', '', ...
                                    'InPlaceEditor', 'variableeditor/views/editors/UITableLogicalEditor');                            
        % for logical data showing checkbox
        checkbox_widget = struct('CellRenderer', 'variableeditor/views/editors/CheckBoxEditor', ...
                                'Editor', '', ...
                                'InPlaceEditor', 'variableeditor/views/editors/CheckBoxEditor');
                            
        % for non-protected categorical data showing non-editable dropdown list
        nonEditableCategorical_widget = struct('CellRenderer', 'variableeditor/views/editors/UITableNonEditableComboboxEditor', ...', ...
                                'Editor', '', ...
                                'InPlaceEditor', 'variableeditor/views/editors/UITableNonEditableComboboxEditor');                            
                            
        % for unsupported data types, no editing behavior.                    
        unsupported_widget = struct('CellRenderer', 'variableeditor/views/editors/UITableEditor', ...
                                'Editor', '', ...
                                'InPlaceEditor', '');

        % for creating dropdown list via ColumnFormat property.
        combobox_widget = internal.matlab.variableeditor.peer.WidgetRegistry.getInstance().getWidgets('','categorical');          
    end 
    
    methods (Static)
        function registerUITableWidgets(peerClass, viewClass)
            
            registry = internal.matlab.variableeditor.peer.WidgetRegistry.getInstance();
            
            % Register the peer class for a JS view            
            registry.registerWidgets(peerClass, '', viewClass, '', '');            
            
            % Register the peer class to get cell widgets based on data types.
            registry.registerWidgets(peerClass, 'char', matlab.ui.internal.controller.uitable.PeerUITableViewModelMixin.text_widget.Editor, ...
                                                        matlab.ui.internal.controller.uitable.PeerUITableViewModelMixin.text_widget.InPlaceEditor, ...
                                                        matlab.ui.internal.controller.uitable.PeerUITableViewModelMixin.text_widget.CellRenderer);
            registry.registerWidgets(peerClass, 'double', matlab.ui.internal.controller.uitable.PeerUITableViewModelMixin.text_widget.Editor, ...
                                                        matlab.ui.internal.controller.uitable.PeerUITableViewModelMixin.text_widget.InPlaceEditor, ...
                                                        matlab.ui.internal.controller.uitable.PeerUITableViewModelMixin.text_widget.CellRenderer);                                                                                                      
            registry.registerWidgets(peerClass, 'logical', matlab.ui.internal.controller.uitable.PeerUITableViewModelMixin.checkbox_widget.Editor, ...
                                                           matlab.ui.internal.controller.uitable.PeerUITableViewModelMixin.checkbox_widget.InPlaceEditor, ...
                                                           matlab.ui.internal.controller.uitable.PeerUITableViewModelMixin.checkbox_widget.CellRenderer);             
            registry.registerWidgets(peerClass, 'string', matlab.ui.internal.controller.uitable.PeerUITableViewModelMixin.string_widget.Editor, ...
                                                          matlab.ui.internal.controller.uitable.PeerUITableViewModelMixin.string_widget.InPlaceEditor, ...
                                                          matlab.ui.internal.controller.uitable.PeerUITableViewModelMixin.string_widget.CellRenderer);
            registry.registerWidgets(peerClass, 'categorical', matlab.ui.internal.controller.uitable.PeerUITableViewModelMixin.nonEditableCategorical_widget.Editor, ...
                                                          matlab.ui.internal.controller.uitable.PeerUITableViewModelMixin.nonEditableCategorical_widget.InPlaceEditor, ...
                                                          matlab.ui.internal.controller.uitable.PeerUITableViewModelMixin.nonEditableCategorical_widget.CellRenderer);                                                       
            registry.registerWidgets(peerClass, 'unsupported', matlab.ui.internal.controller.uitable.PeerUITableViewModelMixin.unsupported_widget.Editor, ...
                                                               matlab.ui.internal.controller.uitable.PeerUITableViewModelMixin.unsupported_widget.InPlaceEditor, ...
                                                               matlab.ui.internal.controller.uitable.PeerUITableViewModelMixin.unsupported_widget.CellRenderer);                                                         
        end
    end
    
    methods
        
        function init(this, variable, viewmodel)
            
            
            % Remove the quotes on the strings for data in the UITable.
            this.setTableModelProperty('RemoveQuotedStrings', true);
            
            %Set the headers editable false 
            this.setTableModelProperty('EditableColumnHeaderLabels', false);
            this.setTableModelProperty('EditableRowHeaderLabels', false);
            
            % Remove header labels
            this.setTableModelProperty('ShowColumnHeaderLabels', false);
            this.setTableModelProperty('ShowRowHeaderLabels', false); 
            
            % attach listener for CellSelection event
            listener = addlistener(this, 'SelectionChanged', @(es, ed)this.cellSelectionHandler(es,ed));            
        end
        
        
        % ToDo: Current selection mode of the DataTools table is only for
        % single cell and area selection, not for discontiguous selection.
        % The following function will need to change when DataTools table
        % supports the discontiguous selection, because the event data is
        % not in the same form of {[startRow endRow], [startColumn endColumn]}.
        function cellSelectionHandler(this, ~, data)
            % current DataTools event data is in form of {[startRow endRow], [startColumn endColumn]}
            selected = data.Selection;
            
            % a click-away action will also sent out a 'SelectionChange'
            % event with empty selected data. g1250215
            if isempty(selected{1})
                return; % No need to execute CellSelectionCallback logic.
            end
                        
            startRow = selected{1}(1);
            endRow = selected{1}(2);
            startColumn = selected{2}(1);
            endColumn = selected{2}(2);
            
            % construct model CellSelection data
            
            % e.g. convert event data {[2 3], [1 2]} to 
            %   [2 1;
            %    2 2;
            %    3 1;
            %    3 2]
            modelData = zeros((endRow-startRow+1)*(endColumn-startColumn+1), 2);
            index = 1;
            for r = startRow:endRow
                for c = startColumn:endColumn
                    modelData(index, 1) = r;
                    modelData(index, 2) = c;
                    index = index + 1;
                end
            end
            this.DataModel.controllerInterface.setModelCellSelectionEvent(modelData);            
        end        
        
        
        function updatePagedBackgroundColor(this, doUpdate)
            % get actual rendering size on the current page.
            dataSize = size(this.DataModel.Data);
            [startRow, endRow, ~, ~] = this.getPagedSize(dataSize);
            
            c = round(255 * this.backgroundColor);
            numColors = size(c, 1);
            
            if(numColors > 0)
                %get the color index
                colorIndex = mod(0:dataSize(1) - 1, numColors) + 1;
                for row = startRow:endRow
                    hexColor = ['#' dec2hex(c(colorIndex(row),1),2) dec2hex(c(colorIndex(row),2),2) dec2hex(c(colorIndex(row),3),2)];
                    this.setRowModelProperty(row, 'backgroundColor', hexColor, false);
                end
                
                if nargin<2
                    doUpdate = true;
                end 

                if doUpdate
                    this.updateRowModelInformation(this.StartRow, this.EndRow);
                end
            end
        end  
        
        % get the actural rendering size on the current page.
        function [startRow, endRow, startColumn, endColumn] = getPagedSize(this, dataSize)
            if ~isempty(dataSize)
                startRow = max(1, this.StartRow);
                endRow = min(this.EndRow, dataSize(1));
                startColumn = max(1, this.StartColumn);
                endColumn = min(this.EndColumn, dataSize(2));
            end
        end 
        
        % For given data type, get widget for uitable class (if available). 
        function [widget, className] = getUITableWidget(this, registry, tData, row, column)
            
            if iscell(tData.(column))
                value = tData.(column){row};
            else
                value = tData.(column)(row);
            end

            % non scalar value is unsupported in cell.
            if ischar(value) || isscalar(value)
                className = class(value);
            else
                className = 'unsupported'; % set unsupported for all non-scalar data
            end
                
            if ismember(className, {'logical', 'double', 'char', 'string', 'unsupported'})
                % provide uitable specific widgets.
                [widget, ~, matchedVariableClass] = registry.getWidgets(class(this), className);
            elseif isequal (className, 'categorical')
                if isprotected(value)
                    % get UITable non-editable combobox (mw-combobox)
                    [widget, ~, matchedVariableClass] = registry.getWidgets(class(this), className);
                else
                    % get Variable Editor editable combobox.
                    [widget, ~, matchedVariableClass] = registry.getWidgets('', className);
                    % configure 
                    update = this.disableColumnModelUpdate();
                    this.setColumnModelProperties(column, 'isProtected', false, 'showUndefined', false);
                    this.resumeColumnModelUpdate(update);
                end
            else
                % get default widget from VE.
                [widget, ~, matchedVariableClass] = registry.getWidgets('', className);
            end
            
            % get UITable unsupported widget
            if ~strcmp(className,matchedVariableClass)
                widget = registry.getWidgets(class(this),'unsupported');
                className = 'char'; % left alignment
            end
        end
        
    end

    
    % public utils
    methods        
        function refreshCurrentPage(this)
            % refresh all model properties for current view page.
            this.updateCurrentPageModels();
        end
        
        function refreshCurrentTable(this)
            % refresh only Table model properties for current view page
            this.updateTableModelInformation();
        end
        
        function refreshCurrentRows(this)
            this.updateRowModelInformation(this.StartRow, this.EndRow);
        end
        
        function refreshCurrentColumns(this)
            this.updateColumnModelInformation(this.StartColumn, this.EndColumn);
        end            
        
        function refreshCurrentCells(this)
            this.updateCellModelInformation(this.StartRow, ...
                                                      this.EndRow, ...
                                                      this.StartColumn, ...
                                                      this.EndColumn);
        end
    end
    
end