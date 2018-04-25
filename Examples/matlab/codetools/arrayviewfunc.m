function varargout = arrayviewfunc(whichcall, varargin)
%ARRAYVIEWFUNC  Support function for the Variable Editor component

%   Copyright 1984-2017 The MathWorks, Inc.

% make sure this function does not clear
mlock

persistent defaultWorkspaceID
if isempty(defaultWorkspaceID)
    defaultWorkspaceID = workspacefunc('getdefaultworkspaceid');
end

% Special handling for some of the updated APIs
if nargin > 1 && isa(varargin{1},'com.mathworks.mlservices.WorkspaceVariable') && length(varargin{1}) == 1 
    swl = com.mathworks.mlwidgets.workspace.MatlabWorkspaceListener.swl(true);
    cleaner = getCleanupHandler(swl); %#ok<NASGU>
end

% Some callers expect to handle errors as strings in varargout.
returnError = false;

% Some callers expect to handle errors as thrown errors.
throwError = true;

% Some callers require the VariableEditor to refresh.
requireUpdate = false;

% Some callers require special handling for value assignment.
assignValue = false;

if nargin > 1 && isa(varargin{1},'com.mathworks.mlservices.WorkspaceVariable') && length(varargin{1}) == 1
    % We can't call workspacefunc('getExist') because this call needs to
    % be made only one stack frame from the calling workspace.
    variable = varargin{1};
    variableName = char(variable.getVariableName);
    workspaceID = variable.getWorkspaceID;
    theWorkspace = workspacefunc('getworkspace', workspaceID, false);
    
    % always check for base name
    baseVariableName = arrayviewfunc('getBaseVariableName',variableName);
    if ischar(theWorkspace)
        exists = logical(evalin(theWorkspace, ['builtin(''exist'',''' baseVariableName ''' , ''var'')']));
    elseif ismethod(theWorkspace, 'hasVariable')
        exists = hasVariable(theWorkspace, baseVariableName);
    else
        exists = logical(evalin(theWorkspace, ['exist(''' baseVariableName ''' , ''var'')']));
    end
    
    if exists
        if ismethod(theWorkspace, 'getVariable')
            baseValue = getVariable(theWorkspace, baseVariableName);
            
            if ~isequal(baseVariableName, variableName)
                % getVariable only works on the base variable name (you
                % can't access struct field values, for example), so
                % need to fallback to using evalin
                currentValue = evalin(theWorkspace, variableName);
            else
                try
                    % Use the getVariable method on the workspace to
                    % get access to the variable
                    currentValue = getVariable(theWorkspace, variableName);
                catch
                    % In case of failure, fallback to using evalin
                    currentValue = evalin(theWorkspace, variableName);
                end
            end
        else
            baseValue = evalin(theWorkspace, baseVariableName);
            currentValue = evalin(theWorkspace, variableName);
        end
    else
        currentValue = [];
    end
end

try
    switch whichcall
        case 'getdata',
            varargout{1} = getData(varargin{1}, varargin{2});
        case 'setdata', % used by ide/ArrayEditor
            varargout{1} = setData(varargin{1}, varargin{2}, varargin{3}); % legacy code , used by Inspector.
        case 'setdatalogic',
            [varargout{1}, varargout{2}] = setDataLogic(varargin{1}, varargin{2}, varargin{3});
        case 'setvarwidth', % used by ide/ArrayEditor
            varargout{1} = setVarWidth(varargin{1}, varargin{2}); % legacy code , used by Inspector.
        case 'setvarwidthlogic',
            [varargout{1}, varargout{2}] = setVarWidthLogic(varargin{1}, varargin{2});
        case 'setvarheight', % used by ide/ArrayEditor
            varargout{1} = setVarHeight(varargin{1}, varargin{2}); % legacy code , used by Inspector.
        case 'setvarheightlogic',
            [varargout{1}, varargout{2}] = setVarHeightLogic(varargin{1}, varargin{2});
        case 'removerowsorcolumns',
            varargout{1} = removeRowsOrColumns(varargin{:});
        case 'insertrowsorcolumns',
            varargout{1} = insertRowsOrColumns(varargin{:});
        case 'renamefield',
            varargout{1} = renameField(varargin{1}, varargin{2}, varargin{3});
        case 'valueHasAppropriateIndexing',
            varargout{1} = valueHasAppropriateIndexing(varargin{:});
        case 'isPossibleIndexedEntityName',
            varargout{1} = isPossibleIndexedEntityName(varargin{:});
        case 'getBaseVariableName',
            varargout{1} = getBaseVariableName(varargin{1});
        case 'assignmentPassthrough',
            varargout{1} = assignmentPassthrough(varargin{1});
        case 'createSpreadsheetValues',
            varargout{1} = createSpreadsheetValues(varargin{1});
        case 'reportValues', % unused outside this file
            [varargout{1}, varargout{2}] = ...
                reportValues(defaultWorkspaceID, varargin{:});
        case 'reportValuesCallback',
            reportValuesCallback(defaultWorkspaceID, varargin{:});
        case 'reportValuesCallbackSynchronous',
            [varargout{1}, varargout{2}] = reportValuesCallbackSynchronous(defaultWorkspaceID, varargin{:});
        case 'reportValuesLogic',
            [varargout{1}, varargout{2}, varargout{3}, varargout{4}, ...
                varargout{5}, varargout{6}, varargout{7}, varargout{8}, ...
                varargout{9}, varargout{10}, varargout{11}] = reportValuesLogic(varargin{:});
        case 'reportValueMetaInfo',
            varargout{1} = reportValueMetaInfo(varargin{:});
        case 'reportNonexistentValueMetaInfo',
            varargout{1} = reportNonexistentValueMetaInfo;
        case 'doHashedAssignment',
            varargout{1} = doHashedAssignment(varargin{:});
        case 'undoHashedAssignment',
            varargout{1} = undoHashedAssignment(varargin{:});
        case 'doVDSAssignment',
            varargout{1} = doVDSAssignment(varargin{:});
        case 'undoVDSAssignment',
            varargout{1} = undoVDSAssignment(varargin{:});
        case 'doMultiFieldAutoCopy',
            varargout{1} = doMultiFieldAutoCopy(varargin{:});
        case 'storeValue',
            storeValue(varargin{:});
            if nargout, varargout{1} = []; end;
        case 'retrieveAndClearValue',
            varargout{1} = retrieveAndClearValue(varargin{1});
        case 'retrieveValue',
            varargout{1} = retrieveValue(varargin{1});
        case 'getAllStorage', % unused outside this file
            varargout{1} = getAllStorage;
        case 'clearValueSafely'
            clearValueSafely(varargin{:});
            if nargout, varargout{1} = []; end;
        case 'whosInformationForProperties',
            [varargout{1}, varargout{2}] = whosInformationForProperties(...
                varargin{1}, varargin{2}, varargin{3});
        case 'getCurrentContextPropsAndPerms',
            [varargout{1}, varargout{2}, varargout{3}, varargout{4}] = getCurrentContextPropsAndPerms(varargin{1}, varargin{2});
        case 'structToWhosInformation',
            varargout{1} = structToWhosInformation(varargin{1});
        case 'getUnsupportedString',
            varargout{1} = getUnsupportedString(varargin{:});
        case 'transpose',
            varargout{1} = getTranspose(varargin{1});
        case 'sortrows',
            varargout{1} = getSortRows(varargin{1}, varargin{2});
        case 'getSelectionIntervals'
            varargout{1} = getSelectionIntervals(varargin{:});
            
            % New APIs begin here
        case 'getUnsupportedVariableString'
            varargout{1} = getUnsupportedString(varargin{2}, varargin{3}, varargin{4}, currentValue);

        case 'getSimulinkDatasetView'
            varargout{1} = getSimulinkDatasetView(varargin{1});

        case 'getSimulinkSimOutMetadata'
            varargout{1} = getSimulinkSimOutMetadata(varargin{1});

        case 'getRef'
            throwError = false;
            
            % Note - this is passing back a ref to the value in
            % this local workspace. This is OK because the Java callers
            % use the ref for reading only. The following command
            % creates an MLArrayRef.
            varargout{1} = system_dependent(45,currentValue);
            
        case 'updateValueTableModel',
            throwError = false;
            
            varargin = varargin(2:end);
            if length(varargin) > 7 && ~varargin{8} % No UI Table
                varargin{2} = currentValue;
            end
            reportValuesCallback(workspaceID, varargin{:});

            % Only force an update if using the defaultWorkspace.
            % Non-default workspaces generate events that put a forced
            % update into an infinite loop.
            requireUpdate = isequal(defaultWorkspaceID, workspaceID);

        case 'updateValueTableModelSynchronous',
            varargin = varargin(2:end);
            if length(varargin) > 7 && ~varargin{8} % No UI Table
                varargin{2} = currentValue;
            end
            varargout{1} = reportValuesCallbackSynchronous(workspaceID, varargin{:});
            
        case 'updateValueInformation',
            throwError = false;
            
            varargout{1} = reportNonexistentValueMetaInfo;
            
            if exists
                try %#ok - ignoring try/catch because the above default value is sufficient.
                    varargout{1} = reportValueMetaInfo(currentValue);
                end
            end
            
        case 'vdsSetValuesAt', % ValueDataSection = vds
            returnError = true;
            
            if ~exists
                return
            end
            
            vdsKey = varargin{2};
            targetValue = varargin{3};
            rowLow = varargin{4};
            rowHigh = varargin{5};
            colLow = varargin{6};
            colHigh = varargin{7};
            
            if rowLow == 0 || colLow == 0
                error(message('MATLAB:arrayviewfunc:IndexesMustBeOneBased'));
            end
            
            variableIsChar = ischar(currentValue);
            
            % Store the current value for undo
            storeValue(vdsKey, currentValue);
            
            if ~ischar(targetValue)
                error(message('MATLAB:arrayviewfunc:TargeValueMustBeAString'));
            end
            
            % Set the specified region.
            newElement = evalin(theWorkspace, targetValue);
            
            if variableIsChar
                newValue = newElement;
            else
                newValue = currentValue;
                newValue(rowLow : rowHigh , colLow : colHigh ) = newElement;
            end
            
            assignmentValue = newValue;
            assignValue = true;
            
            requireUpdate = true;
            
        case 'undo',
            throwError = false;
            
            if ~exists
                return
            end
            
            vdsKey = varargin{2};
            
            % Fetch the previous value - this is the whole matrix
            try
                previousValue = retrieveAndClearValue(vdsKey);
            catch e %#ok
                % ignore this message - the undo stack is lossy
                return
            end
            
            assignmentValue = previousValue;
            assignValue = true;
            
            requireUpdate = true;
            
        case 'deleteInsert',
            throwError = false;
            
            if ~exists
                return
            end
            
            % TODO validate this with non-contiguous regions
            vdsKey = varargin{2};
            rows = eval(varargin{3}); %convert string indexing expression
            cols = eval(varargin{4});
            command = varargin{5};
            direction = eval(varargin{6}); % java sends a string like this: 'up/down'
            
            % Store the current value for undo
            storeValue(vdsKey, currentValue);
            
            % Do the delete/insert
            switch command
                case 'insertrowsorcolumns'
                    newValue = insertRowsOrColumns(currentValue, rows, cols, direction, []);
                case 'removerowsorcolumns'
                    newValue = removeRowsOrColumns(currentValue, rows, cols, direction, []);
                otherwise
                    error(message('MATLAB:arrayviewfunc:UnknownOption', command));
            end
            
            assignmentValue = newValue;
            assignValue = true;
            
            requireUpdate = true;
            
        case 'sortRows',
            throwError = true;
            
            if ~exists
                return
            end
            
            % TODO validate this with non-contiguous regions
            vdsKey = varargin{2};
            columns = eval(varargin{3}); %convert string indexing expression
            
            % Store the current value for undo
            storeValue(vdsKey, currentValue);
            
            % Do the sorting
            newValue = getSortRows(currentValue, columns);
            
            assignmentValue = newValue;
            assignValue = true;
            
            requireUpdate = true;
            
        case 'clearRegion'
            throwError = false;
            
            if ~exists
                return
            end
            
            vdsKey = varargin{2};
            
            % Store the current value for undo
            storeValue(vdsKey, currentValue);
            
            % Clear the specified region or the whole thing.
            if length(varargin) > 2
                rows = varargin{3};
                cols = varargin{4};
                newValue = currentValue;
                if iscell(newValue)
                    % TODO verify this code against a working prototype with the new hooks
                    % this will fail with non-contiguous indexing
                    %newValue( rows, cols ) = cell(rows(2)+1 - rows(1), cols(2)+1 - cols(1));
                    newValue( rows(1):rows(end), cols(1):cols(end) ) = cell(rows(end)+1 - rows(1), cols(end)+1 - cols(1));
                else
                    newValue( rows, cols ) = 0;
                end
            else
                newValue = [];
            end
            
            assignmentValue = newValue;
            assignValue = true;
            
            requireUpdate = true;
            
        case 'updateDataForStruct',
            throwError = false;
            
            if ~exists
                return
            end
            
            varargout{1} = structToWhosInformation(currentValue);
            
        case 'uctaUpdateData' % UnsupportedClassTextArea == ucta
            throwError = false;
            
            if ~isequal(baseVariableName, variableName)
                exists = isPossibleIndexedEntityName(variableName) && ...
                    valueHasAppropriateIndexing(variableName, baseValue);
            end
            varargout{1} = exists;
            
        case 'mmmUpdateData' % MatlabMCOSModel == mmm
            throwError = false;
            
            % We could do something different here but this is solid because
            % the mfilename('class') function returns '' except when we are
            % debugging a class.
            if isequal(theWorkspace,'caller')
                classInfo = evalin(theWorkspace,'mfilename(''class'')');
            else
                classInfo = ''; % TODO: To be Reviewed
            end
            [fieldNames, writables] = ...
                getCurrentContextPropsAndPerms(currentValue, classInfo);
            [varargout{1}, varargout{2}] = whosInformationForProperties(...
                currentValue, fieldNames, writables);
            
        case 'doTranspose',
            throwError = false;
            
            if ~exists
                return
            end
            
            vdsKey = varargin{2};
            
            % Store the current value for undo
            storeValue(vdsKey, currentValue);
            
            newValue = getTranspose(currentValue);
            
            assignmentValue = newValue;
            assignValue = true;
            
            requireUpdate = true;
            
        case 'matmSetValuesAt' % matm = MatlabArrayTableModel
            throwError = false;
            
            vdsKey = varargin{2};
            % transpose to compensate for Java -> MATLAB conversion
            newValuesCell = varargin{3}';
            setValuesAIndicies = varargin{4};
            setValuesBIndicies = varargin{5};
            evaluateStrings = varargin{6};
            
            % Store the current value for undo
            storeValue(vdsKey, currentValue);
            
            % extract the desired values from the cell array
            new_m = length(newValuesCell);
            new_n = length(newValuesCell{1});
            if iscell(currentValue)
                newValue = cell(new_m, new_n);
            else
                newValue = zeros(new_m, new_n);
            end
            
            for i = 1:new_m
                for j = 1:new_n
                    candidate = newValuesCell{i}{j};
                    % pasted empty strings from Java come through as [].
                    if ~isempty(candidate) && ~isequal(candidate,'[]')
                        doubleValue = str2double(candidate);
                        if iscell(currentValue)
                            if isnan(doubleValue)
                                if evaluateStrings
                                    try
                                        value = evalin(theWorkspace,candidate);
                                    catch 
                                        % this model tries three ways to
                                        % put a value in place:
                                        % 1) as a double
                                        % 2) as a MATLAB expression
                                        % 3) as a string
                                        value = candidate;
                                    end
                                else
                                    value = candidate;
                                end
                            else
                                value = doubleValue;
                            end
                            newValue{i,j} = value;
                        else
                            if isnan(doubleValue)
                                try
                                    newValue(i,j) = evalin(theWorkspace,candidate);
                                catch
                                    displayErrorDialog;
                                    varargout{1}=[];
                                    return;
                                end
                            else
                                newValue(i,j) = doubleValue;
                            end
                        end
                    end
                end
            end
            
            % Determine the paste indices
            pasteIndex_m = [];
            for i = 1:setValuesAIndicies.size
                pointsM = setValuesAIndicies.get(i-1);
                pasteIndex_m(end+1,:) = pointsM; %#ok<AGROW>
            end
            if i == 1
                singleMIndex = true;
            else
                singleMIndex = false;
            end
            
            pasteIndex_n = [];
            for i = 1:setValuesBIndicies.size
                pointsN = setValuesBIndicies.get(i-1);
                pasteIndex_n(:,end+1) = pointsN; %#ok<AGROW>
            end
            if i == 1
                singleNIndex = true;
            else
                singleNIndex = false;
            end
            
            if singleMIndex && singleNIndex
                scalarPaste = true;
            else
                scalarPaste = false;
            end
            
            % store the new value into the right location
            allM = [];
            for j = 1:size(pasteIndex_m,1)
                m1 = pasteIndex_m(j,1);
                m2 = pasteIndex_m(j,2);
                if (m1 == m2 && new_m ~= 1 && scalarPaste)
                    % expand selection
                    m2 = m1 + new_m - 1;
                end
                allM = [allM m1:m2]; %#ok
                
            end
            
            allN = [];
            for i = 1:size(pasteIndex_n,2)
                n1 = pasteIndex_n(1,i);
                n2 = pasteIndex_n(2,i);
                if (n2 == n1 && new_n ~= 1 && scalarPaste)
                    % expand the selection
                    n2 = n1 + new_n - 1;
                end
                allN = [allN n1:n2]; %#ok
            end
            
            mCount = length(allM);
            nCount = length(allN);
            allM = allM';
            if floor(mCount / new_m) == mCount / new_m && ...
                    floor(nCount / new_n) == nCount / new_n
                % only replicate if it will be an integer tiling
                newValue = repmat(newValue, mCount / new_m, nCount / new_n);
            end
            
            % Caller should handle errors from here
            returnError = true;
            
            currentValue(allM, allN) = newValue;
            
            assignmentValue = currentValue;
            assignValue = true;
            
            requireUpdate = true;
            
        case 'amotmSetValueAt' % AbstractMatlabObjectTableModel = amotm
            throwError = false;
            
            if ~exists
                return
            end
            
            vdsKey = varargin{2};
            requestedLHS = varargin{3};
            requestedRHS = varargin{4};
            evaluateStrings = varargin{5};
            
            % Store the current value for undo
            storeValue(vdsKey, currentValue);
            
            % Caller should handle errors from here
            returnError = true;
            
            % Set the specified region.
            if evaluateStrings
                newElement = evalin(theWorkspace, requestedRHS);
            else
                newElement = requestedRHS;
            end
            newValue = setVariableValue(baseVariableName, baseValue, requestedLHS, newElement);
            
            assignin(theWorkspace, variableName , newValue);
            
            requireUpdate = true;
            
        case 'createTabularObjectValue' % For testing
            varargout{1} = createTabularObjectValue(varargin{:});
        case 'reportDatasetValuesLogic'
            [varargout{1}, varargout{2}] = reportDatasetValuesLogic(varargin{:});
        case 'variableEditorGridSize'
            varObj = varargin{1};
            m = metaclass(varObj);
            if ~isempty(findobj(m.MethodList, 'Name', 'variableEditorGridSize'))
                varargout{1} = variableEditorGridSize(varObj);
            else
                varargout{1} = [];
            end
        case 'getTableForTimetableCopy'
            tbl = varargin{1};
            tmp = timetable2table(tbl);
            varargout{1} = tmp(:, 2:end);
        otherwise
            error(message('MATLAB:arrayviewfunc:UnknownOption', upper( whichcall )));
    end
 
    % Always if(assignValue) block to be executed before if(requireUpdate) block
    if assignValue
       if isequal(baseVariableName, variableName)
            assignin(theWorkspace, variableName , assignmentValue);
       else
           % This is the temporary solution for solving synchronization
           % issue between ME list view and dialog view.
           % Will update this to setValue in future for Simulink data
           % objects.
           if(isnumeric(assignmentValue) || ischar(assignmentValue))
               expr = [variableName ' = ' mat2str(assignmentValue)];
               evalin(theWorkspace, expr);
           else
               expr = variableName(getIndicesOfIndexingChars(variableName):end);
               newBaseValue = baseValue;
               eval(['newBaseValue' expr ' = assignmentValue;'])
               assignin(theWorkspace, baseVariableName , newBaseValue);
           end
        end
    end
    
    if requireUpdate
        com.mathworks.mlwidgets.workspace.MatlabWorkspaceListener.reportWSChange();
    end
    
    if nargout && ~builtin('exist','varargout','var')
        varargout(1:nargout) = cell(1,nargout);
    end
catch e
    if returnError
        varargout{1} = e.message;
    elseif throwError
       rethrow(e)
    else
        showError(whichcall, e)
        varargout{1}=[]; % to suppress hard error message display on command window
    end
end

%********************************************************************
function out = setVariableValue(baseVariableName,baseValue,lhs,rhs) %#ok
% Use a function to this value so we don't add unexpected variables
% to the caller's workspace.
eval([baseVariableName '= baseValue;']);
eval([lhs ' =  rhs;']);
out = eval(baseVariableName);

%********************************************************************
function result = getData(x, fformat)
if (ischar(x))
    % First, make sure that there aren't a newline in the string.
    % If there are, we can't display it properly.
    if ~isempty(strfind(x, char(10))) || ~isempty(strfind(x, char(13)))
        result = [];
    else
        result = sprintf('%s', x);
    end
elseif iscellstr(x)
    % First, make sure that there are no newlines in the strings.
    % If there are, we can't display them properly.
    found = false;
    for i = 1:length(x)
        if ~isempty(strfind(x{i}, char(10))) || ~isempty(strfind(x{i}, char(13)))
            result = [];
            found = true;
        end
    end
    % have to pad with a space so java tokenizer will function
    % properly when a cell contains an empty string.
    if ~found
        result = sprintf('%s \n', x{:});
    end
elseif iscell(x)
    result = [];
else
    oldFormat = get(0, 'Format');
    oldSpacing = get(0, 'FormatSpacing');

    format(fformat);
    format('compact');

    if length(x) > 1
        result = evalc('disp(x(:))');
    else
        result = evalc('disp(x)');
    end

    
    format(oldFormat);
    format(oldSpacing);
end


%********************************************************************
function newRef = setData(var, coord, expr)
[var, passed] = setDataLogic(var, coord, expr);
if passed
    newRef = system_dependent(45, var);
else
    newRef = var;
end

%********************************************************************
function [var, passed] = setDataLogic(var, coord, expr)
try
    if ischar(var)
        var = expr;
    elseif iscellstr(var),
        var{coord{:}} = expr;
    else
        var(coord{:}) = eval(expr);
    end
    passed = true;
catch anError
    var = anError.message;
    passed = false;
end

%********************************************************************
function [var, pass] = setVarWidthLogic(var, width)
try
    sz = size(var);
    oldWidth = sz(2);

    if iscellstr(var),
        repl = {''};
    else
        repl = 0;
    end

    if width > oldWidth,
        var(:,end+1:width) = repl;
    elseif width < oldWidth,
        var(:,width+1:end) = [];
    end
    pass = true;
catch anError
    var = anError.message;
    pass = false;
end

%********************************************************************
function newRef = setVarWidth(var, width)
% used by ide/ArrayEditor
[var, pass] = setVarWidthLogic(var, width);
if pass
    newRef = system_dependent(45, var);
else
    newRef = var;
end;

%********************************************************************
function [var, pass] = setVarHeightLogic(var, height)
try
    sz = size(var);
    oldHeight = sz(1);

    if iscellstr(var),
        repl = {''};
    else
        repl = 0;
    end;

    if height > oldHeight,
        var(end+1:height,:) = repl;
    elseif height < oldHeight,
        var(height+1:end,:) = [];
    end;
    pass = true;
catch anError
    var = anError.message;
    pass = false;
end

%********************************************************************
function newRef = setVarHeight(var, height)
% used by ide/ArrayEditor
[var, pass] = setVarHeightLogic(var, height);
if pass
    newRef = system_dependent(45, var);
else
    newRef = var;
end;

%********************************************************************
function out = removeRowsOrColumns(orig, rowindices, colindices, direction, key)

toStore = [];
% Take care of the easy cases first
if isa(orig, 'char')
    % A char array (guaranteed to be 1xN)
    orig = '';
elseif strcmp(rowindices, ':')
    % Entire columns.  Rip them out.
    toStore = orig(:, colindices);
    orig(:, colindices) = [];
elseif strcmp(colindices, ':')
    % Entire rows.  Rip them out.
    toStore = orig(rowindices, :);
    orig(rowindices, :) = [];
else
    % User specified only CERTAIN cells.  More complicated.
    % We'll be removing the selected cells, and moving the
    % "neighbors" up or left, depending on the user's choice.
    empty = 0;
    if isa(orig, 'cell')
        empty = {[]};
    end
    [lastRow, lastCol] = size(orig);
    numberOfRows = length(rowindices);
    numberOfCols = length(colindices);
    if strcmp(direction, 'up/down')
        for destRow = rowindices(1):lastRow
            sourceRow = destRow + numberOfRows;
            for colCounter = 1:numberOfCols
                destCol = colindices(colCounter);
                newValue = empty;
                if (sourceRow <= lastRow)
                    newValue = orig(sourceRow, destCol);
                end
                orig(destRow, destCol) = newValue;
            end
        end
    elseif strcmp(direction, 'left/right')
        for destCol = colindices(1):lastCol
            sourceCol = destCol + numberOfCols;
            for rowCounter = 1:numberOfRows
                destRow = rowindices(rowCounter);
                newValue = empty;
                if (sourceCol <= lastCol)
                    newValue = orig(destRow, sourceCol);
                end
                orig(destRow, destCol) = newValue;
            end
        end
    end
end
% if numel(orig) == 0 && isnumeric(orig) && sum(size(orig)) > 0
%     % Reduces the array to a 0x0 without changing its class.
%     orig = repmat(orig, 0, 0);
% end
if (~isempty(toStore))
    storeValue(key, toStore);
end
out = orig;

%********************************************************************
function out = insertRowsOrColumns(orig, rowindices, colindices, direction, key)

empty = 0;
if isa(orig, 'cell')
    empty = {[]};
else if isa(orig, 'struct')
        empty = createEmptyStruct(orig);
    end
end

[height, width] = size(orig);

% Take care of the easy cases first
if isa(orig, 'char')
    % A char array (guaranteed to be 1xN)
    orig = '';
elseif strcmp(rowindices, ':')
    % Entire columns.  Shift all higher columns down and fill the selection
    % with 'empty' (whatever's appropriate for the data type).
    if strcmp(colindices, ':')
        colindices = 1:width;
    end
    numToShift = length(colindices);
    if numToShift==colindices(end)-colindices(1)+1 % Contiguous selection
        for i = (width + numToShift):-1:max([colindices numToShift+1])
            orig(:, i) = orig(:, i-numToShift);
        end
    else
        % For discontiguous columns, the amount of the column shift depends
        % on the position of the column relative to the added columns. For
        % example, if there are 5 columns and 2-3 5 are selected for left
        % insertion, colindices==[2:3 7] (expressed in indices relative to 
        % the expanded array).  3 new columns need to be added,
        % 2 columns between 1-2 (position 1:2 in the expanded array) and 1
        % column between 4-5 (position 7 in the expanded array).
        for i = (width + numToShift):-1:colindices(1)+1
            pos = i-sum(colindices<=i);
            if pos>=1
                orig(:, i) = orig(:,pos);
            end
        end
    end
    if ~isempty(key) && keyExists(key)
        toReplace = retrieveAndClearValue(key);
        orig(:, colindices) = toReplace;
    else
        for i = colindices
            orig(:, i) = empty;
        end
    end
elseif strcmp(colindices, ':')
    % Entire rows.  Shift all higher rows to the left and fill the selection
    % with 'empty' (whatever's appropriate for the data type).
    % Dealt with the row is :, col is : case above.  Don't do it again.
    numToShift = length(rowindices);
    if numToShift==rowindices(end)-rowindices(1)+1
        for i = (height + numToShift):-1:max([rowindices numToShift+1])
            orig(i, :) = orig(i-numToShift, :);
        end
    else
        % For discontiguous rows, the amount of the row shift depends
        % on the position of the row relative to the added rows. For
        % example, if there are 5 rows and 2-3 5 are selected for upper
        % insertion, rowindices==[2:3 7] (expressed in indices relative to 
        % the expanded array). 3 new rows need to be added,
        % 2 rows between 1-2 (position 1:2 in the expanded array) and 1 row
        % between 4-5 (position 7 in the expanded array).
        for i = (height + numToShift):-1:rowindices(1)+1
            pos = i-sum(rowindices<=i);
            if pos>=1
                orig(i, :) = orig(pos,:);
            end
        end    
    end
    if ~isempty(key) && keyExists(key)
        toReplace = retrieveAndClearValue(key);
        orig(rowindices, :) = toReplace;
    else
        for i = rowindices
            orig(i, :) = empty;
        end
    end
else
    % User specified only CERTAIN cells.  More complicated.
    % We'll be moving the selected cells and their "neighbors"
    % down or to the right, depending on the user's choice.
    % Fill in the selected cells with 'empty' (whatever's
    % appropriate for the data type).

    % Move things around
    [lastRow, lastCol] = size(orig);
    lastRowOfSelection = rowindices(end);
    lastColOfSelection = colindices(end);
    numberOfRows = length(rowindices);
    numberOfCols = length(colindices);
    if strcmp(direction, 'up/down')
        for sourceRow = lastRow:-1:rowindices(1)
            destRow = sourceRow + numberOfRows;
            for colCounter = 1:numberOfCols
                destCol = colindices(colCounter);
                newValue = empty;
                if (destRow > lastRowOfSelection)
                    newValue = orig(sourceRow, destCol);
                end
                orig(destRow, destCol) = newValue;
            end
        end
    elseif strcmp(direction, 'left/right')
        for sourceCol = lastCol:-1:colindices(1)
            destCol = sourceCol + numberOfCols;
            for rowCounter = 1:numberOfRows
                destRow = rowindices(rowCounter);
                newValue = empty;
                if (destCol > lastColOfSelection)
                    newValue = orig(destRow, sourceCol);
                end
                orig(destRow, destCol) = newValue;
            end
        end
    end

    % Zero out the selection...
    orig(rowindices, colindices) = empty;

    % "Patch up" cell arrays to preserve the char array nature of empties.
    if isa(orig, 'cell')
        [l, w] = size(orig);
        for i = 1:l
            for j = 1:w
                if isempty(orig{i, j})
                    orig(i, j) = {[]};
                end
            end
        end
    end
end
out = orig;

%********************************************************************
function in = renameField(in, oldFieldName, newFieldName)
if ~strcmp(oldFieldName, newFieldName)
    allNames = fieldnames(in);
    % Is the user renaming one field to be the name of another field?
    % Remember this.
    isOverwriting = ~isempty(find(strcmp(allNames, newFieldName), 1));
    matchingIndex = find(strcmp(allNames, oldFieldName));
    if ~isempty(matchingIndex)
        allNames{matchingIndex(1)} = newFieldName;
        for k=1:length(in)
             in(k).(newFieldName) = in(k).(oldFieldName);    
        end
        in = rmfield(in, oldFieldName);
        if (~isOverwriting)
            % Do not attempt to reorder if we've reduced the number
            % of fields.  Bad things will result.  Let it go.
            in = orderfields(in, allNames);
        end
    end
end

%********************************************************************
function out = createEmptyStruct(in)
fields = fieldnames(in);
args = cell(1, 2*length(fields));
for inc = 1:length(fields)
    args{2*inc-1} = fields{inc};
    args{2*inc} = [];
end
out = struct(args{:});

%********************************************************************
function out = valueHasAppropriateIndexing(name, value)
out = false;
if length(name) >= 3
    special = getIndicesOfIndexingChars(name);
    if ~isempty(special) && special(1) ~= 1
        try
            eval(['value' name(special(1):end) ';']);
            out = true;
        catch anError
            % This is to get around the issues with private variables
            % while debugging. See Geck 693641
            if (strcmp(anError.identifier,'MATLAB:class:GetProhibited'))
                try
                    valuestruct = struct(value); %#ok
                    eval(['valuestruct' name(special(1):end) ';']);
                    out = true;
                catch ignoreError %#ok<NASGU> ignore exceptions
                end
            end
        end
    end
end

%********************************************************************
function out = getBaseVariableName(name)
out = '';
done = false;
if isempty(name)
    done = true;
end
if isvarname(name)
    out = name;
    done = true;
end

if ~done
    % get rid of beginning and end chars
    nameModified = false;
    while any(strfind(name, '[') == 1) || any(strfind(name, '{') == 1)
        name = strtrim(name(2:end));
        nameModified = true;
    end
    while any(strfind(name, ']') == length(name)) || any(strfind(name, '}') == length(name)) || any(strfind(name, '''') == length(name))
        name = strtrim(name(1:length(name)-1));
        nameModified = true;
    end
    
    special = getIndicesOfIndexingChars(name);
    if ~isempty(special)
        out = name(1:special(1)-1);
    elseif nameModified 
        out = name;
    end
end

%********************************************************************
function out = isPossibleIndexedEntityName(in)
out = false;
if length(in) >= 3
    special = getIndicesOfIndexingChars(in);
    if ~isempty(special)
        out = special(1) ~= 1 && special(end) ~= length(in);
    end
end

%********************************************************************
function out = getIndicesOfIndexingChars(in)
out = [];
if length(in) >= 2
    dots = strfind(in, '.');
    parens = strfind(in, '(');
    curleys = strfind(in, '{');
    out = sort([dots parens curleys]);
end

%********************************************************************
function result = assignmentPassthrough(in)
result = in;

%********************************************************************
function out = createSpreadsheetValues(in)
s = size(in);
out = cell(s);
for i = 1:s(1)
    for j = 1:s(2)
        try
            eval(['out{i, j} = ' in{i, j} ';']);
        catch err %#ok<NASGU>
            out{i, j} = in{i, j};
        end
    end
end

%********************************************************************
function [nameForAssign, toReport, startRow, startColumn, ...
    fullWidth, fullHeight, ...
    classID, customClassDescription, dims, recurse, valueIsCellStr] = reportValuesLogic(...
    nameForAssign, value, startRow, startColumn, endRow, endColumn, recurse)
import com.mathworks.mlwidgets.array.data.FunctionHandleValue;
if nargin < 3
    startRow = 1;
end
if nargin < 4
    startColumn = 1;
end
if nargin < 5
    endRow = -1; %Patch it up below.
end
if nargin < 6
    endColumn = -1; %Patch it up below.
end
if nargin < 7
    recurse = true;
end

s = getVariableSize(value); % Treat this as read-only throughout.
fullHeight = s(1);
fullWidth  = s(2);
customClassDescription = class(value);
classID = getMLArrayRefClass(value, customClassDescription);
dims = length(getVariableSize(value));

% Calculate truncation limits
valueIsCellStr = iscellstr(value);
ischars = ischar(value);
trueEndRow = s(1);
if (endRow == -1) || ischars
    endRow = trueEndRow;
else
    endRow = min(endRow, trueEndRow);
end
trueEndColumn = s(2);
if (endColumn == -1) || ischars
    endColumn = trueEndColumn;
else
    endColumn = min(endColumn, trueEndColumn);
end
if startRow > endRow
    startRow = endRow;
end
if startColumn > endColumn
    startColumn = endColumn;
end

% We needed to get all of the values calculated so far strictly correct,
% even for the "empty" cases.  But we do NOT need a correct value of
% toReport for the "empty" cases, so we short-circuit the full-blown
% calculations and simply return [].
if endRow == 0 || endColumn == 0 || localIsEmpty(value)
    if isstruct(value) || isjava(value)
        % Handle empty structs or empty java objects in their entirety
        toReport = value;
    else
        toReport = [];
    end
else
    if isa(value, 'function_handle')
        toReport = func2str(value);
        if toReport(1) ~= '@'
            toReport = ['@' toReport];
        end
        toReport = FunctionHandleValue.valueOf(toReport);
        % cf 1.1.4.73.8.1
    % Handle subclasses of numeric with properties which cannot be subindexed
    elseif (s(1)==1 && s(2)==1 && startRow==1 && endRow==1 && startColumn==1 && endColumn==1)
        toReport = value;
    else
        if isjava(value)
            % Handle java objects in their entirety (don't try to index into
            % them).
            toReport = value;
        else
            try
                toReport = value(startRow:endRow, startColumn:endColumn);
            catch me %#ok<NASGU>
                % If the subsref fails (c.f. g1093728) handle objects in 
                % their entirety (don't try to index into them). 
                toReport = value;
            end
        end
    end
end
if (ischars)
    fullWidth = 1;
    fullHeight = 1;
end

%********************************************************************
%function ca = reportValuesCallback(workspaceID, varargin)
function varargout = reportValuesCallbackFcn(syncronousValueDataSection,workspaceID, varargin)
% workspaceId, name, value, startRow, startColumn, endRow, endColumn, hashCode, [isuitable]
import com.mathworks.mlwidgets.array.*;
import com.mathworks.widgets.spreadsheet.data.*;
import com.mathworks.mlwidgets.array.data.*;
isNewStyleObject = false;
isSystemObject = false;
uitableUsage = false;

% uitable passes true as 8th argument.
if length(varargin)>7 && varargin{8}
    if ~ishandle(varargin{1})
        return;
    end
    uitableUsage = true;
    % Special case for uitable reuse
    % varargin{1} = uitable handle
    % varargin{2} = the property to use as the workspace value
    value = get(varargin{1}, varargin{2});
    % to match the contract, we are setting varargin{1} to "Data"
    % and varargin{2} to get(table, 'Data')
    varargin{1} = varargin{2};
    varargin{2} = value;
end

if nargin>=4
    dtype = [];
    
    if isa(varargin{2},'dataset') || matlab.internal.datatypes.istabular(varargin{2})
        datasize = variableEditorGridSize(varargin{2});

        if isa(varargin{2}, 'timetable')
            % Add the time column into the timetable data, so that it can
            % be displayed as if it were a column of a table.
            tmpTable = varargin{2};
            timeDimName = tmpTable.Properties.DimensionNames{1};

            % Add the time data with a unique name (the name isn't used in display,
            % the actual DimensionNames property is.
            uniqueVarName = matlab.lang.makeUniqueStrings([timeDimName '_1'], ...
                tmpTable.Properties.VariableNames);
            tmpTable.(uniqueVarName) = tmpTable.(timeDimName);

            % Move the time column to be the first column
            tmpTable = tmpTable(:, [end 1:end-1]);
            varargin{2} = tmpTable;
        end
        
        % Use column based indexing to subsref into the dataset
        [nameForAssign, toReport] = reportDatasetValuesLogic(varargin{1:end-1});
        ca = createTabularObjectValue(workspaceID, toReport,varargin{2});
        toReportdatasize = variableEditorGridSize(toReport);
        if isempty(nameForAssign), nameForAssign = '__dataset__'; end

        if isa(varargin{2},'dataset')
            dtype = 'dataset';
        else
            dtype = 'table';
        end

    elseif isa(varargin{2},'categorical')
        [nameForAssign,toReport,~,startColumn] = reportValuesLogic(varargin{1:end-1});
        ca = createCategoricalArrayValue(toReport,startColumn);
        datasize = size(varargin{2});
        if isempty(nameForAssign), nameForAssign = '__categorical__'; end
        toReportdatasize = size(toReport);
        dtype = 'categorical';
        
    elseif isstruct(varargin{2})
        s = size(varargin{2});
        if (s(1,1) == 1) || (s(1,2) == 1)
            % Use column based indexing to subsref into the struct array
            nameForAssign = varargin{1};
            [toReport, ~, startColumn] = reportStructArrayValuesLogic(varargin{2:end-1});
            ca = createStructArrayValue(workspaceID, toReport, startColumn);
            datasize = internal.matlab.array.StructArrayVariableEditorAdapter.variableEditorGridSize(varargin{2});
            toReportdatasize = internal.matlab.array.StructArrayVariableEditorAdapter.variableEditorGridSize(toReport);
            if isempty(nameForAssign), nameForAssign = '__structarray__'; end
            dtype = 'dataset';
        end
        
    elseif isa(varargin{2}, 'datetime') || isa(varargin{2}, 'duration') || ...
            isa(varargin{2}, 'calendarDuration')
        [nameForAssign,toReport,~,startColumn] = reportValuesLogic(varargin{1:end-1});
        ca = createDatetimeArrayValue(toReport,startColumn);
        datasize = size(varargin{2});
        if isempty(nameForAssign), nameForAssign = '__datetime__'; end
        toReportdatasize = size(toReport);
        dtype = 'datetime';

    elseif isa(varargin{2}, 'string')
        [nameForAssign, toReport, ~, startColumn] = reportValuesLogic(varargin{1:end-1});
        ca = createStringArrayValue(toReport, startColumn);
        datasize = size(varargin{2});
        if isempty(nameForAssign), nameForAssign = '__string__'; end
        toReportdatasize = size(toReport);
        dtype = 'string';
    end
    
    if ~isempty(dtype)
        variable = com.mathworks.mlservices.WorkspaceVariable(nameForAssign, workspaceID);
        vds = ValueDataSection(variable,varargin{3}-1,varargin{4}-1, ...
            toReportdatasize(1) + varargin{3} - 2, toReportdatasize(2) + varargin{4} - 2, ca);
        if syncronousValueDataSection
            varargout{1} = vds;
            varargout{2} = ca;
            return
        end
        vmi = ValueMetaInfo(getMLArrayRefClass(toReport), getAttributes(varargin{2}),dtype, ...
                isNewStyleObject, isSystemObject,2, datasize(2),datasize(1));
        com.mathworks.mlwidgets.array.ValueTableModel.valueRequestCompleted(...
            varargin{7}, vds, vmi);
        return
    end
end

[nameForAssign, toReport, startRow, startColumn, ...
    fullWidth, fullHeight, ...
    classID, customClassDescription, dims, ~, valueIsCellStr] = ...
    reportValuesLogic(varargin{1:6});
signed = ~dataviewerhelper('isUnsignedIntegralType', toReport);

% Check if the object is a numeric sublcass object of single or double.
% To  prevent it to error out when numeric subclass objects are passed for
% float values.
if isfloat(toReport)
  if isa(toReport,'single')
    toReport = single(toReport);
  else
     toReport = double(toReport);
  end
end

% Calls to ValueDataSection should take Java-isms (i.e. zero-based row and
% column specifiers)
if localIsEmpty(toReport)
    try
        ca = ComplexArrayFactory.getEmptyInstance(...
            size(toReport, 1), size(toReport, 2), ...
            cast(0, class(toReport)));
    catch
        ca = ComplexArrayFactory.getEmptyInstance(...
            size(toReport, 1), size(toReport, 2), ...
            0);
    end
else
    if isnumeric(toReport) % Include  subclasses of numbers - Removed(~isObject(toReport))
        if isreal(toReport)
            if isscalar(toReport)
                if isfloat(toReport)
                    ca = ComplexScalarFactory.valueOf(toReport);
                elseif isinteger(toReport)
                    ca = ComplexScalarFactory.valueOf(dataviewerhelper('upconvertIntegralType', toReport), signed);
                else
                    ca = ComplexScalarFactory.valueOf(double(toReport));
                end
            else
                if isfloat(toReport)
                    ca = ComplexArrayFactory.valueOf(toReport);
                elseif isinteger(toReport)
                    ca = ComplexArrayFactory.valueOf(dataviewerhelper('upconvertIntegralType', toReport), signed);
                else
                    ca = ComplexArrayFactory.valueOf(double(toReport));
                end
            end
        else
            if isscalar(toReport)
                if isfloat(toReport)
                    ca = ComplexScalarFactory.valueOf(real(toReport), imag(toReport));
                elseif isinteger(toReport)
                    converted = dataviewerhelper('upconvertIntegralType', toReport);
                    ca = ComplexScalarFactory.valueOf(real(converted), imag(converted), signed);
                else
                    ca = ComplexScalarFactory.valueOf(double(toReport), imag(double(toReport)));
                end
            else
                if isfloat(toReport)
                    ca = ComplexArrayFactory.valueOf(real(toReport), imag(toReport));
                elseif isinteger(toReport)
                    converted = dataviewerhelper('upconvertIntegralType', toReport);
                    ca = ComplexArrayFactory.valueOf(real(converted), imag(converted), signed);
                else
                    ca = ComplexArrayFactory.valueOf(double(toReport), imag(double(toReport)));
                end
            end
        end
    elseif islogical(toReport)
        ca = toReport;
    elseif valueIsCellStr
        % The entire array (not only the segment under consideration) is a
        % cell array of strings.  Allow it to be passed to the Variable
        % Editor as a such, which will be converted into an array (or
        % possibly an array of arrays) of java.lang.String. Replace any
        % char(0) with ' ' so the rest of the string will be displayed,
        % like on the command line.
        try
            ca = cellfun(@localReplaceNullCharacters, toReport, 'UniformOutput', false);
        catch
            ca = toReport;
        end
    elseif ischar(toReport)
        % Replace any char(0) with ' ' so the rest of the string will be
        % displayed, like on the command line.
        if size(toReport, 1) == 1
            % Replace special characters so the text will go through normal
            % processing for Variable Editor display (otherwise it may be
            % truncated to 1xN char, while useful elsewhere, it isn't
            % desirable for the Variable Editor display
            toReport = strrep(strrep(strrep(toReport, newline, ''), char(13), ''), char(0), ' ');
            ca = localReplaceNullCharacters(toReport);
        else
            ca = createReadOnlyValue(toReport);
        end
    elseif iscell(toReport)
        if uitableUsage
            % uitable doesn't want quoted or truncated strings
            ca = createCellArrayValue(workspaceID, toReport, false, Inf);
        else
            % Editor for cell arrays wants truncated, unquoted strings.
            % The caller will handle the quoting for us.
            ca = createCellArrayValue(workspaceID, toReport, false);
        end
    elseif isstruct(toReport) && numel(toReport) > 1
        ca = createLegacyStructArrayValue(workspaceID, toReport);
    elseif (isa(toReport, 'optim.problemdef.OptimizationExpression') || ...
            isa(toReport, 'optim.problemdef.OptimizationConstraint')) && ...
            isscalar(toReport)
        % Treat OptimiztionExpression objects like strings, and create
        % StringArray objects for their display.
        val = expand2str(toReport);
        isMissing = false;
        ca = com.mathworks.mlwidgets.array.data.StringArray.valueOf(...
            val, isMissing);
    else
        try
            isNewStyleObject = ~isempty(meta.class.fromName(customClassDescription));
        catch err %#ok<NASGU>
        end
        % Call createNewObjectArrayValue for all MATLAB object (OOP, UDD,
        % MCOS) arrays. Note that createNewObjectArrayValue relies on the
        % use of MATLAB syntax subsref index
        if all(isobject(toReport)) || all(all(ishandle(toReport))) && ~isjava(toReport)
            ca = createNewObjectArrayValue(workspaceID, toReport, false);
        else
            ca = createReadOnlyValue(toReport);
        end
        isSystemObject = isa(toReport, 'matlab.system.SystemImpl');
    end
end 
variable = com.mathworks.mlservices.WorkspaceVariable(nameForAssign, workspaceID);
vds = ValueDataSection(variable, startRow-1, startColumn-1, ...
        getVariableSize(toReport, 1) + startRow - 2, getVariableSize(toReport, 2) + startColumn - 2, ca);
vds.setUITableUsage(uitableUsage);
if syncronousValueDataSection
    varargout{1} = vds;
    varargout{2} = ca;
else
    vmi = ValueMetaInfo(classID, getAttributes(varargin{2}), customClassDescription, ...
        isNewStyleObject, isSystemObject, dims, fullWidth, fullHeight);
    com.mathworks.mlwidgets.array.ValueTableModel.valueRequestCompleted(...
        varargin{7}, vds, vmi);
end

function val = getTextTruncationLength
    % This is the number of characters to display for text before truncating
    val = 10000;

function newString = localReplaceNullCharacters(s)
    [rows, columns] = size(s);
    if rows == 1
        newString = strrep(s, char(0), ' ');
        % Use strlength to handle scalar string input to this function
        columns = strlength(s);
        if columns > getTextTruncationLength
            % Truncate to some character display length
            obj = workspacefunc('getshortvalueobjectj', newString, false, getTextTruncationLength);
            newString = strrep(char(obj.toString), '''', '');
        end
    elseif columns == 1
        newString = strrep(s', char(0), ' ')';
    else
        tmpString = reshape(s, 1, []);
        tmpString = strrep(tmpString, char(0), ' ');
        newString = reshape(tmpString, rows, columns);
    end

%********************************************************************
function reportValuesCallback(workspaceID, varargin)

reportValuesCallbackFcn(false,workspaceID, varargin{:});

%********************************************************************

function [vds,ca] = reportValuesCallbackSynchronous(workspaceID, varargin)

[vds,ca] = reportValuesCallbackFcn(true,workspaceID, varargin{:});

%********************************************************************
function [vds, vmi] = reportValues(workspaceID, varargin)
% name, value, startRow, startColumn, endRow, endColumn
import com.mathworks.mlwidgets.array.*;
import com.mathworks.widgets.spreadsheet.data.*;
import com.mathworks.mlwidgets.array.data.*;

persistent emptyInstance;

isBracketedSummary = false;
isNewStyleObject = false;
isSystemObject = false;
if isa(varargin{2}, 'com.mathworks.widgets.spreadsheet.data.ValueSummary')
    obj = char(varargin{2}.toString);
    varargin{2} = obj;
    varargin{5} = size(obj, 1);
    varargin{6} = size(obj, 2);
    isBracketedSummary = true;
end    
    
[nameForAssign, toReport, startRow, startColumn, ...
    fullWidth, fullHeight, ...
    classID, customClassDescription, dims, recurse, valueIsCellStr] = ...
    reportValuesLogic(varargin{:});
signed = ~dataviewerhelper('isUnsignedIntegralType', toReport);
% Calls to ValueDataSection should take Java-isms (i.e. zero-based row and
% column specifiers)
if isempty(toReport) && ~isstruct(toReport)
    sz = size(toReport);
    foundEmptyInstance = false;
    if ~isempty(emptyInstance)
        if isequal(emptyInstance.sz, sz) && ...
                strcmp(emptyInstance.cls, class(toReport))
            ca = emptyInstance.ca;
            foundEmptyInstance = true;
        end
    end
    
    if ~foundEmptyInstance
        ca = ComplexArrayFactory.getEmptyInstance(...
            sz(1), sz(2), cast(0, class(toReport)));
        emptyInstance = struct;
        emptyInstance.sz = sz;
        emptyInstance.ca = ca;
        emptyInstance.cls = class(toReport);
    end
else
    if isnumeric(toReport) && ~isobject(toReport) % Exclude subclasses of numbers
        if isreal(toReport)
            if isscalar(toReport)
                if isfloat(toReport)
                    ca = ComplexScalarFactory.valueOf(toReport);
                elseif isinteger(toReport)
                    ca = ComplexScalarFactory.valueOf(dataviewerhelper('upconvertIntegralType', toReport), signed);
                else
                    ca = ComplexScalarFactory.valueOf(double(toReport));
                end
            else
                if isfloat(toReport)
                    ca = ComplexArrayFactory.valueOf(toReport);
                elseif isinteger(toReport)
                    ca = ComplexArrayFactory.valueOf(dataviewerhelper('upconvertIntegralType', toReport), signed);
                else
                    ca = ComplexArrayFactory.valueOf(double(toReport));
                end
            end
        else
            if isscalar(toReport)
                if isfloat(toReport)
                    ca = ComplexScalarFactory.valueOf(real(toReport), imag(toReport));
                elseif isinteger(toReport)
                    converted = dataviewerhelper('upconvertIntegralType', toReport);
                    ca = ComplexScalarFactory.valueOf(real(converted), imag(converted), signed);
                else
                    ca = ComplexScalarFactory.valueOf(double(toReport), imag(double(toReport)));
                end
            else
                if isfloat(toReport)
                    ca = ComplexArrayFactory.valueOf(real(toReport), imag(toReport));
                elseif isinteger(toReport)
                    converted = dataviewerhelper('upconvertIntegralType', toReport);
                    ca = ComplexArrayFactory.valueOf(real(converted), imag(converted), signed);
                else
                    ca = ComplexArrayFactory.valueOf(double(toReport), imag(double(toReport)));
                end
            end
        end
    elseif islogical(toReport)
        ca = toReport;
    elseif valueIsCellStr
        % The entire array (not only the segment under consideration) is a
        % cell array of strings.  Allow it to be passed to the Variable
        % Editor as a such, which will be converted into an array (or
        % possibly an array of arrays) of java.lang.String. Replace any
        % char(0) with ' ' so the rest of the string will be displayed,
        % like on the command line.
        ca = cellfun(@localReplaceNullCharacters, toReport, 'UniformOutput', false);
    elseif ischar(toReport)
        % Replace any char(0) with ' ' so the rest of the string will be
        % displayed, like on the command line.
        if size(toReport, 1) == 1
            toReport = localReplaceNullCharacters(toReport);
            if isBracketedSummary
                ca = createReadOnlyValue(toReport);
            else
                ca = toReport;
            end
        else
            ca = createReadOnlyValue(toReport);
        end
    elseif localIsString(toReport) && isscalar(toReport)
        ca = StringArrayValue;
        missingStr = ismissing(toReport);
        toReport(missingStr) = '<missing>';
        vds = com.mathworks.mlwidgets.array.data.StringArray.valueOf(cellstr(toReport), missingStr);
        ca.addVariable(vds, 0);
    elseif isa(toReport, 'com.mathworks.mlwidgets.array.data.FunctionHandleValue')
        ca = toReport;
    elseif ~recurse
        % If getshortvalueobjectj creates a ValueSummary, then display
        % toReport as a read-only uneditable object
        ca = workspacefunc('getshortvalueobjectj', toReport);
        if isa(ca,'com.mathworks.widgets.spreadsheet.data.ValueSummary')
            ca = createReadOnlyValue(ca);
        end
        %ca = workspacefunc('getshortvalueobjectj', toReport);
        %ca = ReadOnlyValue.valueOf(workspacefunc('getshortvalueobjectj', toReport));
    elseif iscell(toReport)
        ca = createCellArrayValue(workspaceID, toReport);
    else
        try
            isNewStyleObject = ~isempty(meta.class.fromName(customClassDescription));
        catch err %#ok<NASGU>
        end
        % Call createNewObjectArrayValue for all MATLAB object (OOP, UDD,
        % MCOS) arrays. Note that createNewObjectArrayValue relies on the
        % use of MATLAB syntax subsref index
        if all(isobject(toReport)) || all(ishandle(toReport)) && ~isjava(toReport)
            ca = createNewObjectArrayValue(workspaceID,toReport, false);
        else
            ca = createReadOnlyValue(toReport);
        end
        isSystemObject = isa(toReport, 'matlab.system.SystemImpl');
    end
end
variable = com.mathworks.mlservices.WorkspaceVariable(nameForAssign, workspaceID);
sz = getVariableSize(toReport);
vds = ValueDataSection(variable, startRow-1, startColumn-1, ...
    sz(1) + startRow - 2, sz(2) + startColumn - 2, ca);
if nargout > 1
    vmi = ValueMetaInfo(classID, getAttributes(varargin{2}), customClassDescription, ...
        isNewStyleObject, isSystemObject, dims, fullWidth, fullHeight);
end

%********************************************************************
function out = reportValueMetaInfo(varargin)
% Arguments are:
% name, value, startRow, startColumn, endRow, endColumn
import com.mathworks.mlwidgets.array.*;

% input validation, if a list of variables is provided, it is not possible
% to process multiple variables at once
if(size(varargin,2) > 1)
    out = reportNonexistentValueMetaInfo;
    return;
end

in = varargin{1};
attributes = getAttributes(in);
% % Added code to handle the numeric subclass objects
isproperty = isnumeric(in) && isempty(properties(in));
if isa(in,'double') && isproperty
   in = double(in);
   clazz = 'double';
elseif isa(in,'single') && isproperty
   in  = single(in);
   clazz = 'single';
elseif isa(in,'uint8')  && isproperty
   in = uint8(in);
   clazz = 'uint8';
elseif isa(in,'uint16') && isproperty
   in = uint16(in);
   clazz = 'uint16';
elseif isa(in,'uint32') &&isproperty
   in = uint32(in);
   clazz = 'uint32';
elseif isa(in,'uint64') && isproperty
   in = uint64(in);
   clazz = 'uint64';
elseif isa(in,'int8')   && isproperty
   in = int8(in);
   clazz = 'int8';
elseif isa(in,'int16')  && isproperty
    in = int16(in);
    clazz = 'int16';
elseif isa(in,'int32')  && isproperty
    in = int32(in);
    clazz = 'int32';
elseif isa(in,'int64')  && isproperty
    in = int64(in);
    clazz = 'int64';   
else
    clazz = class(in);
end
type = getMLArrayRefClass(in);
numOfDims = length(getVariableSize(in));
isNewStyleObject = false;
isSystemObject = false;
if isa(in,'dataset') || matlab.internal.datatypes.istabular(in)
     [height, width] = variableEditorGridSize(in);
elseif isstruct(in)
    [height, width] = internal.matlab.array.StructArrayVariableEditorAdapter.variableEditorGridSize(in);
elseif isjava(in)
    height = 1;
    width = 1;
elseif istall(in)
    % Special case for tall variables
    height = 1;
    width = 1;
    numOfDims = 2;
else
    inSize = getVariableSize(in);
    [height, width] = resolveVariableSize(in, inSize);

    if (type == com.mathworks.jmi.types.MLArrayRef.mxUNKNOWN_CLASS) && ~isa(in,'categorical')
        try
            if ~isempty(meta.class.fromName(clazz))
                isNewStyleObject = true;
                isSystemObject = isa(in, 'matlab.system.SystemImpl');
            end
        catch err %#ok<NASGU>
        end
    end
end

if (type == com.mathworks.jmi.types.MLArrayRef.mxUNKNOWN_CLASS)
    try
        if ~isempty(meta.class.fromName(clazz))
            isNewStyleObject = true;
            isSystemObject = isa(in, 'matlab.system.SystemImpl');
        end
    catch err %#ok<NASGU>
    end
end
out = ValueMetaInfo(type, attributes, clazz, isNewStyleObject, isSystemObject, numOfDims, width, height);

%********************************************************************
function out = createReadOnlyValue(toReport) %#ok<INUSD>
out = com.mathworks.mlwidgets.array.data.ReadOnlyValue.valueOf(evalc('disp(toReport)'));

%********************************************************************
function type = getMLArrayRefClass(in, clazz)
%import com.mathworks.jmi.types.MLArrayRef;
if nargin == 1
    clazz = class(in);
end
% Use values instead of Java references as a small gain in performance
switch clazz
    case 'double'
        type = 6; %MLArrayRef.mxDOUBLE_CLASS;
    case 'single'
        type = 7; %MLArrayRef.mxSINGLE_CLASS;
    case 'uint8'
        type = 9; %MLArrayRef.mxUINT8_CLASS;
    case 'int8'
        type = 8; %MLArrayRef.mxINT8_CLASS;
    case 'uint16'
        type = 11; %MLArrayRef.mxUINT16_CLASS;
    case 'int16'
        type = 10; %MLArrayRef.mxINT16_CLASS;
    case 'uint32'
        type = 13; %MLArrayRef.mxUINT32_CLASS;
    case 'int32'
        type = 12; %MLArrayRef.mxINT32_CLASS;
    case 'uint64'
        type = 15; %MLArrayRef.mxUINT64_CLASS;
    case 'int64'
        type = 14; %MLArrayRef.mxINT64_CLASS;
    case 'logical'
        type = 3; %MLArrayRef.mxLOGICAL_CLASS;
    case 'cell'
        type = 1; %MLArrayRef.mxCELL_CLASS;
    case 'struct'
        type = 2; %MLArrayRef.mxSTRUCT_CLASS;
    case 'char'
        type = 4; %MLArrayRef.mxCHAR_CLASS;
    otherwise
        type = 0; %MLArrayRef.mxUNKNOWN_CLASS;
end

%********************************************************************
function out = reportNonexistentValueMetaInfo
out = com.mathworks.mlwidgets.array.ValueMetaInfo.getNonExistentInstance;

%********************************************************************
function attributes = getAttributes(in)
% This is the code we should run.  Instead, we run a hand-optimized
% version for performance.
%import com.mathworks.jmi.types.*;
%attributes = MLArrayRef.COMPLEX * (~isreal(in)) + ...
%    MLArrayRef.SPARSE * issparse(in);
if ~isreal(in)
    if issparse(in)
        attributes = 3;
    else
        attributes = 1;
    end
else
    if issparse(in)
        attributes = 2;
    else
        attributes = 0;
    end
end

function out = doHashedAssignment(var, rhs, key)
oldValue = var;
out = rhs;
storeValue(key, oldValue);

function out = undoHashedAssignment(key)
out = retrieveAndClearValue(key);

function out = doVDSAssignment(var, rhs, key)
oldValue = var;
out = rhs;
storeValue(key, oldValue);

function out = undoVDSAssignment(key)
out = retrieveAndClearValue(key);

function var = doMultiFieldAutoCopy(var, fieldNames)
for i = 1:length(fieldNames)
    var.(workspacefunc('getcopyname', fieldNames{i}, fields(var))) = ...
        var.(fieldNames{i});
end


%********************************************************************
function out = createCellArrayValue(workspaceID, in, varargin)
import com.mathworks.mlwidgets.array.data.CellArrayValue;
vds = javaArray('com.mathworks.mlwidgets.array.ValueDataSection', size(in));
optargin = size(varargin,2);
for i=1:size(in, 1)
    for j = 1:size(in, 2)
        thisIn = in{i, j};
        if ~istall(thisIn) && (numel(thisIn) < 11) && ndims(thisIn) <= 2
            if isstring(thisIn)
                thisIn = string(localReplaceNullCharacters(thisIn));
            end
            value = reportValues(workspaceID, '__cell__', thisIn, 1, 1, ...
                getVariableSize(thisIn, 1), getVariableSize(thisIn, 2), false);
            
            if (optargin > 1) 
                value.setUITableUsage(true);
            end
            
            vds(i, j) = value;
        else
            obj = workspacefunc('getshortvalueobjectj', thisIn, varargin{:});
            if ~isa(obj, 'com.mathworks.widgets.spreadsheet.data.ValueSummary')
                obj = char(obj.toString);
            end
            value = reportValues(workspaceID, '__cell__', obj, 1, 1, size(thisIn, 1), size(thisIn, 2), false);
            if (optargin > 1) 
                value.setUITableUsage(true);
            end
            vds(i, j) = value;
        end
    end

end
out = CellArrayValue.valueOf(vds);

%********************************************************************
function out = createNewObjectArrayValue(workspaceID, in, varargin)
import com.mathworks.mlwidgets.array.data.CellArrayValue;
sz = getVariableSize(in);
vds = javaArray('com.mathworks.mlwidgets.array.ValueDataSection', sz);
optargin = size(varargin,2);
for i=1:sz(1)
    for j = 1:sz(2)
        thisIn = in(i, j);
        if (numel(thisIn) < 11)
            value = reportValues(workspaceID, '__new__', thisIn, 1, 1, size(thisIn, 1), size(thisIn, 2), false);
            if (optargin > 1) 
                value.setUITableUsage(true);
            end
            vds(i, j) = value;
        else
            obj = workspacefunc('getshortvalueobjectj', thisIn, varargin{:});
            if ~isa(obj, 'com.mathworks.widgets.spreadsheet.data.ValueSummary')
                obj = char(obj.toString);
            end
            value = reportValues(workspaceID, '__new__', obj, 1, 1, size(thisIn, 1), size(thisIn, 2), false);
            if (optargin > 1) 
                value.setUITableUsage(true);
            end
            vds(i, j) = value;
        end
    end

end
out = CellArrayValue.valueOf(vds);

%********************************************************************
function out = createLegacyStructArrayValue(workspaceID, in)
import com.mathworks.mlwidgets.array.data.CellArrayValue;
vds = javaArray('com.mathworks.mlwidgets.array.ValueDataSection', size(in));
for i=1:size(in, 1)
    for j = 1:size(in, 2)
        thisIn = in(i, j);
        vds(i, j) = reportValues(workspaceID, '__struct__', in(i, j), 1, 1, size(thisIn, 1), size(thisIn, 2), false);
    end
end
out = CellArrayValue.valueOf(vds);


%********************************************************************
function out = valueStorage(behavior, key, value)
% behavior 1 = retrieveAndClearValue
% behavior 2 = store
% behavior 0 = getAllStorage
% behavior 3 = clearValueSafely
% behavior 4 = retrieveValue
persistent storage
switch (behavior)
    case 2
        if isempty (storage)
            storage.empty = [];
        end
        storage.(key) = value;
    case 1
        out = storage.(key);
        storage = rmfield(storage, key);
    case 0
        out = storage;
    case 3
        if isfield(storage, key)
            storage = rmfield(storage, key);
        end
    case 4
        out = storage.(key);
        
end

%********************************************************************
function ret = storeValue(key, value)
if ~isempty(key)
    valueStorage(2, key, value);
end
ret = [];

%********************************************************************
function out = retrieveAndClearValue(key)
out = valueStorage(1, key);

%********************************************************************
function out = retrieveValue(key)
out = valueStorage(4, key);

%********************************************************************
function clearValueSafely(key)
valueStorage(3, key);

%********************************************************************
function out = keyExists(key)
out = isfield(getAllStorage, key);

%********************************************************************
function out = getAllStorage
out = valueStorage(0);

%********************************************************************
function [whosInformation, propertyAttributes] = ...
    whosInformationForProperties(object, names, writablesBasedOnContext)
import com.mathworks.mlwidgets.workspace.*;
import com.mathworks.mlwidgets.array.mcos.*;

mc = metaclass(object);
metapropsArray = mc.Properties;
% Extract dynamic properties and append to metapropsArray
if any(strcmp(superclasses(object),'dynamicprops'))
    objPropertyList = properties(object);
    objDynPropList = setdiff(objPropertyList,cellfun(@(x) x.Name,metapropsArray,'UniformOutput',false));
    for i=1:length(objDynPropList)
        % dynamic props are handle classes. So it is safe to call findprop
        metaDynamicProp = findprop(object,objDynPropList{i});
        if isa(metaDynamicProp,'meta.DynamicProperty') 
            metapropsArray = [metapropsArray;{metaDynamicProp}];  %#ok<AGROW>
        end
    end
end

if isa(object, 'Simulink.SimulationOutput') || isa(object, 'Simulink.SimulationData.Dataset')
    metapropsArray = getPropsForSimulationOutput(object);
end

if isempty(metapropsArray) || isempty(names)
    whosInformation = WhosInformation.getInstance;
    propertyAttributes = PropertyAttributes.getInstance;
    return
end

filteredMPA = cell(size(names));
for i = 1:length(names)
    thisName = names(i);
    for j = 1:length(metapropsArray)
        if strcmp(thisName, metapropsArray{j}.Name)
            filteredMPA{i} = metapropsArray{j};
            break;
        end 
    end
end

sizes = cell(size(names));
bytes = zeros(size(names));
classes = cell(size(names));
isSparse = zeros(size(names));
isComplex = zeros(size(names));
nestingFunctions = cell(size(names));

getAccess = javaArray('com.mathworks.mlwidgets.array.mcos.Access', length(names));
setAccess = javaArray('com.mathworks.mlwidgets.array.mcos.Access', length(names));
constant = false(size(names));
transient = false(size(names));
dependent = false(size(names));
description = cell(size(names));
ddescription = cell(size(names));
virtualPropertyCell = false(size(names));

isVariableEditorPropertyProvider = isa(object,'internal.matlab.variableeditor.VariableEditorPropertyProvider');
values = cell(1,length(names));
for i = 1:length(names)
    thisMetaProp = filteredMPA{i};
    if isVariableEditorPropertyProvider && isVariableEditorVirtualProp(object,names{i})
        % If information on this property is provided by VariableEditorPropertyProvider
        % (i.e., the property is virtual), derive size, class, sparsity and
        % complexity information using the VariableEditorPropertyProvider 
        % to avoid direct access to the property.
        sizes{i} = int64(getVariableEditorSize(object,names{i}));     
        isSparse(i) = isVariableEditorSparseProp(object,names{i});
        isComplex(i) = isVariableEditorComplexProp(object,names{i});
        classes{i} = getVariableEditorClassProp(object,names{i});
        virtualPropertyCell(i) = true;
    else
        try
            values{i} = object.(names{i});
        catch
            values{i} = [];
        end
        thisVal = values{i};
        classes{i} = class(thisVal);
        sizes{i} = int64(getVariableSize(thisVal));
        isSparse(i) = issparse(thisVal);
        isComplex(i) = isnumeric(thisVal) && ~isreal(thisVal) && ~isobject(thisVal);
        virtualPropertyCell(i) = false;
    end
    
    nestingFunctions{i} = 'foo';
    
    getAccess(i) = getGetAccessForProperty(thisMetaProp);
    setAccess(i) = getSetAccessForProperty(thisMetaProp);
    constant(i) = thisMetaProp.Constant;
    transient(i) = thisMetaProp.Transient;
    dependent(i) = thisMetaProp.Dependent;
    description{i} = thisMetaProp.Description;
    ddescription{i} = thisMetaProp.DetailedDescription;
end

nestingLevels = ones(size(names));
nesting = NestingInformation.getInstances(nestingLevels, nestingFunctions);
isPersistent = zeros(size(names));
isGlobal = zeros(size(names));

whosInformation = WhosInformation(names, sizes, bytes, classes, ...
    isPersistent, isGlobal, isSparse, isComplex, nesting);
propertyAttributes = PropertyAttributes(names, getAccess, setAccess, ...
    constant, writablesBasedOnContext, transient, dependent, ...
    description, ddescription,virtualPropertyCell);

%********************************************************************
% Used to create a fake list of property attributes for SimulationOutput properties
function metapropsArray = getPropsForSimulationOutput(object)
    if numel(object) == 1
        propNames = [who(object); fieldnames(object)];
        metapropsArray = cell(size(propNames));
        for i = 1:length(propNames)
            propStruct.Hidden = false;
            propStruct.Name = propNames{i};
            propStruct.GetAccess = 'public';
            propStruct.SetAccess = 'private';
            propStruct.Dependent = false;
            propStruct.Constant = false;
            propStruct.Transient = false;
            propStruct.Description = '';
            propStruct.DetailedDescription = '';
            metapropsArray{i} = propStruct;
        end
    else
        propNames = {};
    end


%********************************************************************
function [names, writables, readables, virtuals] = getCurrentContextPropsAndPerms(object, ...
    classnameBeingDebugged)
% classnameBeingDebugged should come from running
% mfilename('class')
% in the context of the debugged function.

mc = metaclass(object);
if isempty(classnameBeingDebugged)
    currentContextHasPrivateAccess = false;
    currentContextHasProtectedAccess = false;
else
    currentContextHasPrivateAccess = strcmp(classnameBeingDebugged, mc.Name);
    currentContextHasProtectedAccess = currentContextHasPrivateAccess || ...
        meta.class.fromName(classnameBeingDebugged) < mc;
end

isVariableEditorPropertyProvider = isa(object,'internal.matlab.variableeditor.VariableEditorPropertyProvider');
metapropsArray = mc.Properties;
% Extract dynamic properties and append to metapropsArray
if(any(strcmp(superclasses(object),'dynamicprops')))
    objPropertyList = properties(object);
    objDynPropList = setdiff(objPropertyList,cellfun(@(x) x.Name,metapropsArray,'UniformOutput',false));
    for i=1:length(objDynPropList)
        % dynamic props are handle classes. So it is safe to call findprop
        metaDynamicProp = findprop(object,objDynPropList{i}); 
        if isa(metaDynamicProp,'meta.DynamicProperty')
            metapropsArray = [metapropsArray;{metaDynamicProp}]; %#ok<AGROW>
        end
    end
end

if isa(object, 'Simulink.SimulationOutput')
    metapropsArray = getPropsForSimulationOutput(object);
end

names = {};
writables = false(0);
readables = false(0);
virtuals = false(0);
for i = 1:length(metapropsArray)
    thisProp = metapropsArray{i};
    append = false;
    writable = false;
    readable = false;
    virtual = false;
    if ~thisProp.Hidden
        if currentContextHasPrivateAccess
            append = true;
            writable = setAccessAvailableToPrivate(thisProp);
            readable = getAccessAvailableToPrivate(thisProp);
        else
            % Property is readable because it is accessed
            % from the same class or a subclass and is public/protected get
            if currentContextHasProtectedAccess && getAccessAvailableToProtected(thisProp)
                append = true;
                % Property is writable because it is public/protected set or the 
                % class being debugged is on the property access list
                writable = setAccessAvailableToProtected(thisProp) || setAccessAvailableToListed(thisProp,classnameBeingDebugged);
                readable = true;
            % Property is readable because it is public get and
            % currentContextHasProtectedAccess is false
            elseif getAccessAvailableToPublic(thisProp, object)
                append = true;
                % Property is writable because it is public set or the 
                % class being debugged is on the property access list
                writable = setAccessAvailableToPublic(thisProp) || ...
                    setAccessAvailableToListed(thisProp,classnameBeingDebugged);
                readable = true;
            % Property is accessible because it is accessed from a class on
            % the access list
            elseif getAccessAvailableToListed(thisProp,classnameBeingDebugged)
                append = true;
                % Property is writable because it is public/protected set or the 
                % class being debugged is on the property access list
                writable = setAccessAvailableToListed(thisProp,classnameBeingDebugged) || (currentContextHasProtectedAccess && ...
                    setAccessAvailableToProtected(thisProp)) || setAccessAvailableToPublic(thisProp);
                readable = true;
            end
        end
        virtual = isVariableEditorPropertyProvider && isVariableEditorVirtualProp(object,thisProp.Name);
    end
    if append
        names{end+1} = thisProp.Name; %#ok<AGROW>
        writables(end+1) = writable; %#ok<AGROW>
        readables(end+1) = readable; %#ok<AGROW>
        virtuals(end+1) = virtual; %#ok<AGROW>
    end
    names = names';
    writables = writables';
    readables = readables';
    virtuals = virtuals';
end

%********************************************************************
function available = getAccessAvailableToPrivate(metaProperty)
available = true;
if metaProperty.Dependent
    available = ~isempty(metaProperty.GetMethod);
end

%********************************************************************
function data = getSimulinkDatasetView (object)
if isa(object, 'Simulink.SimulationData.Dataset') && numel(object) == 1
    n = object.numElements();
    data = cell(n,1);
    names = object.getElementNames();
    for idx = 1:n
        data{idx} = cell(5,1);
        data{idx}{1} = idx;

        val = object{idx};

        if numel(val) > 0 && isa(val, 'timetable')
            str = sprintf('%dx%d', length(val.Properties.RowTimes), ...
                length(val.Properties.VariableNames));
            classSplits = split(class(val), '.');
            data{idx}{2} = sprintf('%s %s', str, classSplits{end});
        else
            str = sprintf('%dx', size(val));
            classSplits = split(class(val), '.');
            data{idx}{2} = sprintf('%s %s', str(1:end-1), classSplits{end});
            end
 
        data{idx}{3} = names{idx};
        if isa(val, 'Simulink.SimulationData.BlockData')
            data{idx}{4} = strjoin(val.BlockPath.convertToCell(), '|');
            classStr = class(val.Values);
        else
            data{idx}{4} = '';
        end

        data{idx}{5} = class(val);
    end
else
    data = {};
end

function str = locGetArrayStr(val)
    if (isempty(val) && isa(val, 'double'))
        str = '[]';
    else
    str = sprintf('%dx', size(val));
    str = sprintf('[%s %s]', str(1:end-1), class(val));
    end

%********************************************************************
function data = getSimulinkSimOutMetadata(object)
    data = {numel(object) == 1, getSimulinkMetadataFields(object)};

%********************************************************************
function data = getSimulinkMetadataFields(object, name)
if nargin == 1
    name = '';
end
if isa(object, 'Simulink.SimulationOutput')
    if numel(object) == 1
    metadata = object.getSimulationMetadata();
    else 
        metadata = [];
    end
    if isa(metadata, 'Simulink.SimulationMetadata')
        objFields = fieldnames(metadata);
        nFields = numel(objFields);
        data = cell(1,nFields);
        for idx = 1:nFields
            data{idx} = getSimulinkMetadataFields(metadata.(objFields{idx}), objFields{idx});
        end
    else 
        data = [];
    end
    return;
end

data = cell(1,4);
data{1} = name;
data{3} = class(object);
if ischar(object) 
    data{2} = slprivate('removeHyperLinksFromMessage', object);
    data{4} = [];
    return;
elseif isnumeric(object)
    if isscalar(object)
        data{2} = num2str(object);
        data{4} = [];
        return;
    else 
        n = numel(object);
        data{2} = locGetArrayStr(object);
        data{4} = cell(n, 1);
        for idx = 1:n
            data{4}{idx} = {num2str(idx), num2str(object(idx)), class(object), []};
        end
        return;
    end
elseif (isa(object, 'Simulink.SimulationMetadata') || isstruct(object) || ...
        isa(object, 'MSLDiagnostic')) %&& ...
        %numel(object) > 0
    n = numel(object);
    if (n == 1)
        objFields = fieldnames(object);
        nFields = numel(objFields);
        data{2} = ''; %locGetArrayStr(object);
        data{4} = cell(nFields, 1);
        for idx = 1:nFields
            data{4}{idx} = getSimulinkMetadataFields(object.(objFields{idx}), objFields{idx});
        end
        return
    elseif n ~= 0
        data{2} = locGetArrayStr(object);
        data{4} = cell(n, 1);
        for idx = 1:n
            data{4}{idx} = getSimulinkMetadataFields(object(idx), num2str(idx));
        end
        return;
        
    else
        data{2} = locGetArrayStr(object);
        data{4} = [];
        return;
    end
    %data{2} = locGetArrayStr(object);
    %data{4} = [];
elseif iscell(object)
    n = numel(object);
    data{2} = locGetArrayStr(object);
    data{4} = cell(n, 1);
    for idx = 1:n
        data{4}{idx} = getSimulinkMetadataFields(object{idx}, num2str(idx));
    end
    return;
end


%********************************************************************
function available = getAccessAvailableToProtected(metaProperty)
available = ~strcmp(metaProperty.GetAccess, 'private');
if available && metaProperty.Dependent
    available = ~isempty(metaProperty.GetMethod);
end

%********************************************************************
function available = getAccessAvailableToPublic(metaProperty, object)
available = strcmp(metaProperty.GetAccess, 'public');
% Consolidated fix for g881347 && g1015277
if all(available) && metaProperty.Dependent
    if isempty(metaProperty.GetMethod)
        isVariableEditorPropertyProvider = isa(object,'internal.matlab.variableeditor.VariableEditorPropertyProvider');
        virtual = isVariableEditorPropertyProvider && isVariableEditorVirtualProp(object,metaProperty.Name);
        if ~virtual
            try
                object.(metaProperty.Name);
            catch
                available = false;
            end
        end
    else
        available = true;
    end
end


%********************************************************************
function available = setAccessAvailableToPrivate(metaProperty)
available = ~metaProperty.Dependent;

%********************************************************************
function available = setAccessAvailableToProtected(metaProperty)

available = ischar(metaProperty.SetAccess) && ~strcmp(metaProperty.SetAccess, 'private') && ...
    ~metaProperty.Dependent;

function available = setAccessAvailableToPublic(metaProperty)

available = ischar(metaProperty.SetAccess) && strcmp(metaProperty.SetAccess, 'public') && ...
    ~metaProperty.Dependent;

function available = setAccessAvailableToListed(metaProperty,classnameBeingDebugged)

if metaProperty.Dependent || isempty(classnameBeingDebugged)
    available = false;
    return
end
if iscell(metaProperty.SetAccess)  
    classBeingDebugged = meta.class.fromName(classnameBeingDebugged);
    available = any(cellfun(@(x) isa(x,'meta.class') && x<=classBeingDebugged,metaProperty.SetAccess));
elseif isa(metaProperty.SetAccess,'meta.class')
    classBeingDebugged = meta.class.fromName(classnameBeingDebugged);
    available = (classBeingDebugged<=metaProperty.SetAccess); 
else
    available = false;
end

function available = getAccessAvailableToListed(metaProperty,classnameBeingDebugged)

if isempty(classnameBeingDebugged)
    available = false;
    return
end
if iscell(metaProperty.GetAccess)  
    classBeingDebugged = meta.class.fromName(classnameBeingDebugged);
    available = any(cellfun(@(x) isa(x,'meta.class') && x<=classBeingDebugged,metaProperty.GetAccess));
elseif isa(metaProperty.GetAccess,'meta.class')
    classBeingDebugged = meta.class.fromName(classnameBeingDebugged);
    available = (classBeingDebugged<=metaProperty.GetAccess); 
else
    available = false;
end


%********************************************************************
function access = getGetAccessForProperty(propertyMetaInfo)
import com.mathworks.mlwidgets.array.mcos.Access;

if isa(propertyMetaInfo.GetAccess,'meta.class') || (iscell(propertyMetaInfo.GetAccess) && ...
        all(cellfun('isclass',propertyMetaInfo.GetAccess,'meta.class')))
    access = Access.ACCESSLIST;
    return
end
switch propertyMetaInfo.GetAccess
    case 'public'
        access = Access.PUBLIC;
    case 'protected'
        access = Access.PROTECTED;
    otherwise
        access = Access.PRIVATE;
end

%********************************************************************
function access = getSetAccessForProperty(propertyMetaInfo)
import com.mathworks.mlwidgets.array.mcos.Access;
if isa(propertyMetaInfo.SetAccess,'meta.class') || (iscell(propertyMetaInfo.SetAccess) && ...
        all(cellfun('isclass',propertyMetaInfo.SetAccess,'meta.class')))
    access = Access.ACCESSLIST;
    return
end
if ischar(propertyMetaInfo.SetAccess)
    switch propertyMetaInfo.SetAccess
        case 'public'
            access = Access.PUBLIC;
        case 'protected'
            access = Access.PROTECTED;
        otherwise
            access = Access.PRIVATE;
    end
else 
    % This should not happen as cell array values of SetAccess should
    % all be meta.class. Assume that exceptions to this are private
    access = Access.PRIVATE;
end

%********************************************************************
function out = structToWhosInformation(object)
import com.mathworks.mlwidgets.workspace.*;

names = fields(object);
if isempty(names)
    out = com.mathworks.mlwidgets.workspace.WhosInformation.getInstance;
    return
end
sizes = cell(size(names));
bytes = zeros(size(names));
classes = cell(size(names));
isSparse = zeros(size(names));
isComplex = zeros(size(names));
nestingFunctions = cell(size(names));
for i = 1:length(names)
    thisVal = object.(names{i});
    sizes{i} = int64(getVariableSize(thisVal));
    classes{i} = class(thisVal);
    isSparse(i) = issparse(thisVal);
    isComplex(i) = isnumeric(thisVal) && ~isreal(thisVal) && ~isobject(thisVal);
    nestingFunctions{i} = 'foo';
end
nestingLevels = ones(size(names));
nesting = NestingInformation.getInstances(nestingLevels, nestingFunctions);
isPersistent = zeros(size(names));
isGlobal = zeros(size(names));

out = WhosInformation(names, sizes, bytes, classes, isPersistent, isGlobal, isSparse, isComplex, nesting);

%********************************************************************
function out = getUnsupportedString(varargin) 

tooLargeMessage = varargin{1}; %#ok<NASGU>
cannotReferenceMessage = varargin{2}; %#ok<NASGU>
maxElements = varargin{3};

% If no value argument is passed in return nothing
if nargin >= 4
    val = varargin{4};
else
    out = '';
    return;
end

if isa(val, 'tall')
    % Special treatment for tall variables, so that the contents shows up
    % better than it would be default, since the unsupported view strips
    % lines with hyperlinks in it.
    out = evalc(['oldVal = feature(''hotlinks'', false);', ...
        'restore = onCleanup(@() feature(''hotlinks'', oldVal));', ...
        'display(val)']);

    % Remove hyperlinks so that the Nx1 tall column vector string shows
    % up
    out = regexprep(out, '<.*?>', '');   
elseif (size(varargin,2) > 4)  
    out = evalc('disp(char(cannotReferenceMessage))');
elseif numel(val) > maxElements || length(size(val)) > maxElements
    % Either there are too many elements, or too many dimentions to try to
    % display in the Variable Editor
    out = evalc('disp(char(tooLargeMessage))');
else
    out = evalc('display(val)');
    out = strrep(strrep(out, '<strong>', ''), '</strong>', '');
end

function vds = createStructArrayValue(workspaceID, in, startColumn)

import com.mathworks.mlwidgets.array.data.*;
import com.mathworks.widgets.spreadsheet.data.*;

vds = com.mathworks.mlwidgets.array.data.StructArrayValue;

columnIndex = startColumn;
fieldNames = fieldnames(in);

% Loop through each field, creating java representations for the
% content of each variable.  This is similar to the dataset variables.
for varIndex = 1:length(fieldNames)
    
    % Create a cell array with the data for the field
    varData = {in.(fieldNames{varIndex})};
    varData = varData(:);
    
    ca = [];
    try
        allNumeric = ~any(cellfun(@isempty, varData)) && ...
            all(all(cellfun(@isnumeric, varData)) | all(cellfun(@islogical, varData))) && ...
            all(cellfun(@isscalar, varData));
        allString = all(cellfun(@localIsString, varData));
        if allNumeric && ~isempty(varData)
            % All cells contain numeric data.  Need to prevent any empty cells
            % from falling into this condition, even if within a numeric array.
            % This is because when we collapse the empty cells into a numeric
            % array below, they are dropped, and then the data becomes out of
            % sync with the rows.
            
            % Also need to make sure all numeric data is the same class.
            % We need to avoid inadvertantly casting numeric data of
            % different classes (for example uint8 and int16) by putting
            % them all in the same array.
            c = cellfun(@class, varData, 'UniformOutput', false);
            if all(string(c) == string(c{1}))
                
                numericVarData = [in.(fieldNames{varIndex})].';
                
                signed = ~dataviewerhelper('isUnsignedIntegralType', numericVarData);
                if isreal(numericVarData)
                    if isscalar(numericVarData)
                        if isfloat(numericVarData)
                            ca = ComplexScalarFactory.valueOf(numericVarData);
                        elseif isinteger(numericVarData)
                            ca = ComplexScalarFactory.valueOf(dataviewerhelper('upconvertIntegralType', numericVarData), signed);
                        else
                            ca = ComplexScalarFactory.valueOf(double(numericVarData));
                        end
                    else
                        if isfloat(numericVarData)
                            ca = ComplexArrayFactory.valueOf(numericVarData);
                        elseif isinteger(numericVarData)
                            ca = ComplexArrayFactory.valueOf(dataviewerhelper('upconvertIntegralType', numericVarData), signed);
                        else
                            ca = ComplexArrayFactory.valueOf(double(numericVarData));
                        end
                    end
                else
                    if isscalar(numericVarData)
                        if isfloat(numericVarData)
                            ca = ComplexScalarFactory.valueOf(real(numericVarData),imag(numericVarData));
                        elseif isinteger(numericVarData)
                            converted = dataviewerhelper('upconvertIntegralType', numericVarData);
                            ca = ComplexScalarFactory.valueOf(real(converted),imag(converted),signed);
                        else
                            ca = ComplexScalarFactory.valueOf(real(double(numericVarData)),imag(double(numericVarData)));
                        end
                    else
                        if isfloat(numericVarData)
                            ca = ComplexArrayFactory.valueOf(real(numericVarData),imag(numericVarData));
                        elseif isinteger(numericVarData)
                            converted = dataviewerhelper('upconvertIntegralType', numericVarData);
                            ca = ComplexArrayFactory.valueOf(real(converted),image(converted),signed);
                        else
                            ca = ComplexArrayFactory.valueOf(real(double(numericVarData)),imag(double(numericVarData)));
                        end
                    end
                end
            end
        elseif allString && ~isempty(varData) && all(cellfun(@isscalar, varData))
            missing = cellfun(@ismissing, varData);
            varData(missing) = {'<missing>'};
            varData = cellfun(@localReplaceNullCharacters, varData, 'UniformOutput', false);
            ca = com.mathworks.mlwidgets.array.data.StringArray.valueOf(cellstr(varData), missing);
        end
    catch
    end
    
    if isempty(ca)
        ca = javaArray('com.mathworks.mlwidgets.array.ValueDataSection',size(varData));
        for i=1:size(varData, 1)
            for j = 1:size(varData, 2)
                thisIn = varData{i, j};
                if localIsString(thisIn) && isscalar(thisIn) && (strlength(thisIn) < 11)
                    if ismissing(thisIn)
                        strValue = com.mathworks.mlwidgets.array.data.StringArray.valueOf({'<missing>'}, true);
                    else
                        strValue = com.mathworks.mlwidgets.array.data.StringArray.valueOf(cellstr(thisIn));
                    end
                    variable = com.mathworks.mlservices.WorkspaceVariable('__cell__', workspaceID);
                    vdsection = com.mathworks.mlwidgets.array.ValueDataSection(variable, 0, 0, 0, 0, strValue);
                    ca(i, j) = vdsection;
                elseif ~istall(thisIn) && (ischar(thisIn) || (numel(thisIn) < 11 && ndims(thisIn) <= 2))
                    sz = getVariableSize(thisIn);
                    if sz(2) < getTextTruncationLength
                        value = reportValues(workspaceID, '__cell__', thisIn, 1, 1, ...
                            sz(1), sz(2), false);
                    else
                        % Replace special characters so the text will go through normal
                        % processing for Variable Editor display (otherwise it may be
                        % truncated to 1xN char, while useful elsewhere, it isn't
                        % desirable for the Variable Editor display)
                        toReport = strrep(strrep(strrep(thisIn, newline, ''), char(13), ''), char(0), ' ');
 
                        % Truncate to a reasonable size
                        obj = workspacefunc('getshortvalueobjectj', toReport, true, getTextTruncationLength);
                        if ~isa(obj, 'com.mathworks.widgets.spreadsheet.data.ValueSummary')
                            value = strrep(char(obj.toString), '''', '');
                        else
                            value = obj;
                        end
                        variable = com.mathworks.mlservices.WorkspaceVariable('__cell__', workspaceID);
                        value = com.mathworks.mlwidgets.array.ValueDataSection(variable, 0, 0, 0, 0, value);
                        
                    end
                    ca(i, j) = value;
                else
                    obj = workspacefunc('getshortvalueobjectj', thisIn);
                    if ~isa(obj, 'com.mathworks.widgets.spreadsheet.data.ValueSummary')
                        obj = char(obj.toString);
                    end
                    value = reportValues(workspaceID, '__cell__', obj, 1, 1, size(thisIn, 1), size(thisIn, 2), false);
                    ca(i, j) = value;
                end
            end
        end
        ca = CellArrayValue.valueOf(ca);
    end
    vds.addVariable(ca,columnIndex-1);
    columnIndex = columnIndex+size(varData,2);
end

function vds = createTabularObjectValue(workspaceID, in, completeDataset)


import com.mathworks.mlwidgets.array.data.*;
import com.mathworks.widgets.spreadsheet.data.*;

vds = com.mathworks.mlwidgets.array.data.DatasetArrayValue;

% Set start columns indexes of each Var - and use this info for sending the vardata object to Java
%
% [in] - a fraction of the complete dataset, shown on the current page 
% [completeDataset] - is used in order to know what are the start indexes of
% each one of the Vars in the fraction [in], in order to report to Java,
% otherwise there is no way to know what is the starting point of Var,
% especially for Vars having grouped colums  (g915386)


startColumnIndexes = getDatasetColumnIndices(completeDataset)-1; % -1 zero based indexes
datasetProperties = in.Properties; % Avoid repeated sub-indexing

if (isempty(in))
   return; 
end

% Loop through each dataset variable, creating java representations for the
% content of each variable

for varIndex = 1:size(in, 2)
    if isa(in,'dataset')
        varName = in.Properties.VarNames(varIndex);
        varData = in.(datasetProperties.VarNames{varIndex});
    else
        varName = in.Properties.VariableNames(varIndex);
        varData = in.(datasetProperties.VariableNames{varIndex});
    end
    if (isnumeric(varData) || islogical(varData)) && ~isobject(varData)
        signed = ~dataviewerhelper('isUnsignedIntegralType', varData);
        if isreal(varData)
            if isscalar(varData)
                if isfloat(varData)
                    ca = ComplexScalarFactory.valueOf(varData);
                elseif isinteger(varData)
                    ca = ComplexScalarFactory.valueOf(dataviewerhelper('upconvertIntegralType', varData), signed);
                else
                    ca = ComplexScalarFactory.valueOf(double(varData));
                end
            else
                if isfloat(varData)
                    ca = ComplexArrayFactory.valueOf(varData);
                elseif isinteger(varData)
                    ca = ComplexArrayFactory.valueOf(dataviewerhelper('upconvertIntegralType', varData), signed);
                else
                    ca = ComplexArrayFactory.valueOf(double(varData));
                end
            end  
        else
            if isscalar(varData)
                if isfloat(varData)
                    ca = ComplexScalarFactory.valueOf(real(varData),imag(varData));
                elseif isinteger(varData)
                    converted = dataviewerhelper('upconvertIntegralType', varData);
                    ca = ComplexScalarFactory.valueOf(real(converted),imag(converted),signed);
                else
                    ca = ComplexScalarFactory.valueOf(real(double(varData)),imag(double(varData)));
                end
            else
                if isfloat(varData)
                    ca = ComplexArrayFactory.valueOf(real(varData),imag(varData));
                elseif isinteger(varData)
                    converted = dataviewerhelper('upconvertIntegralType', varData);
                    ca = ComplexArrayFactory.valueOf(real(converted),imag(converted),signed);
                else
                    ca = ComplexArrayFactory.valueOf(real(double(varData)),imag(double(varData)));
                end
            end  
        end
    elseif isa(varData,'categorical')
        cats = getCategories(varData);
        ca = com.mathworks.mlwidgets.array.data.CategoricalArray.valueOf(cellstr(varData),...
            cats);
    elseif isa(varData, 'datetime') || isa(varData, 'duration') || ...
            isa(varData, 'calendarDuration')
        ca = com.mathworks.mlwidgets.array.data.DatetimeArray.valueOf(cellstr(varData));
    elseif iscellstr(varData)
        % Replace any char(0) with ' ' so the rest of the string will be
        % displayed, like on the command line.
        try
            varData = cellfun(@localReplaceNullCharacters, varData, 'UniformOutput', false);
        catch
        end
        ca = CellStrValue.valueOf(varData); 
    elseif localIsString(varData)
        missing = ismissing(varData);
        varData(missing) = {'<missing>'};       
        varData = getStringColumnVal(varData);
        ca = com.mathworks.mlwidgets.array.data.StringArray.valueOf(cellstr(varData), missing);
    elseif ischar(varData) 
        if size(varData,2) < getTextTruncationLength
            % Replace any char(0) with ' ' so the rest of the string will be
            % displayed, like on the command line.
            if size(varData, 1) == 1
                varData = localReplaceNullCharacters(varData);
            end
            ca = CharArrayValue.valueOf(varData);
        else
            newVarData = [];
            for i=1:size(varData, 1)
                if i==1 && isequal(size(varData),[1 1])
                    thisIn = varData;
                else
                    thisIn = varData(i,:);
                end
                
                % Replace special characters so the text will go through normal
                % processing for Variable Editor display (otherwise it may be
                % truncated to 1xN char, while useful elsewhere, it isn't
                % desirable for the Variable Editor display
                thisIn = strrep(strrep(strrep(thisIn, newline, ''), char(13), ''), char(0), ' ');
                
                obj = workspacefunc('getshortvalueobjectj', thisIn, true, getTextTruncationLength);
                obj = strrep(char(obj.toString), '''', '');
                
                if isempty(newVarData)
                    newVarData = obj;
                else
                    newVarData = char(newVarData, obj);
                end
            end
            ca = CharArrayValue.valueOf(newVarData);
        end
    elseif iscell(varData)
        ca = javaArray('com.mathworks.mlwidgets.array.ValueDataSection',size(varData));
        for i=1:size(varData, 1)
            for j = 1:size(varData, 2)
                thisIn = varData{i, j};
                % Don't use getshortvalueobjectj for strings because it 
                % creates preview text for more than 128 chars which
                % prevents the entire string being edited.
                if ischar(thisIn) || (numel(thisIn) < 11 && ndims(thisIn) <= 2)
                    value = reportValues(workspaceID, '__cell__', thisIn, 1, 1, size(thisIn, 1), size(thisIn, 2), false);
                    ca(i, j) = value;
                else
                    obj = workspacefunc('getshortvalueobjectj', thisIn, false);
                    if ~isa(obj, 'com.mathworks.widgets.spreadsheet.data.ValueSummary')
                        obj = char(obj.toString);
                    end
                    value = reportValues(workspaceID, '__cell__', obj, 1, 1, size(thisIn, 1), size(thisIn, 2), false);
                    ca(i, j) = value;
                end
            end
        end
        ca = CellArrayValue.valueOf(ca);
    elseif istable(varData)
        ca = javaArray('com.mathworks.mlwidgets.array.ValueDataSection',size(varData));
        for i=1:size(varData, 1)
            if i==1 && isequal(size(varData),[1 1])
                thisIn = varData;
            else
                thisIn = varData(i, :);
            end
            
            % Create summary representation for table with correct size
            obj = com.mathworks.widgets.spreadsheet.data.ValueSummaryFactory.getInstance(...
                class(thisIn), size(thisIn));
            value = reportValues(workspaceID, '__table__', obj, 1, 1, ...
                getVariableSize(thisIn, 1), getVariableSize(thisIn, 2), false);
            ca(i, 1) = value;
        end
        ca = CellArrayValue.valueOf(ca);
    else 
        % For other arrays, create a ValueDataSection comprising
        % mlwidgets.array.data.ReadOnlyValues for structs and objects
        ca = javaArray('com.mathworks.mlwidgets.array.ValueDataSection',size(varData));
        for i=1:size(varData, 1)
            for j = 1:size(varData, 2)
                if i==1 && j==1 && isequal(size(varData),[1 1])
                    thisIn = varData;
                else
                    thisIn = varData(i, j);
                end
                obj = workspacefunc('getshortvalueobjectj', thisIn);
                if ~isa(obj, 'com.mathworks.widgets.spreadsheet.data.ValueSummary')
                     obj = char(obj.toString);
                end
                value = reportValues(workspaceID, '__unknown__', obj, 1, 1, ...
                    getVariableSize(thisIn, 1), getVariableSize(thisIn, 2), false);
                ca(i, j) = value;
            end
        end
        ca = CellArrayValue.valueOf(ca);
    end   
    
    
    % getting the corresponding column start index in the dataset  
   if isa(in,'dataset')
        indexInDataset = ismember(completeDataset.Properties.VarNames,varName);
    else
        indexInDataset = ismember(completeDataset.Properties.VariableNames,varName);
    end
    
   % add a newly created Java object with zero based indexes
    columnIndex = startColumnIndexes(1,indexInDataset);
    vds.addVariable(ca,columnIndex);
    
end

function vds = createCategoricalArrayValue(in, startColumn)


import com.mathworks.mlwidgets.array.data.*;
import com.mathworks.widgets.spreadsheet.data.*;

com.mathworks.mlwidgets.array.data.CategoricalScalar.setUndefinedString(categorical.undefLabel);
vds = com.mathworks.mlwidgets.array.data.DatasetArrayValue;
startIndex = startColumn-1;

% Loop through each dataset variable, creating java representations for the
% content of each variable
for col = 1:size(in, 2)
    cats = getCategories(in(:,col));
    ca = com.mathworks.mlwidgets.array.data.CategoricalArray.valueOf(cellstr(in(:,col)), cats);
    vds.addVariable(ca,(col-1)+startIndex);
end

function cats = getCategories(in)
    if isa(in, 'nominal') || isa(in, 'ordinal')
        cats = getlabels(in);
    else
        cats = categories(in);
    end
    
    % Limit the number of categories to what can be displayed in a
    % dropdown menu in Java.  Currently, it displays up to 25000 menu
    % items, plus undefined, so only send over this many.  Any more
    % will be unused, and effects performance.
    cats(25002:end) = [];

function vds = createDatetimeArrayValue(in, startColumn)
import com.mathworks.mlwidgets.array.data.*;
import com.mathworks.widgets.spreadsheet.data.*;

vds = com.mathworks.mlwidgets.array.data.DatetimeArrayValue;
startIndex = startColumn-1;

% Loop through each datetime variable, creating java representations for the
% content of each variable
for col = 1:size(in, 2)
    ca = com.mathworks.mlwidgets.array.data.DatetimeArray.valueOf(...
        cellstr(in(:, col)));
    vds.addVariable(ca,(col-1)+startIndex);
end

function vds = createStringArrayValue(in, startColumn)
import com.mathworks.mlwidgets.array.data.*;
import com.mathworks.widgets.spreadsheet.data.*;

vds = com.mathworks.mlwidgets.array.data.StringArrayValue;
startIndex = startColumn-1;

% Loop through each string variable, creating java representations for
% the content of each variable
for col = 1:size(in, 2)
    
    % Replace any missing strings with <missing>.
    missing = ismissing(in(:, col));
    in(missing, col) = {'<missing>'};

    val = in(:, col);
    val = getStringColumnVal(val);

    ca = com.mathworks.mlwidgets.array.data.StringArray.valueOf(...
        val, missing);
    vds.addVariable(ca, (col-1)+startIndex);
end

%********************************************************************

function val = getStringColumnVal(val)
    try
        val = arrayfun(@localReplaceNullCharacters, val, 'UniformOutput', false);
        if isequal(size(val), [1,1])
            val = val{:};
            val = string(val);
        elseif iscellstr(val)
            val = string(val);
        else
            val = [val{:}]';
        end
    catch
    end

%********************************************************************
function [nameForAssign,toReport] = ...
    reportDatasetValuesLogic(nameForAssign,value, startRow, startColumn, endRow, endColumn)

% Version of reportDatasetValuesLogic for dataset arrays. The key 
% difference is that the start and end columns must be converted to dataset
% variable indices before subreferencing

import com.mathworks.mlwidgets.array.data.FunctionHandleValue;
if nargin < 3
    startRow = 1;
end
if nargin < 4
    startColumn = 1;
end
if nargin < 5
    endRow = -1; %Patch it up below.
end
if nargin < 6
    endColumn = -1; %Patch it up below.
end

s = size(value);

trueEndRow = s(1);
if (endRow == -1) 
    endRow = trueEndRow;
else
    endRow = min(endRow, trueEndRow);
end

% Convert column to dataset variable indices
columnIndices = getDatasetColumnIndices(value);
trueEndIndex = s(2);
if (endColumn == -1)
    endIndex = s(2);
else
    endIndex = find(columnIndices<=endColumn,1,'last');
    endIndex = min(endIndex,trueEndIndex);
end
startIndex = find(columnIndices<=startColumn,1,'last');
if startRow > endRow
    startRow = endRow;
end
if startIndex > endIndex
    startIndex = endIndex;
end

% We needed to get all of the values calculated so far strictly correct,
% even for the "empty" cases.  But we do NOT need a correct value of
% toReport for the "empty" cases, so we short-circuit the full-blown
% calculations and simply return [].
if endRow == 0 || endColumn == 0 || isempty(value)
    toReport = value;
 elseif startRow==endRow && startRow==1 && startIndex==endIndex && endIndex==1 && isequal([1,1] , size(value))
    toReport = value;
else
    toReport = value(startRow:endRow, startIndex:endIndex);
end


%********************************************************************

function [toReport, startRow, startColumn] = ...
    reportStructArrayValuesLogic(value, startRow, startColumn, endRow, endColumn, ~) 

% Version of reportValuesLogic for struct arrays.  Note that all fields are
% currently reported (start/end column is not taken into account).
if nargin < 2
    startRow = 1;
end
if nargin < 3
    startColumn = 1; 
end
if nargin < 4
    endRow = -1; %Patch it up below.
end
if nargin < 5
    endColumn = -1; %Patch it up below.
end

s = size(value);

if (s(1) == 1)
    trueEndRow = s(2);
else
    trueEndRow = s(1);
end

if (endRow == -1)
    endRow = trueEndRow;
else
    endRow = min(endRow, trueEndRow);
end

if endRow == 0 || endColumn == 0 || isempty(value)
    toReport = value;
else
    toReport = value(startRow:endRow);
    f = fieldnames(value);
    if endColumn-startColumn < length(f)
        % If the struct array contains more fields than are in a block
        % of data that we are paging, remove the excess fields
        m = true(1, length(f));
        m(startColumn:endColumn) = false;
        toReport = rmfield(toReport, f(m, 1));
    end
end
% end

%********************************************************************
function out = getTranspose(var)
    out = ctranspose(var);

%********************************************************************
function out = getSortRows(var, cols)
    out = sortrows(var, cols);

%********************************************************************
function intervals = getSelectionIntervals(var, selectionString, dimension)

% Convert selectionString into an nx2 array of intervals where n is the
% number of distinct intervals and the first column is start positions and
% the second end positions.

if strcmp('rows',dimension)
    ind = 1:size(var,1);
else
    if ischar(var) % char arrays are always displayed in an nx1 array (g872913)
       ind = 1;
    else
       ind = 1:size(var,2);
    end
end

if ~strcmp(':', selectionString)
    eval(['ind = ind([' selectionString ']);']);
end

% Fast short circuit for contiguous intervals
if ind(end)-ind(1)+1==length(ind)
     intervals = [ind(1) ind(end)];
     return
end

intervals = [ind(diff([-1 ind])>=2)' ind(diff([ind inf])>=2)'];

function cleaner = getCleanupHandler(swl)
cleaner = onCleanup(@(~,~) com.mathworks.mlwidgets.workspace.MatlabWorkspaceListener.swl(swl));

function showError(whichcall, e)
msg = e.message;
stack = e.stack;
[~,file] = fileparts(stack(1).file);
line = num2str(stack(1).line);
com.mathworks.mlwidgets.array.ArrayDialog.showErrorDialog([whichcall 10 msg 10 file 10 line])

function displayErrorDialog
msg = com.mathworks.mlwidgets.array.ArrayUtils.getResource('alert.PasteGeneralIncompatability');
com.mathworks.mlwidgets.array.ArrayDialog.showErrorDialog(msg);

function startColumnIndexes = getDatasetColumnIndices(dataArray)

% Create temp table/dataset with only the first row, thats all we need to
% check the columns, this helps speed up the query g967725
if ~isempty(dataArray) && size(dataArray,1)>1
    tdataArray = dataArray(1,:);
else
    tdataArray = dataArray;
end

if isa(dataArray,'dataset')
    startColumnIndexes = cumsum([1 datasetfun(@(x) getVariableSize(x,2)*ismatrix(x)*~ischar(x)*~isa(x,'dataset')*~matlab.internal.datatypes.istabular(x)...
        +ischar(x)+isa(x,'dataset')+matlab.internal.datatypes.istabular(x), ...
          tdataArray)]);
else
    startColumnIndexes = cumsum([1 varfun(@(x) getVariableSize(x,2)*ismatrix(x)*~ischar(x)*~isa(x,'dataset')*~matlab.internal.datatypes.istabular(x)...
        +ischar(x)+isa(x,'dataset')+matlab.internal.datatypes.istabular(x), ...
        tdataArray,'OutputFormat','uniform')]);
end

function varSize = getVariableSize(value, varargin)
% Returns the size of the variable. Handles objects which may have a scalar
% size (like Java collection objects), or objects which may not have a
% numeric size.
if isa(value, 'tall') 
    w = whos('value');
    varSize = w.size;
else
    try
        varSize = size(value);
    catch
        % Assume a size of 1x1 for objects which error on size
        varSize = [1 1];
    end
    if numel(varSize) == 1
        if isnumeric(varSize)
            % Handle objects which may have a scalar size (like Java objects)
            % The rows is the size of the object, and the columns is set to 1.
            varSize = [varSize 1];
        else
            % Assume a size of 1,1
            varSize = [1 1];
        end
    end
end

if nargin == 2
    dimension = varargin{1};
    varSize = varSize(dimension);
end

function [height, width] = resolveVariableSize(value, varSize)
    % Resolve the variable size. Check for any classes which have a size
    % greater than [1,1], but report the number of elements as 1, and treat
    % them as being scalar objects.  (Assumes varSize is correct already
    % for tall variables)
    height = varSize(1);
    width = varSize(2);
    if ~isa(value, 'tall')
        if ((height > 1 || width > 1) && (numel(value) == 1) && isobject(value))
            height = 1;
            width = 1;
        end
    end

%********************************************************************
function s = localIsString(var)
    % Guard against objects which have their own isstring methods
    try
        s = isstring(var);
        if ~islogical(s) || isempty(s)
            s = false;
        end
    catch
        s = false;
    end

%********************************************************************
function b = localIsEmpty(var)
    % Guard against objects which have their own isempty methods
    try
        b = isempty(var);
        if ~islogical(b) || isempty(b)
            b = false;
        end
    catch
        b = false;
    end

