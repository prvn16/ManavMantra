classdef (Abstract) VariableEditorViewStrategy < handle
    %VARIABLEEDITORTABLEVIEW Summary of this class goes here
    %   Detailed explanation goes here
    
    %   Copyright 2014-2017 The MathWorks, Inc.    
    
    properties (Access = 'protected')
        controllerInterface;
        DataModel;
        ViewModel;
        adapter;
    end

    methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        %  Constructor
        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function this = VariableEditorViewStrategy(controller, document)       
            this.controllerInterface = controller;   
        end

        function delete (this)
            delete(this.DataModel);
            delete(this.ViewModel);
        end 
        
        % create DataModel and ViewModel with existing document.
        function createDataModelAndViewModel(this, document, adapter)
         
            if ~isempty(document)             
                this.DataModel = adapter.getDataModel(document);
                this.ViewModel = adapter.getViewModel(document);
                
                % assign back to document
                document.setDataModel(this.DataModel);
                document.setViewModel(this.ViewModel);   
            end 
        end        
        
        function setDataModelAndViewModel(this, dm, vm)
            this.DataModel = dm;
            this.ViewModel = vm;
        end
         
    end
    
    
    % abstract methods
    methods (Abstract)
        adapter = getAdapter(this);
    end
    
    % abstract properties
    properties (Abstract)
        dataTypes;
    end
    



    
    methods 
        
        function setViewData (this, value)
            % configure headers in derived strategies.

            %Set data         
            this.DataModel.updateData(value);             
        end
        
        function setViewColumnName (this, columnName)

            %show/hide column header bar
            data = this.controllerInterface.getModelData();
            showColumnHeaders = this.shouldShowColumnHeaders(columnName, data);
            this.ViewModel.setTableModelProperty('ShowColumnHeaders', showColumnHeaders);
         
            % show/hide header numbers and labels.
            isNumbered = isequal(columnName, 'numbered');
            this.ViewModel.setTableModelProperty('ShowColumnHeaderNumbers', isNumbered);
            this.ViewModel.setTableModelProperty('ShowColumnHeaderLabels', ~isNumbered);

            % display non-numbered column headers
            if showColumnHeaders && ~isNumbered
                if ischar(columnName)   %char array
                    % every row means a header name
                    for i = 1:size(columnName, 1)
                        this.ViewModel.setColumnModelProperty(i, 'HeaderName', columnName(i, :), false);
                    end
                elseif iscell(columnName)   %cell array
                    for i = 1:length(columnName)
                        newVal = columnName{i};
                        if isempty(newVal) 
                            newVal = ' ';
                        end
                        this.ViewModel.setColumnModelProperty(i,'HeaderName',newVal, false);
                    end 
                end 

                % clear out remaining names in ColumnModelProperties 
                for j = i+1:length(this.ViewModel.ColumnModelProperties)
                    this.ViewModel.setColumnModelProperty(j, 'HeaderName', '', false);
                end
            end
            
            % refresh view 
            this.ViewModel.refreshCurrentColumns();
        end
        
        
         function setViewRowName (this, rowName)
            data = this.controllerInterface.getModelData();   
            % show/hide row header if either Data or RowName is empty
            % 16b only solution. Will have a full design in 17a.
            noRowHeaders = isempty(data) || isempty(rowName);
            this.ViewModel.setTableModelProperty('ShowRowHeaders', ~noRowHeaders);
            
            if ~noRowHeaders
                % show/hide header numbers and labels.
                isNumbered = isequal(rowName, 'numbered');
                this.ViewModel.setTableModelProperty('ShowRowHeaderNumbers', isNumbered);
                this.ViewModel.setTableModelProperty('ShowRowHeaderLabels', ~isNumbered);

                % Not 'numbered' case
                if ~isNumbered
                    if ischar(rowName)  %char array
                        % every row means a header name
                        for i = 1:size(rowName, 1)
                            this.ViewModel.setRowModelProperty(i, 'RowName', rowName(i, :), false);
                        end
                    elseif iscell(rowName)  %cell array
                        for i = 1:length(rowName)
                            this.ViewModel.setRowModelProperty(i,'RowName',rowName{i}, false);
                        end 
                    end
                    %TODO need a way to clear out previous set
                    % clear out remaining names
                    for j = i+1:size(data, 1)
                        this.ViewModel.setRowModelProperty(j, 'RowName', '', false);
                    end                    
                end
            end
            
            % refresh view 
            this.ViewModel.refreshCurrentRows();
         end
        

        
        function setViewColumnEditable (this, edit, doUpdate)
            if nargin == 2
                doUpdate = true;
            end
            
            if isempty(edit)
                this.ViewModel.setTableModelProperty('Editable', false);
            elseif isequal(edit, true)
                this.ViewModel.setTableModelProperty('Editable', true);
            elseif isequal(edit, false)
                this.ViewModel.setTableModelProperty('Editable', false);
            else
                this.ViewModel.setTableModelProperty('Editable', true);
                dataSize = size(this.controllerInterface.getModelData);
                dataWidth = dataSize(2);
                editableWidth = length(edit);
                
                for i = 1:min(dataWidth, editableWidth)
                    this.ViewModel.setColumnModelProperty(i,'Editable', edit(i), false);
                end
           
                % set remaining columnEditable to be false
                if (editableWidth < dataWidth)
                    for i = min(dataWidth, editableWidth)+1:dataWidth
                        this.ViewModel.setColumnModelProperty(i,'Editable', false, false);
                    end
                end
            end
            
            if doUpdate
                this.ViewModel.refreshCurrentColumns();
            end
        end
        
        function setViewColumnFormat(this, formats)
            % no op
        end    
        
        % Width of table columns, specified as a 1-by-n cell array or 'auto'.
        % 'auto' means:
        %   - Default minimum size in pixel (75). 
        %   - If column header has a longer text, the width should automatically fit to show all content of this header. 
            
        % @ToDo currently 'auto' ColumnWidth only supports the 1st and 2nd feature.
        % 17a we will have a full design and implementation of AUTO column width.
        function setViewColumnWidth(this, columnWidth)
            
            this.ViewModel.disableColumnModelUpdate();
            
            columnName = this.controllerInterface.getModelColumnName();
            data = this.controllerInterface.getModelData();
            
            % get how may column headers will be shown in the view.
            if isequal(columnName, 'numbered')
                headers = size(data, 2);
            else
                headers = max(size(data, 2), length(columnName));
            end            
            
            % set column widths to the view.
            if ischar(columnWidth) 
                % 'auto' case
                this.ViewModel.setColumnModelProperty(1:headers, 'ColumnWidth', -1, false);
            else
                % ColumnWidth property is a cell array of 'auto' and number
                for i = 1:size(columnWidth, 2)
                    if strcmpi(columnWidth{i}, 'auto')
                        this.ViewModel.setColumnModelProperty(i, 'ColumnWidth', -1, false);
                    else
                        this.ViewModel.setColumnModelProperty(i, 'ColumnWidth', columnWidth{i}, false);
                    end
                end
                
                % May have more columns after the last item in ColumnWidth
                for j = i+1:headers
                    this.ViewModel.setColumnModelProperty(j, 'ColumnWidth', -1, false);
                end
            end            

            % refresh
            this.ViewModel.resumeColumnModelUpdate([], true);
            this.ViewModel.refreshCurrentColumns();
            
        end        
        
        function setViewBackgroundColor(this, value)
          
            % set the background color property 
            this.ViewModel.backgroundColor = value;

            % update the background color on set bg property 
            this.ViewModel.updatePagedBackgroundColor(true);           
        end
        
        function setViewForegroundColor(this, value)
          c = round(255 * value);
          hexColor = ['#' dec2hex(c(1),2) dec2hex(c(2),2) dec2hex(c(3),2)];
          % set foregroundcolor to the view model.
          this.ViewModel.setTableModelProperty('color', hexColor);
        end
        
        function setViewFontWeight(this, value)
            % set fontWeight to the view model.
            this.ViewModel.setTableModelProperty('fontWeight', value);
        end 
        
        function setViewFontAngle(this, value)
            % set fontAngle to the view model.
            this.ViewModel.setTableModelProperty('fontStyle', value);
        end
        
        function setViewFontSize(this, value)
            % set fontSize to the view model.
            fontSize = value.FontSize;
            fontUnits = convertFontUnits(this, value.FontUnits);
            value = strcat(num2str(fontSize), fontUnits);
            this.ViewModel.setTableModelProperty('fontSize', value);
        end
        
        function setViewFontName(this, value)
            fontName = strcat(value, ', Helvetica, sans-serif');
            % set fontName to the view model.
            this.ViewModel.setTableModelProperty('fontFamily', fontName);
        end 
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%% util methods %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    methods
        % given column names and data, column headers may be shown or not.
        function show = shouldShowColumnHeaders(~, columnName, data)
            % Situations we need to hide column headers
            % - ColumnName property is set to empty.
            % - Data property is empty AND ColumnName property is
            % 'numbered' - for initial table view.            
            noColumnHeader = isempty(columnName) || ...
                             (isempty(data) && isequal(columnName, 'numbered'));
            
            show = ~noColumnHeader;
        end        
    end
    
    methods ( Access = 'private' )
        
        function value =  convertFontUnits(~, value)
            if(isequal(value, 'points'))
                value = 'pt';
            elseif(isequal(value, 'inches'))
                value = 'in';
            elseif(isequal(value, 'centimeters'))
                value = 'cm';
            elseif(isequal(value, 'pixels'))
                value = 'px';
            end    
        end
        


    end    
    
end

