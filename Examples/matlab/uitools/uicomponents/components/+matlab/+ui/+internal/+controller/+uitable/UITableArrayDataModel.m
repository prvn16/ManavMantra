classdef UITableArrayDataModel < internal.matlab.variableeditor.MLArrayDataModel
    % UITableArrayDataModel

    % Copyright 2014-2017 The MathWorks, Inc.

    
    properties (SetAccess='private')
        Type = 'UITableData';
        ClassType = 'UITableData';
    end
    
    properties
        controllerInterface;
    end
    
    % Dependent Data property.    
    properties (SetObservable=true, Dependent=true)
        Data;
    end
    
    methods
        % Data getter
        function data = get.Data(this)
            data = this.controllerInterface.getModelData();
        end
        
        % Data setter
        function set.Data(~, ~)
            % No use case currently for set bulk data from view to model.
            % ignore Data set
        end
    end 

    methods(Access='public')
        % Constructor
        function this = UITableArrayDataModel(name, workspace, viewInterface)
            %TODO need to refactor
            this@internal.matlab.variableeditor.MLArrayDataModel(name, workspace);
            this.controllerInterface = viewInterface;
        end
        
        % setData
        % Called from ViewModel.
        % Always set single cell value

        function varargout = setData(this, newValue, row, column)
          
            % disable stack trace printing as part of the warning 
            warnMode = warning('backtrace', 'off'); 
            this.controllerInterface.setModelCellData(newValue, row, column);
            warning(warnMode);

            % @TODO we need to manually get the updated data, because Component Framework will not automatically
            % propagate the Data change of CellEditCallBack (not through doPostSet process). 

            % refresh the view with the validated value in the model.
            validatedValue = this.Data(row,column);
            this.updateData(validatedValue, row, column);

            varargout{1} = '';
            
        end
        
        % updateData
        % Update a block of values.
        % If only one paramter is specified, that parameter is assumed to be
        % the data and all of the data is replaced by that value.
        % If three paramters are passed in the the first value is assumed
        % to be the data and the second is the row and third the column.

        function data = updateData(this, newData, varargin)
            % refresh view by notifying the 'DataChange' event
            eventdata = internal.matlab.variableeditor.DataChangeEventData;
            
            if nargin == 2
                % all of data will be refreshed.
                [I,J] = meshgrid(1:size(newData,1),1:size(newData,2));
                I = I(:)';
                J = J(:)';
                eventdata.Range = [I; J];
                eventdata.Values = [];
            else % refresh one single cell
                row = varargin{1};
                column = varargin{2};

                eventdata.Range = [row column]';
                eventdata.Values = newData;
            end            

            this.notify('DataChange',eventdata);                
            data = '';
        end
    end %methods
    
    
   % @ToDo Need to refactor out.
    methods(Access='protected')
        function [I,J] = doCompare(~, ~)
            assert(false);
        end

        function lhs=getLHS(~,~)
            assert(false);
        end
    end
end
