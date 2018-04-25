classdef VariableEditorArrayStrategy < matlab.ui.internal.controller.uitable.VariableEditorViewStrategy & ...
         internal.matlab.variableeditor.FormatDataUtils
     
    %VARIABLEEDITORARRAYVIEW Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        dataTypes = {'cell', 'double', 'logical'}; % valid data types.
    end
    
    
    
    methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        %  Constructor
        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function this = VariableEditorArrayStrategy(controller, document, ~)
            this@matlab.ui.internal.controller.uitable.VariableEditorViewStrategy(controller, document);
            
            this.createDataModelAndViewModel(document, this.getAdapter());
        end
        
        
        function adapter = getAdapter(this)
            if isempty(this.adapter)
                this.adapter = matlab.ui.internal.controller.uitable.VariableEditorArrayAdapter(this.controllerInterface);
            end
            adapter = this.adapter;
        end                
    end

    
    methods 
        
        function setViewData (this, value)     
            %set data
            setViewData@matlab.ui.internal.controller.uitable.VariableEditorViewStrategy(this, value);
            
            % configure headers.
            % show/hide row headers.
            noRowHeaders = isempty(value);
            this.ViewModel.setTableModelProperty('ShowRowHeaders', ~noRowHeaders);
            
            % show/hide column headers bar
            columnName = this.controllerInterface.getModelColumnName();
            showColumnHeaders = this.shouldShowColumnHeaders(columnName, value);
            this.ViewModel.setTableModelProperty('ShowColumnHeaders', showColumnHeaders);            
        end
        
        function setViewColumnFormat(this, formats)
            % set column-level formats to the view model.
            this.ViewModel.setColumnFormat(formats);
        end          
    end
   
    
end

