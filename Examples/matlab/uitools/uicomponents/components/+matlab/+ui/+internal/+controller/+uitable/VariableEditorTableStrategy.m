classdef VariableEditorTableStrategy < matlab.ui.internal.controller.uitable.VariableEditorViewStrategy

    %VARIABLEEDITORTABLEVIEW Summary of this class goes here
    %   Detailed explanation goes here
    
    %   Copyright 2017 The MathWorks, Inc.
    
    properties
        dataTypes = {'table'}; % valid data types.
    end



    methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        %  Constructor
        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function this = VariableEditorTableStrategy(controller, document)
            this@matlab.ui.internal.controller.uitable.VariableEditorViewStrategy(controller, document);

            this.createDataModelAndViewModel(document, this.getAdapter());
        end

        function adapter = getAdapter(this)
            if isempty(this.adapter)
                this.adapter = matlab.ui.internal.controller.uitable.VariableEditorTableAdapter(this.controllerInterface);
            end

            adapter = this.adapter;
        end

        function delete (this)
            if ~this.controllerInterface.isModelDeleted()
                % restore column/row name to 'numbered' if necessary.
                if this.controllerInterface.isColumnNameModeAuto()
                    this.controllerInterface.setModelColumnName('numbered');
                end
                if this.controllerInterface.isRowNameModeAuto()
                    this.controllerInterface.setModelRowName('numbered');
                end
            end

            delete@matlab.ui.internal.controller.uitable.VariableEditorViewStrategy(this);
        end
    end



    methods

        function setViewData (this, value)
            % set data
            setViewData@matlab.ui.internal.controller.uitable.VariableEditorViewStrategy(this, value);

            % if ColumnName/RowName property hasn't been set before,
            % then uitable leverages Table's VariableNames/RowNames
            if this.controllerInterface.isColumnNameModeAuto()
                this.controllerInterface.setModelColumnName(value.Properties.VariableNames);
            end

            if this.controllerInterface.isRowNameModeAuto()
                this.controllerInterface.setModelRowName(value.Properties.RowNames);
            end
        end

        function setViewColumnName(this, name)
            % if user has set ColumnName property.
            this.ViewModel.UseTableColumnNamesForView = this.controllerInterface.isColumnNameModeAuto();

            setViewColumnName@matlab.ui.internal.controller.uitable.VariableEditorViewStrategy(this,name);
        end

        function setViewRowName(this, name)
            % if user has set RowName property.
            this.ViewModel.UseTableRowNamesForView = this.controllerInterface.isRowNameModeAuto();

            setViewRowName@matlab.ui.internal.controller.uitable.VariableEditorViewStrategy(this,name);
        end     
        
        function setViewColumnFormat(~, formats)
            if ~isempty(formats)
                w = warning('backtrace', 'off'); 
                warning(message('MATLAB:uitable:ColumnFormatNotSupported'));
                warning(w);
            end
        end

		function setViewColumnEditable(this, edit)

            %Set call editable for the Default datatypes
            setViewColumnEditable@matlab.ui.internal.controller.uitable.VariableEditorViewStrategy(this, edit, false);

            %Update ColumnEditable for only valid datatypes
            this.validateEditableDataTypes(edit);

            %refresh the columns
            this.ViewModel.refreshCurrentColumns();

        end

        % For Table Data only the following data types are editable.
        % Invalid variable types for interactive editing are:
        % * cell array (except cell array of characters - using cellstr)
        % * duration
        % * multi-column variables (sub columns)
        % * other unknown types.
        
        function validateEditableDataTypes (this, edit)
 
            showWarning = false;
            data = this.controllerInterface.getModelData;
            dataWidth = size(data, 2);
            editableWidth = length(edit);

            %Case 1: If Edit is empty - return
            %Case 2: If Edit Scalar false - return
            if isempty(edit) || isequal(edit, false)
                return;
            end

            %Case 3: if Edit Scalar true
            %Case 4: if edit is vector of true/false
            if isequal(edit, true) && editableWidth == 1
                col = dataWidth;
                edit = true(col, 1); % update edit to be vector of true
            else
                % take min value of the column width or data to loop
                % through columns
                col = min(dataWidth, editableWidth);
            end

            % loop through teh data and set the column editable false as in
            % the base class all clolumns are set to true by default
            for i = 1:col
                % for non-editable data types.
                if edit(i) && ~this.isEditableDataType(data.(i))
                    showWarning = true;
                    this.ViewModel.setColumnModelProperty(i,'Editable', false, false);
                end
            end

            % show the warning msg based on the flag
            if showWarning
                w = warning('backtrace', 'off'); 
                warning(message('MATLAB:uitable:NonEditableDataTypes'));
                warning(w);
            end
        end 

        
        
        function isEditable = isEditableDataType (this, colData)
            isEditable = false;
            
            % variable with multiple sub columns is not editable.
            if size(colData, 2) > 1
                return;
            end
            
            if iscellstr(colData) || ...   % cell array of characters
               ismember(class(colData), {'char', 'string', 'double','logical', 'datetime', 'categorical'})
                % return true for all editable data types.
                isEditable = true;
            end
               
        end
    end
end

