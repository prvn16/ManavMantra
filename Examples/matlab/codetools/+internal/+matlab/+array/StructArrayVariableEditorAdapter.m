%   Copyright 2012-2016 The MathWorks, Inc.

classdef StructArrayVariableEditorAdapter

    methods (Static=true)
        
        function varargout = variableEditorGridSizeWorkspace(workspaceID, workspaceVariableName)
            % Get the current value from the specified workspace
            theWorkspace = workspacefunc('getworkspace', workspaceID);
            currentValue = localGetValueFromWorkspace(theWorkspace, workspaceVariableName);
            
            varargout = internal.matlab.array.StructArrayVariableEditorAdapter.variableEditorGridSize(...
                currentValue);
            varargout = {varargout};
        end

        function varargout = variableEditorGridSize(a)
            % Returns the size of the grid needed to display the struct
            % vector.
            if isempty(a) % The Variable Editor can be open for empty struct array
                gridSize = [0 0];
            elseif isvector(a)
                gridSize = [length(a) length(fieldnames(a))];
            else % The Variable Editor should not use a 2d grid to display ND arrays
                gridSize = [size(a,1) 0];
            end
            if nargout==2
                varargout{1} = gridSize(1);
                varargout{2} = gridSize(2);
            elseif nargout==1
                varargout{1} = gridSize;
            end
        end
        
        function [names, indices, classes, cellstrflag, charwidths] = variableEditorColumnNamesWorkspace(...
                workspaceID, workspaceVariableName)
            % Get the current value from the specified workspace
            theWorkspace = workspacefunc('getworkspace', workspaceID);
            currentValue = localGetValueFromWorkspace(theWorkspace, workspaceVariableName);
            
            [names, indices, classes, cellstrflag, charwidths] = internal.matlab.array.StructArrayVariableEditorAdapter.variableEditorColumnNames(...
                currentValue);
        end
        
        function scalarNumeric = variableEditorIsScalarNumericSelection(...
                a, rowIntervals, columnIntervals)
            % Called to determine if a selection contains only scalar
            % numeric values or not.
            
            % Convert struct array to cell array for better performance
            varCell = localConvertToCell(a);
            
            rowInterval = str2num(localGetRowIntervalString(rowIntervals)); %#ok<ST2NM>
            colInterval = str2num(localGetRowIntervalString(columnIntervals)); %#ok<ST2NM>

            % Grab the data from the cell array
            varData = varCell(rowInterval, colInterval);
            
            % It is considered scalar numeric if it is logical or double,
            % and is a scalar value.
            scalarNumeric = localIsScalarNumeric(varData);
        end
        
        function [names, indices, classes, cellstrflag, charwidths] = variableEditorColumnNames(a)
            % Returns information about the columns (fields) for displaying
            % the struct vector in the variable editor.
            
            % column names are the field names
            names = fieldnames(a);
            
            % indices identifies the column positions of each struct field
            % variable with an additional last value of indices is the
            % column after the last column of the struct .
            indices = 1:length(names)+1;
            
            % determine class type for each column
            classes = cell(length(names), 1);
            
            % Convert struct array to cell array for better performance
            varCell = localConvertToCell(a);
            for varIndex = 1:length(names)
                varData = varCell(:, varIndex);
                isEmpty = cellfun('isempty', varData);
                
                if all(isEmpty)
                    classes{varIndex, 1} = 'double';
                elseif all(cellfun('isclass', varData, 'dataset') | isEmpty)
                    classes{varIndex, 1} = 'dataset';
                elseif all(cellfun('isclass', varData, 'table') | isEmpty)
                    classes{varIndex, 1} = 'table';
                elseif all(cellfun(@isnumeric, varData) | isEmpty)
                    %allSingleValue = cellfun(@(x) (numel(x) == 1), varData);
                    allSingleValue = cellfun('prodofsize', varData);
                    if all((allSingleValue == 1) | isEmpty)
                        classes{varIndex, 1} = 'double';
                    else
                        classes{varIndex, 1} = 'mixed';
                    end
                elseif all(cellfun('isclass', varData, 'cell') | isEmpty)
                    classes{varIndex, 1} = 'cell';
                elseif all(cellfun(@islogical, varData) | isEmpty)
                    classes{varIndex, 1} = 'logical';
                elseif all(cellfun('isclass', varData, 'char') | isEmpty)
                    classes{varIndex, 1} = 'char';
                elseif all(cellfun('isclass', varData, 'struct') | isEmpty)
                    classes{varIndex, 1} = 'struct';
                elseif all(cellfun('isclass', varData, 'timeseries') | isEmpty)
                    classes{varIndex, 1} = 'timeseries';
                elseif all(cellfun('isclass', varData, 'ordinal') | isEmpty)
                    classes{varIndex, 1} = 'ordinal';
                elseif all(cellfun('isclass', varData, 'nominal') | isEmpty)
                    classes{varIndex, 1} = 'nominal';
                elseif all(cellfun('isclass', varData, 'categorical') | isEmpty)
                    classes{varIndex, 1} = 'categorical';
                elseif all(cellfun('isclass', varData, 'datetime') | isEmpty)
                    classes{varIndex, 1} = 'datetime';
                elseif all(cellfun('isclass', varData, 'duration') | isEmpty)
                    classes{varIndex, 1} = 'duration';
                elseif all(cellfun('isclass', varData, 'calendarDuration') | isEmpty)
                    classes{varIndex, 1} = 'calendarDuration';
                elseif all(cellfun('isclass', varData, 'string') | isEmpty)
                    classes{varIndex, 1} = 'string';
                elseif all(cellfun(@isobject, varData) | isEmpty)
                    % Object needs to be after others, since they may be
                    % objects as well.
                    classes{varIndex, 1} = 'object';
                else
                    % This field contains mixed data
                    classes{varIndex, 1} = 'mixed';
                end
            end
            cellstrflag = false(1,length(names));
            for col=1:length(names)
                if strcmp(classes{col}, 'char')
                    cellstrflag(col) = iscellstr(varCell(:, col));
                end
            end
            
            % charwidths is currently unused
            charwidths = zeros(1, length(names));
        end
        
        function rowNames = variableEditorRowNames(~)
            % Row names are unused by struct vectors (they are just
            % numbered).
            rowNames = {};
        end
                        
        function [msg] = variableEditorRowDelete(workspaceID, ...
                workspaceVariableName, rowIntervals)
            msg = '';
            
            % Get the current value from the specified workspace
            theWorkspace = workspacefunc('getworkspace', workspaceID);
            currentValue = localGetValueFromWorkspace(theWorkspace, workspaceVariableName);
            
            % Generate the code needed & eval it to delete the rows, using
            % the currentValue variable
            code = internal.matlab.array.StructArrayVariableEditorAdapter.variableEditorRowDeleteCode(...
                [], 'currentValue', rowIntervals);
            eval(code);
            
            % Assign in the specified workspace
            assignVariableInWorkspace(theWorkspace, workspaceVariableName, currentValue);
        end
        
        function [code,msg] = variableEditorRowDeleteCode(~, workspaceVariableName, rowIntervals)
            % Generates code to delete elements of the struct array.
            % rowIntervals is guaranteed by the Java UI to be valid            
            code = [workspaceVariableName '(' localGetRowIntervalString(rowIntervals) ') = [];'];            
            msg = '';
        end
        
        function [msg] = variableEditorColumnDelete(workspaceID, workspaceVariableName, columnIntervals)
            msg = '';
            
            % Get the current value from the specified workspace
            theWorkspace = workspacefunc('getworkspace', workspaceID);
            currentValue = localGetValueFromWorkspace(theWorkspace, workspaceVariableName);
            
            % Generate the code needed & eval it to delete the rows, using
            % the currentValue variable
            code = internal.matlab.array.StructArrayVariableEditorAdapter.variableEditorColumnDeleteCode(...
                currentValue, 'currentValue', columnIntervals);
            eval(code);
            
            % Assign in the specified workspace
            assignVariableInWorkspace(theWorkspace, workspaceVariableName, currentValue);
        end
        
        function [code,msg] = variableEditorColumnDeleteCode(a, workspaceVariableName, columnIntervals)
            % Generates code to delete fields of the struct array.
            % columnIntervals is guaranteed by the Java UI to be valid
            code = [workspaceVariableName ' = rmfield(' workspaceVariableName ', '];
            
            requiresCell = false;
            if (numel(columnIntervals) ~= 2) || (columnIntervals(1,1) ~= columnIntervals(1,2))
                code = [code '{'];
                requiresCell = true;
            end

            [numIntervals, ~] = size(columnIntervals);
            fields = fieldnames(a);
            for x=1:numIntervals
                if columnIntervals(x, 1) == columnIntervals(x, 2)
                    % Interval specifies a single field (like [3,3])
                    code = [code '''' fields{columnIntervals(x, 1)} ''''];
                else
                    % Interval specifies multiple fields (like [3,5])
                    for y=columnIntervals(x, 1):columnIntervals(x, 2)
                        code = [code '''' fields{y} ''''];
                        
                        if y ~= columnIntervals(x, 2)
                            % Add the comma if there are more fields
                            code = [code ', '];
                        end
                    end
                end
                
                if x ~= numIntervals
                    % Add the comma if there are more intervals
                    code = [code ', '];
                end
            end
            if requiresCell
                code = [code '}'];
            end
            code = [code ');'];
            msg = '';
        end
        
        function variableEditorPasteWorkspace(workspaceID, ...
                workspaceVariableName, rows, columns, data, isTextData)
            % Get the current value from the specified workspace
            theWorkspace = workspacefunc('getworkspace', workspaceID);
            currentValue = localGetValueFromWorkspace(theWorkspace, workspaceVariableName);
            
            [currentValue, startingRow, startingCol, data] = prepareForPaste(currentValue, rows, columns, data, isTextData);
            fields = fieldnames(currentValue);
            
            % Call assignData function to assign the data to the structure
            % array, giving it the appropriate data types
            currentValue = assignData(currentValue, startingRow, startingCol, ...
                data, fields, isTextData); 
            
            % Assign in the specified workspace
            assignVariableInWorkspace(theWorkspace, workspaceVariableName, currentValue);
        end
        
        function variableEditorPaste(a, workspaceVariableName, ...
                rows, columns, data, isTextData)
            [a, startingRow, startingCol, data] = prepareForPaste(a, rows, columns, data, isTextData);
            fields = fieldnames(a);
            
            % Call assignData function to assign the data to the structure
            % array, giving it the appropriate data types
            a = assignData(a, startingRow, startingCol, ...
                data, fields, isTextData); %#ok<NASGU>
            
            theWorkspace = workspacefunc('getworkspace', 0);
            baseVariableName = arrayviewfunc('getBaseVariableName', ...
                workspaceVariableName);
            
            % Strategy is to create a temporary variable holding the
            % original base variable and assign the new struct into it, and
            % reassign back to the workspace.  A simple assignin won't work
            % with nested struct vectors.
            tmp = evalin(theWorkspace, baseVariableName);
            tmpStructName =  regexprep(workspaceVariableName, baseVariableName, 'tmp', 'once');
            eval([tmpStructName '=a;']);
            assignin(theWorkspace, baseVariableName, tmp);
        end
        
        function variableEditorInsertWorkspace(workspaceID, ...
                workspaceVariableName, orientation, row, col, data, isTextData)
            % Get the current value from the specified workspace
            theWorkspace = workspacefunc('getworkspace', workspaceID);
            currentValue = localGetValueFromWorkspace(theWorkspace, workspaceVariableName);
            
            [currentValue, ~] = variableEditorInsert(currentValue, orientation, ...
                row, col, data, isTextData);
            
            % Assign in the specified workspace
            assignVariableInWorkspace(theWorkspace, workspaceVariableName, currentValue);
        end

        
        function variableEditorInsert(a, workspaceVariableName, ...
                orientation, row, col, data, isTextData)
            theWorkspace = workspacefunc('getworkspace', 0);
            baseVariableName = arrayviewfunc('getBaseVariableName', ...
                workspaceVariableName);

            if (strcmp(orientation, 'rows'))
                % prepareForPaste will add any extra fields, if necessary
                [a, row, col, ~] = prepareForPaste(a, row, col, data, isTextData);
            end
            [a, ~] = variableEditorInsert(a, orientation, row, col, data, isTextData); %#ok<ASGLU>

            % Strategy is to create a temporary variable holding the
            % original base variable and assign the new struct into it, and
            % reassign back to the workspace.  A simple assignin won't work
            % with nested struct vectors.
            tmp = evalin(theWorkspace, baseVariableName);
            tmpStructName =  regexprep(workspaceVariableName, baseVariableName, 'tmp', 'once');
            eval([tmpStructName '=a;']);
            assignin(theWorkspace, baseVariableName, tmp);

            com.mathworks.mlwidgets.workspace.MatlabWorkspaceListener.reportWSChange();
        end
        
        function [msg] = variableEditorSetData(workspaceID, ...
                workspaceVariableName, row, col, rhs)
            msg = '';
            
            % Get the current value from the specified workspace
            theWorkspace = workspacefunc('getworkspace', workspaceID);
            currentValue = localGetValueFromWorkspace(theWorkspace, workspaceVariableName);
            
            % Generate the code needed & eval it to sort, using the
            % currentValue variable
            code = internal.matlab.array.StructArrayVariableEditorAdapter.variableEditorSetDataCode(...
                currentValue, 'currentValue', row, col, rhs);
            eval(code);
            
            % Assign in the specified workspace
            assignVariableInWorkspace(theWorkspace, workspaceVariableName, currentValue);
        end

        function [code,msg] = variableEditorSetDataCode(a,workspaceVariableName,row,col,rhs)
            % Applies the value specified by rhs to the element in the
            % struct vector, specified by row, to the struct field,
            % specified by col.
            allFieldNames = fieldnames(a);
            numFields = length(allFieldNames);
            msg = '';

            if (col > (numFields + 1))
                % The user has typed into a column outside of the struct
                % array, attempting to leave blank columns (fields) in
                % between.  Notify the user that we'll add the new value in
                % the next available column (field).
                msg = getString(message('MATLAB:codetools:structArray:VarEditorIndexOverflow'));
                col = numFields + 1;
            end
            
            if col < length(allFieldNames)
                currValue = a(min(row, length(a))).(allFieldNames{col});
            else
                currValue = [];
            end
            
            if col <= numFields && ...
                    (isstring(currValue) || ...
                    (isempty(currValue) && isstring(a(1).(allFieldNames{col}))))
                % User is editing a string value.  If they entered a string
                % here, it needs to be wrapped in the string constructor
                % until the double quote operator is complete
                if isstring(rhs)
                    % Double all the double quotes.  This way we should have
                    % valid MATLAB syntax
                    rhs = strrep(rhs, """", """""");

                    rhs = ['"' char(replace(rhs, newline, '" + newline + "')) '"'];
                else
                    idxs = strfind(rhs, '"');
                    if ~isempty(idxs) && idxs(1) == 1 && idxs(end) == length(rhs) && length(rhs) > 1
                        if isempty(rhs)
                            rhs = '""';
                        else                            
                            % Did the user enter double quotes at the beginning
                            % and end of the string? If so, remove them.
                            idx = strfind(rhs, '"');
                            if idx(1) == 1 && idx(end) == length(rhs)
                                rhs = rhs(2:end-1);
                            end
                            rhs = ['"' rhs '"'];
                        end
                    end
                end
            end

            % Evaluate the value that is going to be assigned
            if ~isempty(rhs)
                rhsValue = evalin('caller', rhs);
            else
                rhsValue = '';
            end
            
            if (col <= numFields)
                if (row <= length(a))
                    lhs = a(row).(allFieldNames{col});
                else
                    lhs = [];
                end

                if ~isempty(lhs) && isequal(lhs, rhsValue)
                    % No-op if the values are equal
                    code = '';
                else
                    if isempty(rhs)
                        code = [workspaceVariableName '(' num2str(row) ').' allFieldNames{col} ' = [];'];
                    else
                        code = [workspaceVariableName '(' num2str(row) ').' allFieldNames{col} ' = ' char(rhs) ';'];
                    end
                end
            elseif (col == (numFields + 1))
                % Create a new unique field name based on 'unnamed' and
                % assign the value in the proper position.
                newFieldName = localGenerateUniqueNameFromList('unnamed', allFieldNames);
                code = [ workspaceVariableName '(' num2str(row) ').' newFieldName ' = ' rhs ';' ];
            end 
        end
        
        function [msg] = variableEditorSort(workspaceID, ...
                workspaceVariableName, structFields, direction)
            msg = '';
            
            % Get the current value from the specified workspace
            theWorkspace = workspacefunc('getworkspace', workspaceID);
            currentValue = localGetValueFromWorkspace(theWorkspace, workspaceVariableName);
            
            % Generate the code needed & eval it to sort, using the
            % currentValue variable
            code = internal.matlab.array.StructArrayVariableEditorAdapter.variableEditorSortCode(...
                currentValue, 'currentValue', structFields, direction);
            eval(code);
            
            % Assign in the specified workspace
            assignVariableInWorkspace(theWorkspace, workspaceVariableName, currentValue);
        end
        
        function [code,msg] = variableEditorSortCode(this, varName, ...
                structFields, direction)
            % Generates code to sort the specified struct vector, by the
            % given fields and direction.
            msg = '';
            f = fieldnames(this);

            if ischar(structFields)
                % sorting by single field
                varToSort = [varName '.' structFields];
                                
                % Convert struct array to cell array for better performance
                varCell = localConvertToCell(this);
                
                % Get indices of struct fields to sort by to index into
                % cell array
                varIndex = cellfun(@(x) isequal(x, structFields), f);
                varData = varCell(:, varIndex);
               
                allNumbers = cellfun(@isnumeric, varData);
                allLogical = cellfun('islogical', varData);
                allCellStr = cellfun(@ischar, varData);
                allStrings = cellfun('isclass', varData, 'string');
                emptyVals = cellfun('isempty', varData);
            else
                % sorting by multiple fields
                varToSort = '';
                
                % initialize these to the appropriate length
                allNumbers = true(length(this), 1);
                allLogical = true(length(this), 1);
                allStrings = true(length(this), 1);
                allCellStr = true(length(this), 1);
                emptyVals = false(length(this), 1);

                % Convert struct array to cell array for better performance
                varCell = localConvertToCell(this);

                for i=1:length(structFields)
                    varToSort = [varToSort varName '.' structFields{i}];
                    
                    if ~isequal(i, length(structFields))
                        varToSort = [varToSort '; '];
                    end
                    
                    % Need to index into cell array using index of field
                    % name
                    varIndex = cellfun(@(x) isequal(x, structFields{i}), f);
                    varData = varCell(:, varIndex);
                    
                    allNumbers = allNumbers & cellfun(@isnumeric, varData);
                    allLogical = allLogical & cellfun('islogical', varData);
                    allStrings = allStrings & cellfun('isclass', varData, 'string');
                    allCellStr = allCellStr & cellfun(@isstr, varData);
                    emptyVals = emptyVals | cellfun('isempty', varData);
                end
            end            

            whoOutput = evalin('caller','whos');
            indexName = localGenerateUniqueName('index', whoOutput);
            if all(allNumbers | allLogical | allStrings) && ~any(emptyVals)
                if direction
                    code = ['[~,' indexName '] = sortrows([' varToSort '].''); ' varName ' = ' varName '(' indexName '); clear ' indexName ];
                else
                    code = ['[~,' indexName '] = sortrows([' varToSort '].''); ' varName ' = ' varName '(' indexName '(end:-1:1)); clear ' indexName ];
                end
            elseif all(allCellStr)
                if direction
                    code = ['[~,' indexName '] = sortrows({' varToSort '}.''); ' varName ' = ' varName '(' indexName '); clear ' indexName ];
                else
                    code = ['[~,' indexName '] = sortrows({' varToSort '}.''); ' varName ' = ' varName '(' indexName '(end:-1:1)); clear ' indexName ];
                end
            else
                % Cannot sort field with mixed values
                code = '';
                msg = getString(message('MATLAB:codetools:structArray:InvalidSort'));
            end
        end
        
        function [msg] = variableEditorMoveColumn(workspaceID, ...
                workspaceVariableName, startCol, endCol)
            msg = '';
            
            % Get the current value from the specified workspace
            theWorkspace = workspacefunc('getworkspace', workspaceID);
            currentValue = localGetValueFromWorkspace(theWorkspace, workspaceVariableName);

            % Generate the code needed & eval it to delete the rows, using
            % the currentValue variable
            code = internal.matlab.array.StructArrayVariableEditorAdapter.variableEditorMoveColumnCode(...
                currentValue, 'currentValue', startCol, endCol);
            eval(code);
            
            % Assign in the specified workspace
            assignVariableInWorkspace(theWorkspace, workspaceVariableName, currentValue);            
        end
        
        function [code, msg] = variableEditorMoveColumnCode(this, ...
                varName, startCol, endCol)
            % Generates code to reorder fields in the variable editor.
            fieldNames = fieldnames(this);
            code = [ varName ' = orderfields(' varName ', '];
            
            if (startCol < endCol)
                resolvedEndCol = min(length(fieldNames), endCol-1);
                resolvedAfterEndCol = min(length(fieldNames), endCol);
                if (startCol == 1)
                    % moving first column
                    if (resolvedEndCol >= length(fieldNames))
                        % moving first column to end
                        code = [ code '[' localResolveRange(2, resolvedEndCol) ',' num2str(startCol) ']);'];
                    else
                        % moving first column to middle
                        code = [ code '[' localResolveRange(2, resolvedEndCol) ',' num2str(startCol) ',' localResolveRange(resolvedAfterEndCol, length(fieldNames)) ']);'];
                    end
                elseif (resolvedEndCol >= length(fieldNames))
                    code = [ code '[' localResolveRange(1, startCol-1) ',' localResolveRange(startCol+1, resolvedEndCol) ',' num2str(startCol) ']);'];
                else
                    code = [ code '[' localResolveRange(1, startCol-1) ',' localResolveRange(startCol+1, resolvedEndCol) ',' num2str(startCol) ',' localResolveRange(resolvedAfterEndCol, length(fieldNames)) ']);'];
                end
            else
                if (endCol == 1)
                    % moving to first position
                    if (startCol == length(fieldNames))
                        % moving last column to first column
                        code = [ code '[' num2str(startCol) ',' localResolveRange(1, startCol-1) ']);']; 
                    else
                        code = [ code '[' num2str(startCol) ',' localResolveRange(1, startCol-1) ',' localResolveRange(min(startCol+1, length(fieldNames)), length(fieldNames)) ']);'];
                    end
                elseif (startCol == length(fieldNames))
                    % moving last column
                    code = [ code '[' localResolveRange(1, endCol-1) ',' num2str(startCol) ',' localResolveRange(endCol, startCol-1) ']);' ]; 
                else
                    code = [ code '[' localResolveRange(1, endCol-1) ',' num2str(startCol) ',' localResolveRange(endCol, startCol-1) ',' localResolveRange(min(startCol+1, length(fieldNames)), length(fieldNames)) ']);']; 
                end
            end
            
            msg = '';
        end
        
        function [msg] = variableEditorMetadata(workspaceID, ...
                workspaceVariableName, index, propertyName, newFieldName)
            msg = '';
            
            % Get the current value from the specified workspace
            theWorkspace = workspacefunc('getworkspace', workspaceID);
            currentValue = localGetValueFromWorkspace(theWorkspace, workspaceVariableName);
            
            % Generate the code needed & eval it to delete the rows, using
            % the currentValue variable
            code = internal.matlab.array.StructArrayVariableEditorAdapter.variableEditorMetadataCode(...
                currentValue, 'currentValue', index, ...
                propertyName, newFieldName);
            eval(code);
            
            % Assign in the specified workspace
            assignVariableInWorkspace(...
                theWorkspace, workspaceVariableName, currentValue);
        end
        
        function [metadataCode,warnmsg] = variableEditorMetadataCode(this,varName,index,propertyName,newFieldName)
            % Called to generate code to set meta-data for the struct
            % vector -- in this case, it will always be for renaming a
            % field.
            warnmsg = '';
            if strcmpi('varnames',propertyName)
                fieldNames = fieldnames(this);
                oldFieldName = fieldNames{index};
                % Validation
                if ~isvarname(newFieldName)
                    error(message('MATLAB:codetools:structArray:InvalidVariableName',newFieldName));
                end
                if any(strcmp(fieldNames,newFieldName))
                    error(message('MATLAB:codetools:structArray:DuplicateVarnames'));
                end
                metadataCode = ['[' varName '.' newFieldName '] = ' varName '.' oldFieldName '; ' varName ' = orderfields(' varName ',[1:' num2str(index-1) ',' num2str(length(fieldNames)+1) ',' num2str(index) ':' num2str(length(fieldNames)) ']); ' varName ' = rmfield(' varName ',''' oldFieldName ''');'];
            end
        end
        
        function [code, openvarCode, msg] = variableEditorCreateNewStructCode(...
                this, varName, rowIntervals, columnIntervals)
            % Generates code to create a new scalar struct or struct
            % vector, with the specified rows/fields from the original
            % struct vector.
            fieldNames = fieldnames(this);
            whoOutput = evalin('caller','whos');
            newVarName = localGenerateUniqueName(varName, whoOutput);
            
            largeNumRowsSelected = localIsLargeNumRowsSelected(rowIntervals);
            if localIsSingleRowSelected(rowIntervals)
                % creating a new scalar struct
                rowIntervalStr = num2str(rowIntervals(1,1));
            else
                % creating a new struct array
                rowIntervalStr = localGetRowIntervalString(rowIntervals);
            end

            newFields = localGetSelectedFieldNames(fieldNames, columnIntervals);
            if (columnIntervals(1,1) == 1) && ...
                    (columnIntervals(1, 2) == numel(fieldNames))
                % creating new structure or structure array using all
                % columns.
                code = [newVarName ' = ' varName '(' rowIntervalStr ');'];
            elseif largeNumRowsSelected
                % Need to create temporary cell array to deal with really
                % large struct array creation.  This is much quicker than
                % referencing the fields of the struct array, however it
                % may appear to be more confusing as far as codegen goes.
                % For example:
                % temp = struct2cell(starray).'; starray1 = struct(...
                %  'field1', temp(1:100000,1), 'field2', temp(1:100000,2));
                whoOutput = evalin('caller','whos');
                tempName = localGenerateUniqueName('temp', whoOutput);
                
                % first in generated code need to convert to cell array to
                % improve performance
                if localNeedsTransposeBeforeStruct2Cell(this)
                    code = [tempName ' = struct2cell(' varName '.'').''; '];
                else
                    code = [tempName ' = struct2cell(' varName ').''; '];
                end
                code = [code newVarName ' = struct('];
                [numColIntervals, ~] = size(columnIntervals);
                first = true;
                for i=1:numColIntervals
                    for j=columnIntervals(i,1):columnIntervals(i,2)
                        if first
                            first = false;
                        else
                            code = [code ', '];
                        end

                        code = [code '''' fieldNames{j} ''', ' tempName '(' rowIntervalStr ',' num2str(j) ')'];
                    end
                end
                code = [code '); clear ' tempName];
            else
                % creating new structure or structure array using a subset
                % of columns
                code = [newVarName ' = struct('];
                for i=1:numel(newFields)
                    code = [code '''' newFields{i} ''', {' varName '(' rowIntervalStr ').' newFields{i} '}'];
                    if i ~= numel(newFields)
                        code = [code ', '];
                    end
                end
                code = [code ');'];
            end
            openvarCode = ['openvar ' newVarName];
            msg = '';
        end
        
        function [code, openvarCode, msg] = variableEditorCreateNewNumericArrayCode(this, varName, rowIntervals, columnIntervals)
            whoOutput = evalin('caller','whos');
            [code, msg, newVarName] = localCreateArray(this, varName, rowIntervals, columnIntervals, '[', ']', whoOutput);
            openvarCode = ['openvar ' newVarName];
        end
        
        function [code, openvarCode, msg] = variableEditorCreateNewCellArrayCode(this, varName, rowIntervals, columnIntervals)
            whoOutput = evalin('caller','whos');
            [code, msg, newVarName] = localCreateArray(this, varName, rowIntervals, columnIntervals, '{', '}', whoOutput);
            openvarCode = ['openvar ' newVarName];
        end
        
        function [code, openvarCode, msg] = variableEditorCreateSeparateVariablesCode(this, varName, rowIntervals, columnIntervals)
            [numColIntervals, ~] = size(columnIntervals);
            first = 1;
            maxOpenVars = 5;
            numOfOpenVars = 1;
            openvarCodeStr = 'openvar ';

            % Convert struct array to cell array for better performance
            varCell = localConvertToCell(this);

            whoOutput = evalin('caller','whos');
            for i=1:numColIntervals
                for j=columnIntervals(i,1):columnIntervals(i,2)
                    varData = varCell(rowIntervals(1,1):rowIntervals(1,2), j);
                    allArrayFmt = cellfun(@(x) isnumeric(x) || ...
                        iscategorical(x) || isdatetime(x) || isduration(x) || ...
                        iscalendarduration(x) || isstring(x), varData);
                    allLogical = cellfun('islogical', varData);
                    lengths = cellfun('length', varData);
                    
                    if all(allArrayFmt | allLogical) && all(lengths == 1) 
                        [newcode, msg, newVarName] = localCreateArray(this, varName, rowIntervals, [j, j], '[', ']', whoOutput);
                    else
                        [newcode, msg, newVarName] = localCreateArray(this, varName, rowIntervals, [j, j], '{', '}', whoOutput);
                    end
                    
                    if first
                        openvarCode = [openvarCodeStr newVarName];
                        code = newcode;
                        first = 0;
                    else
                        if numOfOpenVars <=  maxOpenVars
                            openvarCode = [openvarCode ';' openvarCodeStr newVarName];
                        end
                        code = [code ' ' newcode];
                    end
                    numOfOpenVars = numOfOpenVars + 1;
                end
            end
        end
                
        function [code, openvarCode, msg] = variableEditorCreateNewDatasetArrayCode(this, varName, rowIntervals, columnIntervals)
            fieldNames = fieldnames(this);
            whoOutput = evalin('caller','whos');
            newVarName = localGenerateUniqueName(varName, whoOutput);
            
            if localIsSingleRowSelected(rowIntervals)
                % creating a dataset from a single row
                rowIntervalStr = num2str(rowIntervals(1,1));
            elseif localIsEntireColumnSelected(this, rowIntervals)
                % creating a dataset from all rows
                rowIntervalStr = [];
            else
                % creating a dataset from multiple rows
                rowIntervalStr = localGetRowIntervalString(rowIntervals);
            end
            
            % Creating new dataset using a subset of columns.  For small
            % struct arrays, it will be done by directly referencing the
            % fields in the struct array.  For example:
            % newDataset = dataset({[starray.field1].', 'field1'}, ...
            %    {{starray.field2}.', 'field2'});
            %
            % However, for larger struct arrays, we'll convert to a cell
            % array first for better performance.  For example:
            % temp = cell2struct(starray); newDataset = dataset(...
            %    {cell2mat(temp(:,1)), 'field1'}, {temp(:,2), 'field2'});
            largeNumRowsSelected = localIsLargeNumRowsSelected(rowIntervals);

            varCell = localConvertToCell(this);
            [numColIntervals, ~] = size(columnIntervals);
            first = true;
            
            if largeNumRowsSelected
                % first in generated code need to convert to cell array to
                % improve performance
                whoOutput = evalin('caller','whos');
                tempName = localGenerateUniqueName('temp', whoOutput);
                if localNeedsTransposeBeforeStruct2Cell(this)
                    code = [tempName ' = struct2cell(' varName '.'').''; ' newVarName ' = dataset('];
                else
                    code = [tempName ' = struct2cell(' varName ').''; ' newVarName ' = dataset('];
                end
            else
                code = [newVarName ' = dataset('];
            end
            for i=1:numColIntervals
                for j=columnIntervals(i,1):columnIntervals(i,2)
                    if ~first
                        code = [code ', '];
                    else
                        first = false;
                    end

                    varData = varCell(rowIntervals(1,1):rowIntervals(1,2), j);
                    
                    scalarNumeric = localIsScalarNumeric(varData);
                    if scalarNumeric 
                        if isempty(rowIntervalStr)
                            code = [code '{[' varName '.' fieldNames{j} '].'', ''' fieldNames{j} '''}'];
                        else
                            code = [code '{[' varName '(' rowIntervalStr ').' fieldNames{j} '].'', ''' fieldNames{j} '''}'];
                        end
                    else
                        if (largeNumRowsSelected) 
                            if isempty(rowIntervalStr)
                                rowIntervalStr = ':';
                            end
                            code = [code '{' tempName '(' rowIntervalStr ', ' num2str(j) '), ''' fieldNames{j} '''}'];
                        else
                            if isempty(rowIntervalStr)
                                code = [code '{{' varName '.' fieldNames{j} '}.'', ''' fieldNames{j} '''}'];
                            else
                                code = [code '{{' varName '(' rowIntervalStr ').' fieldNames{j} '}.'', ''' fieldNames{j} '''}'];
                            end
                        end
                    end                    
                end
            end
            code = [code ');'];
            if largeNumRowsSelected
                code = [code 'clear ' tempName];
            end
            openvarCode = ['openvar ' newVarName];
            msg = '';
        end
        
        function [code, openvarCode, msg] = variableEditorCreateNewTableCode(this, varName, rowIntervals, columnIntervals)
            fieldNames = fieldnames(this);
            whoOutput = evalin('caller','whos');
            newVarName = localGenerateUniqueName(varName, whoOutput);
            
            if localIsSingleRowSelected(rowIntervals)
                % creating a table from a single row
                rowIntervalStr = num2str(rowIntervals(1,1));
            elseif localIsEntireColumnSelected(this, rowIntervals)
                % creating a table from all rows
                rowIntervalStr = [];
            else
                % creating a table from multiple rows
                rowIntervalStr = localGetRowIntervalString(rowIntervals);
            end
            
            % Creating new table using a subset of columns.  For small
            % struct arrays, it will be done by directly referencing the
            % fields in the struct array.  For example:
            % newTable = table([starray.field1].', {starray.field2}.', ...
            %     'VariableNames', {'field1', 'field2'});
            %
            % However, for larger struct arrays, we'll convert to a cell
            % array first for better performance.  For example:
            % temp = cell2struct(starray); newTable = table(...
            %    temp(:,1), temp(:, 2), 'VariableNames', {'field1', ...
            %    'field2'}); clear temp;
            largeNumRowsSelected = localIsLargeNumRowsSelected(rowIntervals);

            varCell = localConvertToCell(this);
            [numColIntervals, ~] = size(columnIntervals);
            first = true;
            
            if largeNumRowsSelected
                % first in generated code need to convert to cell array to
                % improve performance
                whoOutput = evalin('caller','whos');
                tempName = localGenerateUniqueName('temp', whoOutput);
                if localNeedsTransposeBeforeStruct2Cell(this)
                    code = [tempName ' = struct2cell(' varName '.'').''; ' newVarName ' = table('];
                else
                    code = [tempName ' = struct2cell(' varName ').''; ' newVarName ' = table('];
                end
            else
                code = [newVarName ' = table('];
            end
            
            varNames = '''VariableNames'', {';
            for i=1:numColIntervals
                for j=columnIntervals(i,1):columnIntervals(i,2)
                    if ~first
                        code = [code ', '];
                        varNames = [varNames ', '];
                    else
                        first = false;
                    end

                    varData = varCell(rowIntervals(1,1):rowIntervals(1,2), j);
                    scalarNumeric = localIsScalarNumeric(varData);
                    allStrings = cellfun('isclass', varData, 'string');

                    % add field name to list of table columns
                    varNames = [varNames '''' fieldNames{j} ''''];
                    
%                     if all(allNumbers | allLogical) && all(lengths == 1) 
                    if scalarNumeric || all(allStrings)
                        if isempty(rowIntervalStr)
                            code = [code '[' varName '.' fieldNames{j} '].'''];
                        else
                            code = [code '[' varName '(' rowIntervalStr ').' fieldNames{j} '].'''];
                        end
                    else
                        if (largeNumRowsSelected) 
                            if isempty(rowIntervalStr)
                                rowIntervalStr = ':';
                            end
                            code = [code tempName '(' rowIntervalStr ', ' num2str(j) ')'];
                        else
                            if isempty(rowIntervalStr)
                                code = [code '{' varName '.' fieldNames{j} '}.'''];
                            else
                                code = [code '{' varName '(' rowIntervalStr ').' fieldNames{j} '}.'''];
                            end
                        end                        
                    end                    
                end
            end
            code = [code ', ' varNames '});'];
            if largeNumRowsSelected
                code = [code 'clear ' tempName];
            end
            openvarCode = ['openvar ' newVarName];
            msg = '';
        end
        
        function [msg] = variableEditorClearData(workspaceID, ...
                workspaceVariableName, rowIntervals, columnIntervals)
            msg = '';
            
            % Get the current value from the specified workspace
            theWorkspace = workspacefunc('getworkspace', workspaceID);
            currentValue = localGetValueFromWorkspace(theWorkspace, workspaceVariableName);
            
            % Generate the code needed & eval it to delete the rows, using
            % the currentValue variable
            code = internal.matlab.array.StructArrayVariableEditorAdapter.variableEditorClearDataCode(...
                currentValue, 'currentValue', rowIntervals, columnIntervals);
            eval(code);
            
            % Assign in the specified workspace
            assignVariableInWorkspace(theWorkspace, workspaceVariableName, currentValue);
        end

        function [code, msg] = variableEditorClearDataCode(...
                this, varName, rowIntervals, columnIntervals)
            
            rowIntervalStr = localGetRowIntervalString(rowIntervals);
            fieldNames = fieldnames(this);
            [numColIntervals, ~] = size(columnIntervals);

            % Need to construct a line for each field
            code = '';
            for i=1:numColIntervals
                for j=columnIntervals(i,1):columnIntervals(i,2)
                    if localIsSingleRowSelected(rowIntervals)
                        % Only a single row is selected, we don't need the
                        % deal command
                        code = [code varName '(' rowIntervalStr ...
                            ').' fieldNames{j} ' = []; '];
                    else
                        code = [code '[' varName '(' rowIntervalStr ...
                            ').' fieldNames{j} '] = deal([]); '];
                    end
                end
            end
            
            msg = '';
        end
    end
end

function rangeStr = localResolveRange(startRange, endRange)
    % Returns a range string appropriate for the given range.  If start and
    % end are the same, it just returns a single number.  For example:
    % localResolveRange(1,5) returns '1:5'
    % localResolveRange(3,3) returns '3'
    if (startRange ~= endRange)
        rangeStr = [num2str(startRange) ':' num2str(endRange)];
    else
        rangeStr = num2str(startRange);
    end
end

function [code, msg, newVarName] = localCreateArray(s, varName, ...
        rowIntervals, columnIntervals, arrayStartChar, arrayEndChar, ...
        whoOutput, tmpVarName)
    % Generates the code to create a numeric or cell array with the
    % specified row/column intervals, starting with a struct array s with
    % the name varName.
    
    fieldNames = fieldnames(s);
    
    if (nargin == 8 && tmpVarName == 1)
        % Create a temporary variable name
        newVarName = localGenerateUniqueName('temp', whoOutput);
    elseif numel(columnIntervals) == 2 && columnIntervals(1,1) == columnIntervals(1,2)
        % creating an array from a single column.  Name it after the field
        % name
        newVarName = localGenerateUniqueName(fieldNames{columnIntervals(1,1)}, whoOutput);
    else
        % creating an array from multiple columns.  Name it after the
        % struct name
        newVarName = localGenerateUniqueName(varName, whoOutput);
    end
    
    if localIsEntireColumnSelected(s, rowIntervals)
        % Entire column selected - don't need to show row intervals
        rowIntervalStr = [];
    else
        rowIntervalStr = localGetRowIntervalString(rowIntervals);
    end
    
    largeNumRowsSelected = localIsLargeNumRowsSelected(rowIntervals);
    whoOutput = evalin('caller','whos');
    if largeNumRowsSelected && strcmp(arrayStartChar, '{')
        tempName = localGenerateUniqueName('temp', whoOutput);
        % first in generated code need to convert to cell array to
        % improve performance
        if localNeedsTransposeBeforeStruct2Cell(s)
            code = [tempName ' = struct2cell(' varName '.'').''; '];
        else
            code = [tempName ' = struct2cell(' varName ').''; '];
        end
        colIntervalStr = localGetRowIntervalString(columnIntervals);
        if isempty(rowIntervalStr)
            rowIntervalStr = ':';
        end
        
        % Code references rows/columns in the cell array
        code = [code newVarName ' = ' tempName '(' rowIntervalStr ', ' colIntervalStr ');'];
        code = [code ' clear ' tempName ';'];        
    else
        code = [newVarName ' = ' arrayStartChar];
        
        newFields = localGetSelectedFieldNames(fieldNames, columnIntervals);
        for i=1:numel(newFields)
            if rowIntervalStr
                code = [code varName '(' rowIntervalStr ').' newFields{i}]; %#ok<*AGROW>
            else
                code = [code varName '.' newFields{i}];
            end
            if i ~= numel(newFields)
                code = [code '; '];
            end
        end
        code = [code arrayEndChar '.'';'];
    end
    msg = '';
end

function singleRowSelected = localIsSingleRowSelected(rowIntervals) 
    % Single row is selected if there are two elements in the row intervals
    % and they are both the same number.
    singleRowSelected = (numel(rowIntervals) == 2 && ...
        rowIntervals(1,1) == rowIntervals(1,2));
end

function entireColSelected = localIsEntireColumnSelected(a, rowIntervals) 
    % Entire column is selected if there are two elements in the row
    % intervals and the first one is 1 and the second one is the length of
    % the struct array
    if numel(rowIntervals) == 2 && ...
            rowIntervals(1,1) == 1 && ...
            rowIntervals(1,2) == numel(a)
        entireColSelected = true;
    else
        entireColSelected = false;
    end
end

function largeNumRowsSelected = localIsLargeNumRowsSelected(rowIntervals)
    % Called to determine if the number of rows selected is 'large'.  After
    % a certain number of elements, referencing fields of a struct can take
    % too long (30+ seconds for a 100000 array).  For example:
    % {starray(1:10000).field1} takes a very long time.  (Converting to
    % numeric is not as long:  [starray(1:100000).field1]).  This function
    % returns true if the number of elements selected by the rowIntervals
    % range will take a long time.  (In this case, we convert the entire
    % struct array to a cell array using struct2cell).
    largeNumRowsSelected = false;
    numRows = 0;
    [numRowIntervals, ~] = size(rowIntervals);
    
    % For each row interval pair...
    for i=1:numRowIntervals
        % Add the number of rows in the interval to total
        numRows = numRows + (rowIntervals(i,2) - rowIntervals(i,1));
    end
    
    if numRows > 10000
        largeNumRowsSelected = true;
    end
end

function newFieldNames = localGetSelectedFieldNames(fieldNames, columnIntervals) 
    index = 1;
    newFieldNames = {};
    [numColIntervals, ~] = size(columnIntervals);
    for i=1:numColIntervals
        for j=columnIntervals(i,1):columnIntervals(i,2)
            newFieldNames{index} = fieldNames{j};
            index = index+1;
        end
    end
end

function uniqueName = localGenerateUniqueName(baseName, whoOutput) 
    % whoOutput is a struct array, but we need only the names
    varNames = {whoOutput.name};
    
    uniqueName = localGenerateUniqueNameFromList(baseName, varNames);
 end

function uniqueName = localGenerateUniqueNameFromList(fullName, varNames)
    
    % start out with the full name, then try to create a unique one based
    % on it
    
    index = strfind(fullName, '.');
    if ~isempty(index) 
        % If we're dealing with nested structs, just want to use the field
        % name
        uniqueName = fullName(index(end)+1:length(fullName));
        baseName = uniqueName;
    else
        uniqueName = fullName;
        baseName = uniqueName;
    end
    nameExists = any(strcmp(varNames, uniqueName));
    
    index = 1;
    while nameExists
        uniqueName = sprintf('%s%d', baseName, index);
        nameExists = any(strcmp(varNames, uniqueName));
        index = index+1;
    end
end

function rowIntervalStr = localGetRowIntervalString(rowIntervals)
    % rowIntervals is an array of interval pairs, like: [1,8;11,11]
    % This function will convert this to its text equivalent, which would
    % be '[1:8, 11]'
    if localIsSingleRowSelected(rowIntervals)
        rowIntervalStr = num2str(rowIntervals(1,1));
    else
        [numIntervals, ~] = size(rowIntervals);
        if numIntervals == 1
            rowIntervalStr = '';
        else
            rowIntervalStr = '[';
        end
        for i=1:numIntervals
            if rowIntervals(i, 1) == rowIntervals(i, 2)
                rowIntervalStr = [rowIntervalStr num2str(rowIntervals(i, 1))];
            else
                rowIntervalStr = [rowIntervalStr num2str(rowIntervals(i, 1)) ':'...
                    num2str(rowIntervals(i, 2)) ];
            end
            if i ~= numIntervals
                rowIntervalStr = [rowIntervalStr ', '];
            end
        end
        
        if numIntervals ~= 1
            rowIntervalStr = [rowIntervalStr ']'];
        end
    end
end

function assignVariableInWorkspace(theWorkspace, workspaceVariableName, currentValue) %#ok<INUSD>
    baseVariableName = arrayviewfunc('getBaseVariableName', workspaceVariableName);
    
    % Strategy is to create a temporary variable holding the
    % original base variable and assign the new struct into it, and
    % reassign back to the workspace.  A simple assignin won't work
    % with nested struct vectors.
    tmp = evalin(theWorkspace, baseVariableName);
    tmpStructName =  regexprep(workspaceVariableName, baseVariableName, 'tmp', 'once');
    eval([tmpStructName '=currentValue;']);
    assignin(theWorkspace, baseVariableName, tmp);
    
    % Force an update in the display
    com.mathworks.mlwidgets.workspace.MatlabWorkspaceListener.reportWSChange()
end

function [a, data] = variableEditorInsert(a, orientation, row, col, data, isTextData)
    if (strcmp(orientation, 'columns'))
        if isTextData && iscell(data{1,1})
            data = data(:);
            % for nested data, the lengths are all the same
            columns = max(cellfun('length', data));
        else
            [~, columns] = size(data);
        end
        
        insertAtCol = min(col, (length(fieldnames(a)) + 1));
        
        % Inserting column data means adding new fields to the
        % structure.  Insert one at a time and move into place.
        for colIndex=1:columns
            % Create a unique field name & fill in with empty
            newFieldName = localGenerateUniqueNameFromList(...
                'unnamed', fieldnames(a));
            [a(:).(newFieldName)] = deal([]);
            
            fields = fieldnames(a);
            newPos = length(fields);
            
            % Call assignData function to assign the data to the
            % structure array, giving it the appropriate data types
            if isTextData && iscell(data{1,1})
                colData = cellfun(@(x) x{colIndex}, data, 'UniformOutput', false);
                a = assignData(a, 1, newPos, colData, fields, isTextData);
            else
                a = assignData(a, 1, newPos, data(:, colIndex), fields, isTextData);
            end
            
            if insertAtCol ~= newPos
                % move it to the appropriate place if the user
                % didn't choose to insert at the end. (new fields
                % are always added at the end of the structure)
                a = orderfields(a, [1:insertAtCol-1, newPos, insertAtCol:newPos-1]);
            end
            
            % increment column so that the inserts end up in the
            % correct order.
            insertAtCol = insertAtCol+1;
        end
    elseif (strcmp(orientation, 'rows'))
        % Inserting row data means adding new elements to the
        % structure vector
        if (isTextData)
            data = data(:);
        end
        [rows, ~] = size(data);
        
        if (row-1 > length(a))
            % Fill in any empty elements between the current length of the
            % structure and the row we're adding to with empties.
            fields = fieldnames(a);
            a(row-1).(fields{1}) = [];
        end
        
        for rowIndex=1:rows
            % assign data off the end of the struct vector (it will
            % be moved into the proper place afterwards)
            insertPosition = length(a) + 1;
            fields = fieldnames(a);
            
            % Call assignData function to assign the data to the
            % structure array, giving it the appropriate data types
            a = assignData(a, insertPosition, 1, ...
                data(rowIndex, :), fields, isTextData);
            
            % move the new row to the appropriate place
            newPos = length(a);
            a = a([1:row-1, newPos, row:newPos-1]);
            
            % increment row so that the inserts end up in the
            % correct order.
            row = row+1;
        end
    end
end

function [a, startingRow, startingCol, data] = prepareForPaste(a, rows, columns, data, isTextData)
    % Pastes the given data into the specified rows and columns.
    % New elements or fields will be created and set to empty [] if
    % needed.  data is expected to be a cell array of data to
    % paste, which may contain the data directly or nested.
    fields = fieldnames(a);
    [numFields, ~] = size(fields);
    
    [dataRows, dataColumns] = size(data);
    if isTextData
        if dataRows == 1 && dataColumns == 1
            % single row of data
            data = data{1};
        else
            % multiple rows of data
            data = data(:);
        end
    end
    
    % use length of data for paste size
    if isTextData && iscell(data{1,1})
        % for nested data, the lengths are all the same
        dataColumns = max(cellfun('length', data));
    else
        [~, dataColumns] = size(data);
    end
    
    % Its ok if starting row is past the end of the array - empties will be
    % filled in, in between the end and the startingRow.
    startingRow = rows(1,1);
    startingCol = columns(1,1);
    fields = fieldnames(a);
    
    if startingCol > numFields+1
        % Prevent empty fields from being created in between by
        % adjusting the paste to start after the last field.
        startingCol = numFields+1;
    end    
    
    if (startingCol + dataColumns - 1) > length(fields)
        % If the data to paste extends past the number of
        % fields, create new fields before doing the paste
        numNewFields = (startingCol + dataColumns -1) - length(fields);
        
        for i=1:numNewFields
            newFieldName = localGenerateUniqueNameFromList(...
                'unnamed', fields);
            
            % fill in with empty, in case new data isn't the same size
            [a(:).(newFieldName)] = deal([]);
            
            % Get fieldnames again so it contains the new field
            % name that was just added
            fields = fieldnames(a);
        end
    end
end

function out = assignData(a, startingRow, startingCol, data, fields, isTextData)
    % Assigns the given data into a struct array, beginning at the
    % startingRow and startingCol.  This function assumes all needed fields
    % have been created. data can be a cell array of data, or a cell array
    % of cell arrays with the data within them.

    % use length of data for paste size
    nestedCell = false;
    if isTextData && iscell(data{1,1}) 
        % with nested cell arrays, use the size of the nested data
        [dataRows, ~] = size(data);
        dataColumns = max(cellfun('length', data));
        nestedCell = true;
    else
        [dataRows, dataColumns] = size(data);
    end

    dataIndex = [1, 1];
    for rowIndex=startingRow:startingRow + dataRows - 1

        % Assign the values in the row field by field
        for colIndex = startingCol:startingCol + dataColumns - 1
            if nestedCell
                % for nested cell arrays, pull out the necessary cell data
                dataVal = data{dataIndex(1,1), 1};

                if iscell(dataVal)
                    dataVal = dataVal{1, dataIndex(1,2)};
                end
            else
                if iscell(data)
                    % otherwise just reference the cell data directly
                    dataVal = data{dataIndex(1,1), dataIndex(1,2)};
                    
                    if isTextData && iscell(dataVal)
                        dataVal = dataVal{1};
                    end
                else
                    dataVal = data(dataIndex(1,1), dataIndex(1,2));
                end
            end

            if ischar(dataVal)
                % remove extra quotes
                dataVal = strrep(dataVal, '''', '');

                % try to convert to numeric
                [numeric, ok] = str2num(dataVal); %#ok<ST2NM>
                if ok
                    a(rowIndex).(fields{colIndex}) = numeric;
                else
                    a(rowIndex).(fields{colIndex}) = dataVal;
                end
            elseif isequal(class(dataVal), 'dataset') || istable(dataVal)
                tableFields = fieldnames(dataVal);
                a(rowIndex).(fields{colIndex}) = dataVal.(tableFields{1,1});
            else
                a(rowIndex).(fields{colIndex}) = dataVal;
            end

            dataIndex = dataIndex + [0,1];
        end

        % Go to the next row in the data
        dataIndex = dataIndex + [1,0];

        % Reset to the first column in the data
        dataIndex(1,2) = 1;
    end

    out = a;
end

function varCell = localConvertToCell(a)
    % Convert data to cell array to use in loops (this is quicker than
    % grabbing each field one by one).  Note that struct2cell creates a
    % (num fields)-by-(rows)-by-(columns) cell array, so if we work with a
    % Nx1 struct array with P fields, we get a PxM cell array, which is
    % nicer to work with than a Px1xM cell array. So transpose before doing
    % the struct2cell call if necessary.
    if localNeedsTransposeBeforeStruct2Cell(a)
        varCell = struct2cell(a.').';
    else
        varCell = struct2cell(a).';
    end
end

function needsTranspose = localNeedsTransposeBeforeStruct2Cell(a)
    % Called to see if the struct array should be transposed before
    % struct2cell is called.  This is so we get a (num fields)-by-(rows)
    % cell array instead of a (num fields)-by-1-by-(rows) cell array.
    [numrows, ~] = size(a);
    needsTranspose = (numrows == 1);
end

function scalarNumeric = localIsScalarNumeric(varData)
    % Called to check if the data contained within the cell array varData
    % is all scalar numeric values or not.  It is considered numeric if it
    % is one of the double, uint*, int*, or logical, and the number of
    % elements in each cell is 1.  (Note that for larger cell arrays, using
    % the 'isclass' call multiple times still yields better performance
    % than calling @isnumeric().
    scalarNumeric = all(all((cellfun('islogical', varData) | ...
        cellfun('isclass', varData, 'double') | ...
        cellfun('isclass', varData, 'uint8') | ...
        cellfun('isclass', varData, 'uint16') | ...
        cellfun('isclass', varData, 'uint32') | ...
        cellfun('isclass', varData, 'uint64') | ...
        cellfun('isclass', varData, 'int8') | ...
        cellfun('isclass', varData, 'int16') | ...
        cellfun('isclass', varData, 'int32') | ...
        cellfun('isclass', varData, 'int64')) ...
        & (cellfun('prodofsize', varData) == 1)));
end

function currentValue = localGetValueFromWorkspace(theWorkspace, wsVariableName)
    % Returns the value from the given workspace.  If the workspace has a
    % getVariable method, it will attempt to use it.  Otherwise (or if this
    % fails), it will use evalin of the variable name.
    if ismethod(theWorkspace, 'getVariable')
        try
            currentValue = getVariable(theWorkspace, wsVariableName);
        catch
            % In case of failure, fallback to using currentValue
            currentValue = evalin(theWorkspace, wsVariableName);
        end
    else
        currentValue = evalin(theWorkspace, wsVariableName);
    end
end

