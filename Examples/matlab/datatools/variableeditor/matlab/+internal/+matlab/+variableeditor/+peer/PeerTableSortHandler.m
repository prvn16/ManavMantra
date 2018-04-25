classdef PeerTableSortHandler < internal.matlab.variableeditor.peer.PeerSortHandler
    % Class to handle Sort Events on the tables in the LE
    % Table Sort Handler IS A Sort Handler

    % Copyright 2017 The MathWorks, Inc.

    properties
        TableName;
    end

    methods
        function this = PeerTableSortHandler(parentNode, variable)
            this = this@internal.matlab.variableeditor.peer.PeerSortHandler(parentNode,variable);
            this.TableName = variable.Name;
        end
        function newSortCommand(this, sortInfo)
            this.newSortCommand@internal.matlab.variableeditor.peer.PeerSortHandler(sortInfo);
        end
        function undo(this, undoInfo)
            this.undo@internal.matlab.variableeditor.peer.PeerSortHandler(undoInfo);
        end
        function redo(this, redoInfo)
            this.redo@internal.matlab.variableeditor.peer.PeerSortHandler(redoInfo);
        end
        function updateClientView(this, range)
            this.updateRowHeadersInViewModel();
            this.updateClientView@internal.matlab.variableeditor.peer.PeerSortHandler(range);
        end
        function updateRowHeadersInViewModel(this)
            % Updates the row headers on the client side after sort is performed
            % Check if it is a timetable
            if istimetable(this.DataModel.Data)
                temp = 'RowTimes';
            else
                temp = 'RowNames';
            end
            % Need to do this because header prop is different for TT
            if ~isempty(this.DataModel.Data.Properties.(temp))
                for i = 1:length(this.ViewModel.RowModelProperties)
                    this.ViewModel.RowModelProperties{i}.RowName = char(this.DataModel.Data.Properties.(temp)(i));
                end
            end
        end
        function sortCode = sortCodeGen(this, Index, Direction)
            % Function to generate code for the sort operation
            varName = this.TableName;
            colName = this.DataModel.Data.Properties.VariableNames{Index};
            tableVariableNames = colName;
            if iscell(tableVariableNames)
                tableVariableNameString = '{';
                for k=1:length(tableVariableNames)-1
                    tableVariableNameString = [tableVariableNameString tableVariableNames{k} ',']; %#ok<AGROW>
                end
                tableVariableNamesString = [tableVariableNameString tableVariableNames{end} '}'];
            else
                tableVariableNamesString = tableVariableNames;
            end
            % Add the direction to the generated code only if descending
            if strcmp(Direction, 'ascend')
                sortCode = [varName ' = sortrows(' varName ',' char(39) tableVariableNamesString char(39) ');'];
            else
                sortCode = [varName ' = sortrows(' varName ',' char(39) tableVariableNamesString char(39) ',' char(39) Direction char(39) ');'];
            end
        end
    end
end
