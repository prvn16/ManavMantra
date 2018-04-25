classdef PeerSortHandler < handle
    % Class to handle Sort Events in the LE

    % Copyright 2017 The MathWorks, Inc.

    properties
        commandArray = [];
        codeArray = [];
        origData;
        DataModel;
        ViewModel;
        Index;
        Direction;
        isUndoRedoAction = false;
        undoCommandArray = [];
    end

    methods
        function this = PeerSortHandler(parentNode, variable)
            this.DataModel = variable.DataModel;
            this.origData = this.DataModel.Data;
            this.ViewModel = parentNode;
        end

        function newSortCommand(this, sortInfo)
            this.Index = sortInfo.index + 1;
            order = sortInfo.order;
            if strcmpi(order, 'asc')
                this.Direction = 'ascend';
            else
                this.Direction = 'descend';
            end
            CurrentRange = sortInfo.range;
            this.ViewModel.setTableModelProperty('LastSorted', struct('index', sortInfo.index, 'order', sortInfo.order), true);
            this.executeCode(this.Index, this.Direction);
            this.updateClientView(CurrentRange);

            % commandArray contains a list of call the interactive sort commands issued for a output
            this.commandArray = [this.commandArray, struct('Index',this.Index, 'Direction',this.Direction)];

            % codeGenArray is a subset of commandArray containing the commands for which code
            % needs to be generated
            codeGenArray = [];

            % Logic used to filter down list of commands to only those which should generate code
            indexList = [this.Index];
            for i = length(this.commandArray):-1:1
                if (~ismember(this.commandArray(i).Index, indexList))
                    codeGenArray = [codeGenArray, this.commandArray(i)];
                    indexList = [indexList, this.commandArray(i).Index];
                end
            end
            codeGenArray = fliplr(codeGenArray);
            codeGenArray = [codeGenArray, this.commandArray(end)];

            % converting the sort commands into MATLAB codeArray
            % each child class has its own implementation of the sortCodeGen method
            this.codeArray = arrayfun(@(tmp)this.sortCodeGen(tmp.('Index'), tmp.('Direction')), codeGenArray, 'UniformOutput', false);
            this.publishCode();
        end

        function executeCode(this, index, direction)
            % Performs the sort by calling the sortrows command
            this.DataModel.Data = sortrows(this.DataModel.Data, index, direction);
        end

        function updateClientView(this, range)
            % Updates the view on the client side after data is sorted on the server
            columns = range.get('columns');
            rows = range.get('rows');
            startColumn = columns.get('start');
            endColumn = columns.get('end');
            startRow = rows.get('start');
            endRow = rows.get('end');
            this.ViewModel.updateRowModelInformation(startRow + 1, endRow + 1);
            this.ViewModel.refreshRenderedData(struct('startRow', startRow ,'endRow', endRow, 'startColumn', startColumn, 'endColumn', endColumn));
        end

        function publishCode(this)
            % Publish the generated code to the client
            % Append isUndoRedoAction to message so server knows whether it is
            % a new sort action or an undo action
            this.codeArray = [this.codeArray, this.isUndoRedoAction];
            codeArrayJSON = internal.matlab.variableeditor.peer.PeerUtils.toJSON('codeArray', this.codeArray);
            % Subscriber is the LiveEditorCodePublishService
            message.publish('/DataToolsCodePubChannel'+"/"+ this.ViewModel.PeerNode.Id, codeArrayJSON);
            this.isUndoRedoAction = false;
        end

        function undo(this, undoInfo)
            % Undo the sort action
            CurrentRange = undoInfo.range;
            this.isUndoRedoAction = true;
            % Set the data as original data and resort after popping last sort command
            this.DataModel.Data = this.origData;
            % Discarding entire code array since we are going to re-crete it.
            this.codeArray = [];
            % Appending the undo command to the an undo stack for redo.
            this.undoCommandArray = [this.undoCommandArray, this.commandArray(end)];
            % Discarding last command before undo.
            this.commandArray(end) = [];
            if isempty(this.commandArray)
                % If commmandrray is empty, exit early since data is no longer sorted
                % Set the sortOrder to "none" and the sortIndex to -1 to
                % clear the indicator
                this.ViewModel.setTableModelProperty('LastSorted', struct('index', -1, 'order', 'NONE'), true);
                this.updateClientView(CurrentRange);
                this.codeArray = {';'};
                this.publishCode();
                return
            end
            index = this.commandArray(end).Index;
            index = index - 1;
            direction = this.commandArray(end).Direction;
            if strcmpi(direction, 'ascend')
                order = 'ASC';
            else
                order = 'DESC';
            end
            % Removing this command since we are going to re-generate it.
            this.commandArray(end) = [];

            % Re-running all the sort commands on the original data to get
            % back the same sort state.
            % This can be improved by saving only the row indices of the
            % orignial data.
            for i = 1:length(this.commandArray)
                this.executeCode(this.commandArray(i).Index, this.commandArray(i).Direction);
            end
            this.newSortCommand(struct('index', index, 'order', order, 'range', CurrentRange));
        end
        
        function redo(this, redoInfo)
            % Redo the previous sort undo action
            CurrentRange = redoInfo.range;
            this.isUndoRedoAction = true;
            index = this.undoCommandArray(end).Index;
            index = index - 1;
            direction = this.undoCommandArray(end).Direction;
            if strcmpi(direction, 'ascend')
                order = 'ASC';
            else
                order = 'DESC';
            end
            % Removing this command from undo stack since we are going to redo it
            this.undoCommandArray(end) = [];

            % Passing the last undo command as a new redo
            this.newSortCommand(struct('index', index, 'order', order, 'range', CurrentRange));
        end

    end
end
