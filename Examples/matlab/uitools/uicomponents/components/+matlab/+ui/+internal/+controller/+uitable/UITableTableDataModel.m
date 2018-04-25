classdef UITableTableDataModel < internal.matlab.variableeditor.MLTableDataModel
    
    properties
        controllerInterface;
    end    
    
    methods(Access='public')
        % Constructor
        function this = UITableTableDataModel(name, workspace, controller)
            
            this = this@internal.matlab.variableeditor.MLTableDataModel(name, workspace);
            
            this.controllerInterface = controller;

            this.Data = table();
        end  
    end
    
    methods

        %setData
        % shouldn't set data directly in DataModel.
        function varargout = setData(this, varargin)
            assert(false);
        end
        
        % updateData
        % override to allow update a single value during cell editing
        % refresh.
        function data = updateData(this, varargin) 
            if nargin == 4
                % update single cell
                newValue = varargin{1};
                row = varargin{2};
                column = varargin{3};

                eventdata = internal.matlab.variableeditor.DataChangeEventData;
                eventdata.Range = [row column]';
                eventdata.Values = newValue;
                
                this.notify('DataChange',eventdata);
                
                data = ''; % no need of return;
            else 
                data = updateData@internal.matlab.variableeditor.MLTableDataModel(this, varargin{:});
            end
        end
        
        
        % Override setCommand for cell editing on TABLE data
        % return the setCommand only and will set data later.
        function varargout = executeSetCommand(this, setCommand, varargin)
            
            % update single cell
            if nargin == 6 
                editValue = varargin{1};
                row = varargin{2};
                column = varargin{3};
                columnIndex = varargin{4};

                % disable stack trace printing as part of the warning 
                %warnMode = warning('backtrace', 'off'); 
                this.controllerInterface.setModelCellData(editValue, row, column, columnIndex);
                %warning(warnMode);

                % refresh the view with the new data in the model.
                newData = this.controllerInterface.getModelData();
                newValue = newData(row,column);
                this.updateData(newValue, row, column);                
                
            end            

            % no error thrown to Variable Editor.
            varargout{1} = ''; 
        end
        
        function eq = equalityCheck(~, oldData, newData)
            eq = matlab.ui.internal.controller.uitable.isTableDataEqual(oldData, newData);
        end        
    end
end