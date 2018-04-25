function varargout = workspacefunc(whichcall, varargin)
%WORKSPACEFUNC  Support function for Workspace browser component.

% Copyright 1984-2017 The MathWorks, Inc.

% make sure this function does not clear
mlock 

persistent defaultWorkspaceID simulinkLoaded lastUpdate
if isempty(defaultWorkspaceID)
    defaultWorkspaceID = getDefaultWorkspaceID;
end
if isempty(simulinkLoaded)
    simulinkLoaded = false;
end

% throttle workspace updates if any simulations are running
% let the first one go then reset the long delay after the 
% next event.  Before testing for a running simulation, we first check to
% see if the Simulink dlls are loaded.  We do this by seeing if the
% Simulink function, get_param, is loaded into memory.
try
if simulinkLoaded || (exist('get_param','builtin') == 5 && inmem('-isloaded','get_param'))
    simulinkLoaded = true;
    
    % simulink is loaded - are any systems open and running?
    statuses = get_param(find_system(0,'type','block_diagram'),'SimulationStatus');
    if ~isempty(statuses)
        if iscell(statuses)
            running = any(cellfun(@(x)~isempty(x),strfind(statuses,'running')));
        else
            running = isequal(statuses,'running');
        end
        com.mathworks.mlwidgets.workspace.MatlabWorkspaceListener.setSimulationRunning(running);
    end
end
catch
    % Ignore any errors that may occur here
end

% Special handling for some of the updated APIs
switch whichcall
    case 'getlastupdate'
        if isempty(lastUpdate)
            error('Workspace browser is not up to date - perhaps it''s not open')
        end
        varargout{1} = lastUpdate;
        return
  case 'requestupdate'
        reportWSChange
        return
end

% Update this value to easily track when the workspace browser is updated
lastUpdate = now;

% Special handling for some of the updated APIs
switch whichcall
    case 'getdefaultworkspaceid'
        varargout{1} = defaultWorkspaceID;
        return

    case {'getworkspace','getworkspaceid','getwhosinformation'}
        swl = com.mathworks.mlwidgets.workspace.MatlabWorkspaceListener.swl(true);
        cleaner = getCleanupHandler(swl); %#ok<NASGU>
        try
            switch whichcall
                case 'getworkspace'
                    varargout{1} = getWorkspace(varargin{1});
                    return
                    
                case 'getworkspaceid'
                    varargout{1} = setWorkspace(varargin{1});
                    return
                    
                case 'getwhosinformation'
                    varargout = {getWhosInformation(varargin{1})};
                    return
            end
        catch e
            if nargin < 3 || ~islogical(varargin{2}) || varargin{2}
                showError(whichcall, e)
            end
            varargout{1} = [];
            return
        end
end

if nargin > 1 && isa(varargin{1},'com.mathworks.mlservices.WorkspaceVariable') && length(varargin{1}) == 1
    swl = com.mathworks.mlwidgets.workspace.MatlabWorkspaceListener.swl(true);
    cleaner = getCleanupHandler(swl); %#ok<NASGU>
end

% some callers expect to handle errors as strings in varargout
returnError = false;

% some callers expect to handle errors as thrown errors
throwError = true;

% some callers require the VariableEditor to refresh.
requireUpdate = false;

if nargin > 1 && isa(varargin{1},'com.mathworks.mlservices.WorkspaceVariable') && length(varargin{1}) == 1
    % Note: the length() == 1 test is for 'save'.
    variable = varargin{1};
    variableName = char(variable.getVariableName);
    workspaceID = variable.getWorkspaceID;
    theWorkspace = workspacefunc('getworkspace', workspaceID);
    
    % always check for base name
    baseVariableName = arrayviewfunc('getBaseVariableName',variableName);
    exists = [];
    
    if ischar(theWorkspace)
        exists = logical(evalin(theWorkspace, ['builtin(''exist'',''' baseVariableName ''' , ''var'')']));
    elseif ismethod(theWorkspace, 'hasVariable')
        try
            exists = hasVariable(theWorkspace, baseVariableName);
        catch
        end
    end
    
    if isempty(exists)
        exists = logical(evalin(theWorkspace, ['exist( ''' baseVariableName ''' , ''var'')']));
    end
    if exists
        try         
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
        catch e
            showError(whichcall, e)
            currentValue = [];
        end
    else
        currentValue = [];
    end
end

try
    
switch whichcall
    case 'getcopyname'
        varargout = {getCopyName(varargin{1}, varargin{2})};
    case 'getnewname'
        varargout = {getNewName(varargin{1})};
    case 'getshortvalue'
        varargout = {getShortValue(varargin{1})};
    case 'getshortvalues'
        getShortValues(varargin{1});
    case 'getshortvalueserror'
        getShortValuesError(varargin{1});
    case 'getshortvalueobjectj'
        varargout = {getShortValueObjectJ(varargin{1}, varargin{2:end})};
    case 'getshortvaluesbypropj'
        varargout = {getShortValuesByPropJ(varargin{:})};
    case 'num2complex'
        varargout = {num2complex(varargin{1}, varargin{2:end})};
    case 'getshortvalueobjectsj'
        varargout = {getShortValueObjectsJ(varargin{1})};
    case 'getshortvalueobjectswithevalj'
        vars = varargin{1};
        w = warning('off', 'all');
        ret = javaArray('java.lang.Object', length(vars));
        for i = 1:length(vars)
            try
                ret(i) = getShortValueObjectJ(evalin('caller',vars{i}));
            catch err %#ok<NASGU>
                ret(i) = java.lang.String(getString(message('MATLAB:codetools:workspacefunc:ErrorDisplayingValue')));
            end
        end
        warning(w);
        varargout{1} = ret;
    case 'getabstractvaluesummariesj'
        varargout = {getAbstractValueSummariesJ(varargin{1})};
    case 'getabstractvaluesummariesjnames'
        w = warning('off', 'all');
        vars = varargin{1};
        ret = javaArray('java.lang.Object', length(vars));
        for i = 1:length(vars)
            try
                % Check to see if the variable exists in the calling
                % workspace before trying to evaluate it
                if evalin('caller',['exist(''' vars{i} ''',''var'')'])
                    % try to eval the variable here, instead of when calling
                    % the function, so that we can catch any errors and prevent
                    % error beeping
                    v = evalin('caller', vars{i});
                    ret(i) = getAbstractValueSummaryJ(v);
                else
                    ret(i) = java.lang.String(getString(message('MATLAB:codetools:workspacefunc:ErrorDisplayingValue')));
                end
            catch err %#ok<NASGU>
                ret(i) = java.lang.String(getString(message('MATLAB:codetools:workspacefunc:ErrorDisplayingValue')));
            end
        end
        varargout = {ret};
        warning(w);
    case 'getstatobjectm'
        varargout = {getStatObjectM(varargin{1}, varargin{2}, varargin{3})};
    case 'getstatobjectsj'
        w = warning('off', 'all');
        vars = varargin{1};
        baseFunction = varargin{2};
        showNaNs = varargin{3};
        numelLimit = varargin{4};
        
        ret = javaArray('java.lang.Object', length(vars));
        for i = 1:length(vars)
            try
                % Check to see if the variable exists in the calling
                % workspace before trying to evaluate it
                baseVarName = arrayviewfunc('getBaseVariableName', vars{i});
                if evalin('caller',['exist(''' baseVarName ''',''var'')'])
                    % try to eval the variable here, instead of when calling
                    % the function, so that we can catch any errors and prevent
                    % error beeping
                    v = evalin('caller', vars{i});
                    ret(i) = getStatObjectJVar(v, baseFunction, showNaNs, numelLimit);
                else
                ret(i) = java.lang.String('');
                end
            catch err %#ok<NASGU>
                ret(i) = java.lang.String('');
            end
        end
        varargout = {ret};
        warning(w);
        
    case 'getshortvalueerrorobjects'
        varargout = {getShortValueErrorObjects(varargin{1})};
    case 'areAnyVariablesReadOnly'
        varargout = {areAnyVariablesReadOnly(varargin{1}, varargin{2})};

    % New APIs begin here
    case 'getExist'
        throwError = false;

        varargout{1} = exists;
        
    case 'save'
        returnError = true;
        
        variables = varargin{1};
        fullPath = char(varargin{2});
        doAppend = varargin{3};
        if isempty(variables)
            workspaceID = getDefaultWorkspaceID;
            variableNames = '';
        else
            workspaceID = variables{1}.getWorkspaceID;
            variableNames = char(variables{1}.getVariableName);
            for i = 2:length(variables)
                if (variables{i} ~= workspaceID)
                    error(message('MATLAB:codetools:workspacefunc:AllVariablesMustHaveSameID'));
                end
                variableNames = [variableNames ' ' char(variables{1}.getVariableName)]; %#ok<AGROW>
            end
        end
        
        appendStr = '';
        if doAppend
            appendStr = ' -append';
        end
        
        evalin(getWorkspace(workspaceID), ['save ' fullPath ' ' variableNames appendStr]);
        
    case 'whos'
        throwError = false;

        evalin(getWorkspace(varargin{1}), 'builtin(''whos'')')
        
    case 'getshortvalueobjects'
        throwError = true;

        workspaceID = varargin{1};
        varargin = varargin(2:end);
        
        values = varargin{1};
        for i = 1:length(values)
            values{i} = evalin(getWorkspace(workspaceID),values{i});
        end
        varargout = {getShortValueObjectsJ(values)};
        
        
    case 'getshortvaluesbyprop'
        throwError = true;

        workspaceID = varargin{1};
        varargin = varargin(2:end);
        
        props = varargin{1};
        varName = varargin{2};
        values = cell(1,length(props));
        for i = 1:length(values)
            try
                values{i} = evalin(getWorkspace(workspaceID),sprintf('%s.%s',varName,props{i}));
            catch
                values{i} = [];
            end
        end
        varargout = {getShortValueObjectsJ(values)};
        
    case 'getabstractvaluesummaries'
        throwError = true;

        varargout = {getAbstractValueSummariesJ({currentValue})};

    case 'getvariableclass'
        throwError = true;
        try
            if nargin > 1 && isa(varargin{1},'com.mathworks.mlservices.WorkspaceVariable') && length(varargin{1}) == 1
                varargout = {class(currentValue)};
            elseif nargin > 1
                % try to eval the variable here, instead of when calling
                % the function, so that we can catch any errors and prevent
                % error beeping
                v = evalin('caller', varargin{1});
                varargout = {class(v)};
            else
                varargout = {''};
            end
        catch
            varargout = {''};
        end
        
    case 'getvariablestatobjects'
        throwError = true;

        workspaceID = varargin{1};
        theWorkspace = getWorkspace(workspaceID);
        
        values = varargin{2};
        for i = 1:length(values)
            variableName = values{i};
            currentValue = evalin(theWorkspace, variableName);
            values{i} = currentValue;
        end
        varargin = varargin(3:end);
        varargout = {getStatObjectsJ(values, varargin{1}, varargin{2}, varargin{3})};
        
    case 'whosinformation'
        throwError = false;
        if varargin{1} == getDefaultWorkspaceID
            error(message('MATLAB:codetools:workspacefunc:GettingVariablesfromDefaultWorkspaceNotImplemented'));
        end
        varargout = {getWhosInformation(evalin(getWorkspace(varargin{1}),'builtin(''whos'')'))};
        
    case 'readonly'
        throwError = false;

        theWorkspace = getWorkspace(varargin{1});
        variableName = varargin{2};
        exists = [];
        
        %split and join are used to escape all quotes in the variable name
        if ischar(theWorkspace)
            exists = logical(evalin(theWorkspace, ['builtin(''exist'',''' strjoin(strsplit(variableName,''''),'''''') ''', ''var'')']));
        elseif ismethod(theWorkspace, 'hasVariable')
            try
                exists = hasVariable(theWorkspace,  strjoin(strsplit(variableName,''''),''''''));
            catch
            end
        end
        if isempty(exists)
            exists = logical(evalin(theWorkspace, ['exist(''' strjoin(strsplit(variableName,''''),'''''') ''' , ''var'')']));
        end
        if ~exists
            varargout{1} = false;
            return
        end
        
        varargin = varargin(2:end);
        names = varargin{2};
        values = varargin{2};
        for i = 1:length(values)
            variableName = values{i};
            if ismethod(theWorkspace, 'getVariable')
                try
                    currentValue = getVariable(theWorkspace, variableName);
                catch
                    % In case of failure, fallback to using evalin
                    currentValue = evalin(theWorkspace, variableName);
                end
            else
                try
                    currentValue = evalin(theWorkspace, variableName);
                catch
                    varargout{1} = false;
                    return
                end
            end
            values{i} = currentValue;
        end
        varargout = {areAnyVariablesReadOnly(values, names)};
        
    case 'rmfield'
        throwError = false;

        % cannot use assignin because variable name can itself
        % be a struct field
        expr = [variableName ' = rmfield(' variableName ','''...
            varargin{2} ''');'];
        evalin(theWorkspace, expr);
        requireUpdate = true;
        
    case 'renamefield'
        throwError = false;
        % cannot use assignin because variable name can itself
        % be a struct field
        expr = [variableName ' = renameStructField(' variableName ','''...
            varargin{2} ''',''' varargin{3} ''');'];
        evalin(theWorkspace, expr);
        requireUpdate = true;
        
    case 'createUniqueField'
        % Create new field in scalar struct, struct array, or nested
        % structs.
        throwError = false;
        
        %
        % Uniquely named field (unnamed#) is added at the end, and assigned
        % a value of 0.
        %
        fields = evalin(theWorkspace,['fieldnames(' variableName ')']);
        fieldLength = length(fields) + 1;
        newName = getNewName(fields);
        
        %
        % determine the new order of the fields, if a 'insert before' field
        % isn't specified, insert it at the beginning
        %
        if (numel(varargin) == 2) 
            insertBefore = varargin{2};
            index = find(strcmp(insertBefore, fields));
        else
            index = [];
        end
        
        %
        % create the strings that will define the new field order - note
        % that arrays aren't used so as to minimize the length of the input
        % string to evalin below
        %
        if (~isempty(index))
            % fieldOrder = [1:index-1 fieldLength index:fieldLength-1];
            fieldOrder = sprintf('[1:%d %d %d:%d]', index-1, fieldLength, index, fieldLength-1);
        else
            % fieldOrder = [1:fieldLength];
            fieldOrder = sprintf('[1:%d]', fieldLength);
        end
        
        % first add a field
        evalin(theWorkspace,sprintf('[%s.(''%s'')]=deal(0);', variableName, newName));
        
        % now reorder them (get rid of any indexing at the end as it is illegal
        % to modify an element of a struct array with disimilarly structured
        % elements
        variableName = regexprep(variableName,'\(.+\)$','');
        evalin(theWorkspace,sprintf('%s=orderfields(%s,%s);', variableName, variableName, fieldOrder));

        requireUpdate = true;
        
    case 'duplicateField'
        throwError = false;

        fields = fieldnames(currentValue);
        newName = getCopyName(varargin{2}, fields);
        % cannot use assignin because variable name can itself
        % be a struct field
        expr = [variableName '.' newName ' = ' variableName '.' ...
            varargin{2} ';'];
        evalin(theWorkspace, expr);
        requireUpdate = true;
 
    case 'createVariable'
        throwError = false;

        expression = varargin{2};
        newValue = evalin(theWorkspace,expression);
        whoOutput = evalin(theWorkspace,'who');
        newName = getNewName(whoOutput);
        assignin(theWorkspace, newName, newValue)
        requireUpdate = true;
        
    case 'assignVariable'
        throwError = false;

        returnError = true;
        expression = varargin{2};
        newExpression = evalin(theWorkspace,expression);
        newValue = setVariableValue(baseVariableName, baseValue, variableName, newExpression);
        assignin(theWorkspace, baseVariableName, newValue)
        requireUpdate = true;
    
    case 'copyworkspacevariables'
        % workspacefunc('copyworkspacevariables', <cell array of variable names>, <cell array of variable identifiers>)
        % Variable Names - Used to store and retrieve the variables from storage.
        % Variable Identifiers - Used to query the values of variables from the caller workspace. 
        
        % Set required variables
        varargout = {};
        
        if isempty(varargin{1}) || isempty(varargin{2})
            return
        end
        
        % Set variable names and identifiers from varargin
        varNames = varargin{1};       % cell array of variable names
        varIdentifiers = varargin{2}; % cell array of variable identifiers
        
        % Set variable names in storage
        copyPasteStorage('-setVarNames',varNames);
        
        % Get variable values from caller workspace and pass into storage
        evalin('caller',[mfilename,...
            '(''setcopyvarvalues'',{',cell2csv(varIdentifiers),'});']);
        
    case 'pasteworkspacevariables'
        % workspacefunc('pasteworkspacevariables', <cell array of original variable names>, <cell array of new variable names>)
        % Original Names - Used to query variables in storage
        % New Names - Used to name variables in Caller workspace
        
        % Set required variables
        varargout = {};
        
        if isempty(varargin{1}) || isempty(varargin{2})
            return
        end
        
        % Get cell array of stored and new variable names
        origNames = varargin{1};   % cell array of original variable names        
        newNames  = varargin{2};   % cell array of new variable names
        
        % Clean up any leaked variables
        copyPasteStorage('-clearVariables',origNames);
        
        % Check to be sure that 'copy' has been called previously
        if    copyPasteStorage('-isempty')
            return;
        end

        % Create variables in caller workspace
        for varNameIdx = 1:numel(newNames)
            evalin('caller',[newNames{varNameIdx},...
                ' = ',mfilename,'(''getcopyvarvalues'',''',...
                origNames{varNameIdx},''');']);
        end
        
        requireUpdate = true;

    case 'clearstoredworkspacevariables'
        % workspacefunc('clearstoredworkspacevariables', <cell array of variables to be saved>{optional})
        % Saved Variables - Optional way of preventing certain variables from being cleared from storage.
        
        % Set required variables
        varargout = {};
        
        % Clean up variable storage
        if isempty(varargin)
            copyPasteStorage('-clearAllVariables');
        else
            copyPasteStorage('-clearVariables',varargin{1});
        end
        
    case 'getcopyvarnames'
        % Return names of all variables in storage (Used for testing)
        varargout = {copyPasteStorage('-getVarNames')}; 

    % The following 2 cases are called from previous cases and require data 
    % to be input from the caller workspace    
    case 'setcopyvarvalues'
        % Set required variables
        varargout = {};
        
        % Set variable values in storage
        copyPasteStorage('-setVarValues',varargin{1});
        
    case 'getcopyvarvalues'
        % Return variable values from storage
        varargout = {copyPasteStorage('-getVarValues',varargin{1})};

    case 'clearstoredworkspace'
      getWorkspaceID('-clear',varargin{1})
      
    case 'createComplexVector'
      varargout = {createComplexVector(varargin{:})}; 

    otherwise
        error(message('MATLAB:workspacefunc:unknownOption'));
end

    if requireUpdate
        reportWSChange
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
function reportWSChange()
com.mathworks.mlwidgets.workspace.MatlabWorkspaceListener.reportWSChange();

%********************************************************************
function out = setVariableValue(baseVariableName,baseValue,lhs,rhs) %#ok
% Use a function to this value so we don't add unexpected variables
% to the caller's workspace.
eval([baseVariableName '= baseValue;']);
eval([lhs ' =  rhs;']);
out = eval(baseVariableName);

%********************************************************************
function yesno = isValidWorkspace(arg)
yesno = isa(arg,'handle') && isscalar(arg) && ismethod(arg,'evalin') && ismethod(arg,'assignin');

%********************************************************************
function out = getWorkspace(arg)
out = getWorkspaceID('-get',arg);

%********************************************************************
function out = setWorkspace(arg)
out = getWorkspaceID('-set',arg);

%********************************************************************
function out = getDefaultWorkspaceID
out = com.mathworks.mlservices.WorkspaceVariable.DEFAULT_ID;

%********************************************************************
function out = getWorkspaceID(request, arg)
persistent savedWorkspaces;
persistent defaultID;
persistent defaultWS;
if isempty(savedWorkspaces)
    savedWorkspaces = cell(1,10);
end
if isempty(defaultID)
    defaultID = getDefaultWorkspaceID;
end
if isempty(defaultWS)
    defaultWS = 'default';
end

switch request
    case '-get'
        if isempty(arg)
            error(message('MATLAB:codetools:workspacefunc:ArgumentToGetWorkspaceIDCannotBeEmpty'));
        end
        
        if isequal(arg,defaultID)
            out = 'caller';
            return
        end
        
        if arg > length(savedWorkspaces) || ~isnumeric(arg) || ...
                isempty(savedWorkspaces{arg}) || isequal(savedWorkspaces{arg},0)
            error(message('MATLAB:codetools:unknownid'));
        end
        
        out = savedWorkspaces{arg};
    
    case '-set'
        if isempty(arg)
            arg = defaultWS;
        end

        if isequal(arg,defaultWS)
            out = defaultID;
            return
        end
        
        if ~isValidWorkspace(arg)
            error(message('MATLAB:codetools:invalid'));
        end
        
        locations = cellfun(@(candidate)isequal(candidate,arg), savedWorkspaces);
        if any(locations)
            index = find(locations);
            if length(index) > 1
                error(message('MATLAB:codetools:workspacefunc:WorkspaceStorageErrorTooManyWorkspacesFound'));
            end
        else
            indexes = find(cellfun('isempty',savedWorkspaces));
            if isempty(indexes)
                % grow the array
                savedWorkspaces{end+1} = arg;
                index = length(savedWorkspaces);
            else
                index = min(indexes);
                savedWorkspaces{index} = arg;
            end
        end
        out = index;

    case '-clear'
        if arg > length(savedWorkspaces) || ~isnumeric(arg) || ...
                isempty(savedWorkspaces{arg}) || isequal(savedWorkspaces{arg},0)
              return;
        end

        savedWorkspaces{arg} = [];

    otherwise
        error(message('MATLAB:codetools:workspacefunc:UnexpectedInput', request));

end

%********************************************************************
function new = getCopyName(orig, who_output)

    % Create a new unique variable name given the existing workspace
    % variables.  The new variable name will have 'Copy' appended to the
    % end.  If the new variable name is too long, characters will be
    % stripped off the end prior to 'Copy' being appended so it is less
    % than namelengthmax and is unique.
    counter = 0;
    if strlength(orig) + 4 > namelengthmax
        orig = orig(1:namelengthmax - 4);
    end
    new_base = [orig 'Copy'];
    new = new_base;
    while localAlreadyExists(new , who_output)
        counter = counter + 1;
        proposed_number_string = num2str(counter);
        new = [new_base proposed_number_string];
        if strlength(new) > namelengthmax
            new = [orig(1:namelengthmax - 4 - strlength(proposed_number_string)) ...
                'Copy' proposed_number_string];
        end
    end

%********************************************************************
function new = getNewName(who_output)

counter = 0;
new_base = 'unnamed';
new = new_base;
while localAlreadyExists(new , who_output)
    counter = counter + 1;
    proposed_number_string = num2str(counter);
    new = [new_base proposed_number_string];
end

%********************************************************************
function getShortValues(vars)

w = warning('off', 'all');
fprintf(newline);
for i=1:length(vars)
    % Escape any backslashes.
    % Do it here rather than in the getShortValue code, since the
    % fact that Java is picking them up for interpretation is a
    % function of how they're being displayed.
    val = getShortValue(vars{i});
    val = strrep(val, '\', '\\');
    val = strrep(val, '%', '%%');
    fprintf([val 13 10]);
end
warning(w);

%********************************************************************
function retstr = getShortValue(var)

retstr = '';
if isempty(var)
    if builtin('isnumeric', var)
        % Insert a space for enhanced readability.
        retstr = '[ ]';
    end
    if ischar(var)
        retstr = '''''';
    end
end

if isempty(retstr)
    try
        stringDisplayLimit = 128;
        if ~isempty(var)
            if builtin('isnumeric',var) && (numel(var) < 11) && (ismatrix(var))
                % Show small numeric arrays.
                if ~contains(get(0, 'format'), 'long')
                    retstr = mat2str(var, 5);
                else
                    retstr = mat2str(var);
                end
            elseif islogical(var) && (numel(var) == 1)
                if var
                    retstr = 'true';
                else
                    retstr = 'false';
                end
            elseif (localIsString(var) && (ismatrix(var)) && (length(var) == 1))
                if var.strlength <= stringDisplayLimit
                    retstr = ['"' char(var) '"'];
                else
                    strPreviewTruncated = getString(message('MATLAB:codetools:workspacefunc:PreviewTruncatedAtCharacters',num2str(stringDisplayLimit)));
                    retstr = ['"' char(var.extractBetween(1,stringDisplayLimit)) '..." ' ...
                        strPreviewTruncated];
                end
            elseif (ischar(var) && (ismatrix(var)) && (size(var, 1) == 1))
                % Show "single-line" char arrays, while establishing a reasonable
                % truncation point.
                if ~contains(var, newline) && ...
                        ~contains(var, char(13)) && ...
                        ~contains(var, char(0))
                    if numel(var) <= stringDisplayLimit
                        retstr = ['''' var ''''];
                    else
%                         retstr = ['''' var(1:limit) '...'' ' ...
%                             getString(message('MATLAB:codetools:workspacefunc:cellstr_PreviewTruncatedAt')) num2str(limit) ' characters>'];
                          strPreviewTruncated = getString(message('MATLAB:codetools:workspacefunc:PreviewTruncatedAtCharacters',num2str(stringDisplayLimit)));
                          retstr = ['''' var(1:stringDisplayLimit) '...'' ' ...
                            strPreviewTruncated];
                    end
                end
            elseif isa(var, 'function_handle') && numel(var) == 1
                retstr = strtrim(evalc('disp(var)'));
            end
        end
        
        % Don't call mat2str on an empty array, since that winds up being the
        % char array "''".  That looks wrong.
        if isempty(retstr)
            s = size(var);
            D = numel(s);
            if D == 1
                % This can happen when objects that have overridden SIZE (such as
                % a javax.swing.JFrame) return another object as their "size."
                % In that case, it's a scalar.
                theSize = '1x1';
            elseif D == 2
                theSize = [num2str(s(1)), 'x', num2str(s(2))];
            elseif D == 3
                theSize = [num2str(s(1)), 'x', num2str(s(2)), 'x', ...
                    num2str(s(3))];
            else
                theSize = [num2str(D) '-D'];
            end
            classinfo = [' ' getclass(var,true)];
            retstr = ['<', theSize, classinfo, '>'];
        end
    catch err %#ok<NASGU>
        retstr = getString(message('MATLAB:codetools:workspacefunc:ErrorDisplayingValue'));
    end
end

%********************************************************************
function result = localAlreadyExists(name, who_output)
result = false;
counter = 1;
while ~result && counter <= length(who_output)
    result = strcmp(name, who_output{counter});
    counter = counter + 1;
end

%********************************************************************
function getShortValuesError(numberOfVars)

fprintf(newline);
for i=1:numberOfVars
    fprintf([getString(message('MATLAB:codetools:workspacefunc:ErrorRetrievingValue')) 13 10]);
end

%********************************************************************
function retval = getShortValueObjectJ(var, varargin)
if nargin == 0
    var = [];
end
if isa(var, 'tall') || localIsDistributedType(var)
    retval = num2complex(var);
    return
end

try
    L = lasterror; %#ok<*LERR>
catch
    % Any errors trying to get the lasterror state can be ignored
    L = [];
end

try
    emptyVar = isempty(var);
    if ~islogical(emptyVar)
        emptyVar = true;
    end
catch
    % Assume empty if there's an error
    emptyVar = true;
    if ~isempty(L)
        lasterror(L);
    end
end

if emptyVar
    if builtin('isnumeric', var)
        retval = num2complex(var);
        return;
    end
    if ischar(var)
        retval = num2complex(var);
        return;
    end
end

try
    % Start by assuming that we won't get anything back.
    retval = '';
    if ~emptyVar
        if islogical(var)
            retval = num2complex(var);
        end
    end

    if (localIsString(var) && (ismatrix(var)) && (length(var) == 1))
        quoteStrings = true;
        limit = 128;
        optargin = size(varargin,2);
        if (optargin > 0)
            quoteStrings = varargin{1};
        end
        if (optargin > 1)
            limit = varargin{2};
        end
        if ismissing(var)
            retval = com.mathworks.widgets.spreadsheet.data.ValueSummaryFactory.getInstance(...
                strtrim(evalc('disp(var)')), size(var));
            retval.setMissing(true);
        elseif var.strlength <= limit
            if (quoteStrings)
                retval = java.lang.String(['"' char(var) '"']);
            else
                retval = java.lang.String(['' char(var) '']);
            end
        else
            strPreviewTruncated = getString(message('MATLAB:codetools:workspacefunc:PreviewTruncatedAtCharacters',num2str(limit)));
            if quoteStrings
                retval = java.lang.String(...
                    sprintf('"%s..." %s', ...
                    var.extractBetween(1,limit), strPreviewTruncated));
            else
                retval = java.lang.String(...
                    sprintf('%s... %s', ...
                    var.extractBetween(1,limit), strPreviewTruncated));
            end
        end
    elseif (ischar(var) && (ismatrix(var)) && (size(var, 1) == 1))
        % Show "single-line" char arrays, while establishing a reasonable
        % truncation point.
        if ~contains(var, newline) && ...
                ~contains(var, char(13)) && ...
                ~contains(var, char(0))
            quoteStrings = true;
            limit = 128;
            optargin = size(varargin,2);
            if (optargin > 0) 
                quoteStrings = varargin{1};
            end
            if (optargin > 1) 
                limit = varargin{2};
            end
            if numel(var) <= limit
                if (quoteStrings)
                    retval = java.lang.String(['''' var '''']);
                else
                    retval = java.lang.String(['' var '']);
                end
            else
                strPreviewTruncated = getString(message('MATLAB:codetools:workspacefunc:PreviewTruncatedAtCharacters',num2str(limit)));
                retval = java.lang.String(...
                    sprintf('''%s...'' %s', ...
                    var(1:limit), strPreviewTruncated));
            end
        end
    end

    if isa(var, 'function_handle') && numel(var) == 1
        retval = java.lang.String(strtrim(evalc('disp(var)')));
    end

    % Don't call mat2str on an empty array, since that winds up being the
    % char array "''".  That looks wrong.
    if isempty(retval)
        retval = num2complex(var);
    end
catch err %#ok<NASGU>
    retval = java.lang.String(getString(message('MATLAB:codetools:workspacefunc:ErrorDisplayingValue')));
end

%********************************************************************
function outVal = num2complex(in)
if builtin('isnumeric', in)
    if isscalar(in)
        outVal = createComplexScalar(in);
    elseif isempty(in)
        % Use this to get the special "empty" handling of the
        % ValueSummaryFactory class.
        clazz = class(in);
        outVal = com.mathworks.widgets.spreadsheet.data.ValueSummaryFactory.getInstance(...
            cast(0, clazz), size(in), ...	 
            ~dataviewerhelper('isUnsignedIntegralType', in), isreal(in));
    elseif numel(size(in)) > 2 || numel(in) > 10
        outVal = getAbstractValueSummaryJ(in);
    else
        outVal = createComplexVector(in);
    end
else
    if islogical(in)
        if isscalar(in)
            if (in)
                outVal = java.lang.Boolean.TRUE;
            else
                outVal = java.lang.Boolean.FALSE;
            end
        else
            % Let it drop to the class-handling code.
            outVal = getAbstractValueSummaryJ(in);
        end

    elseif localIsDistributedType(in) 
        % Display the underlying class for distributed/gpuArrays
        vs = com.mathworks.widgets.spreadsheet.data.ValueSummaryFactory.getInstance(...
            class(in), size(in));
        vs.setSecondaryClassName(classUnderlying(in));
        outVal = vs;

    elseif isa(in, 'tall')
        % Custom display for tall variables
        w = whos('in');
        className = class(in);
        
        % Create ValueSummary, and setup the additional tall information if its
        % available. 
        vs = com.mathworks.widgets.spreadsheet.data.ValueSummaryFactory.getInstance(...
            className, w.size);

        try
            tallInfo = matlab.bigdata.internal.util.getArrayInfo(in);
            tallInfoSize = getTallInfoSize(tallInfo);
            if ~tallInfo.Gathered
                vs.setSecondaryStatus(getString(message...
                    ('MATLAB:codetools:workspacefunc:Unevaluated')));
            end
            if ~isempty(tallInfo.Class)
                vs.setSecondaryClassName(tallInfo.Class);
            end
            if ~isempty(tallInfoSize)
                vs.setSecondarySize(tallInfoSize);
            end
        catch
            % do nothing
        end
        vs.setIsTall(true);
        outVal = vs;
    else
        outVal = getAbstractValueSummaryJ(in);
    end
end

function tallInfoSize = getTallInfoSize(tallInfo)
    % Calculate a MxNx... or similar size string.  This logic matches
    % similar logic for tall variable command line display.
    if isempty(tallInfo.Size) || isnan(tallInfo.Ndims)
        % No size information at all
        tallInfoSize = '';        
    else
        % Create a string representation of the size, replacing any NaN's
        % with a replacement letter
        
        % unknownDimLetters are the placeholders we'll use in the size
        % specification
        unknownDimLetters = 'M':'Z';
        
        dimStrs = cell(1, tallInfo.Ndims);
        for idx = 1:tallInfo.Ndims
            if isnan(tallInfo.Size(idx))
                if idx > numel(unknownDimLetters)
                    % Array known to be 15-dimensional, but 15th (or
                    % higher) dimension is not known. Not sure how you'd
                    % ever hit this.
                    dimStrs{idx} = '?';
                else
                    dimStrs{idx} = unknownDimLetters(idx);
                end
            else
                dimStrs{idx} = num2str(tallInfo.Size(idx));
            end
        end

        % Join together dimensions using the x character.
        tallInfoSize = strjoin(dimStrs, 'x'); %char(215));
    end


%********************************************************************
function outVal = createComplexScalar(in)
import com.mathworks.widgets.spreadsheet.data.ComplexScalarFactory;
toReport = dataviewerhelper('upconvertIntegralType', in);
if isinteger(in)
    signed   = ~dataviewerhelper('isUnsignedIntegralType', in);
    % Integer values need their signed-ness explicitly stated.
    if isreal(in)
        outVal = ComplexScalarFactory.valueOf(toReport, signed);
    else
        outVal = ComplexScalarFactory.valueOf(real(toReport), imag(toReport), signed);
    end
else
    % Floating-point values don't have a "signed" vs. "unsigned" concept.
    if isreal(in)
        outVal = ComplexScalarFactory.valueOf(double(toReport));
    else
        outVal = ComplexScalarFactory.valueOf(real(toReport), imag(toReport));
    end
end

%********************************************************************
function outVal = createComplexVector(in, realdata)
import com.mathworks.widgets.spreadsheet.data.ComplexArrayFactory;
toReport = dataviewerhelper('upconvertIntegralType', in);
if nargin<=1
    realdata = isreal(in);
end
if isinteger(in)
    signed   = ~dataviewerhelper('isUnsignedIntegralType', in);
    % Integer values need their signed-ness explicitly stated.
    if realdata
        outVal = ComplexArrayFactory.valueOf(toReport, signed);
    else
        outVal = ComplexArrayFactory.valueOf(real(toReport), imag(toReport), signed);
    end
else
    % Floating-point values don't have a "signed" vs. "unsigned" concept.
    if realdata
        outVal = ComplexArrayFactory.valueOf(double(toReport));
    else
        outVal = ComplexArrayFactory.valueOf(real(toReport), imag(toReport));
    end
end

%********************************************************************
function ret = getAbstractValueSummariesJ(vars)

w = warning('off', 'all');
ret = javaArray('java.lang.Object', length(vars));
for i = 1:length(vars)
    try
        ret(i) = getAbstractValueSummaryJ(vars{i});
    catch err %#ok<NASGU>
        ret(i) = java.lang.String(getString(message('MATLAB:codetools:workspacefunc:ErrorDisplayingValue')));
    end
end
warning(w);

%********************************************************************
function clazz = getclass(in, include_attributes, w)
if ~isa(in, 'timeseries') || numel(in)~=1
    if nargin == 2
        w = whos('in');
    end
    clazz = w.class;
    if include_attributes
        if w.complex
            clazz = ['complex ' clazz]; % not translated in MATLAB
        end
        if w.sparse
            clazz = ['sparse ' clazz]; % not translated in MATLAB
        end
        if w.global
            clazz = ['global ' clazz]; % not translated in MATLAB
        end
    end
else
    clazz = [class(in.Data) ' ' class(in)];
end

%********************************************************************
function vs = getAbstractValueSummaryJ(in)

w = whos('in');
if isa(in, 'tall')
    % Custom display for tall variables
    vs = com.mathworks.widgets.spreadsheet.data.ValueSummaryFactory.getInstance(...
        getclass(in, false, w), w.size);
    vs.setIsTall(true);

    try
        tallInfo = matlab.bigdata.internal.util.getArrayInfo(in);
        if ~tallInfo.Gathered
            vs.setSecondaryStatus(getString(message...
                ('MATLAB:codetools:workspacefunc:Unevaluated')));
        end
        if ~isempty(tallInfo.Class)
            vs.setSecondaryClassName(tallInfo.Class);
        end
        tallInfoSize = getTallInfoSize(tallInfo);
        if ~isempty(tallInfoSize)
            vs.setSecondarySize(tallInfoSize);
        end
    catch
    end

elseif localIsDistributedType(in) 
    % Custom display for distributed/gpuArray variables
    vs = com.mathworks.widgets.spreadsheet.data.ValueSummaryFactory.getInstance(...
        getclass(in, false, w), w.size);
    vs.setSecondaryClassName(classUnderlying(in));

else
    try
        vs = com.mathworks.widgets.spreadsheet.data.ValueSummaryFactory.getInstance(...
            getclass(in, false, w), w.size);
        if any(isinf(w.size))
            vs.setInfSizes(isinf(w.size));
        end
    catch ex
        % This may have failed because the number of dimensions in the
        % variable is so large that the java array of dimensions fails to
        % be created.  If  that's the case, use a size of -1x-1, and set
        % the length of size setting to be used instead.  (Otherwise, if it
        % failed for another reason, just rethrow the error).  Note - using
        % a try/catch instead of checking beforhand so there's no change in
        % performance under normal circumstances.
        sizeLength = length(w.size);
        if sizeLength > 100000
            vs = com.mathworks.widgets.spreadsheet.data.ValueSummaryFactory.getInstance(...
                getclass(in, false, w), [-1, -1]);
            vs.setLengthOfSize(sizeLength);
        else
            ex.rethrow
        end
    end
    if w.complex
        vs.setIsReal(false);
    end
    if w.global
        vs.setIsGlobal(true);
    end
    if w.sparse
        vs.setIsSparse(true);
    end
    if strcmp(w.class, 'struct')
        f = fieldnames(in);
        vs.setNumFields(length(f));
    end
end

%********************************************************************
function ret = getShortValueObjectsJ(vars)

w = warning('off', 'all');
ret = javaArray('java.lang.Object', length(vars));
for i = 1:length(vars)
    try
        ret(i) = getShortValueObjectJ(vars{i});
    catch err %#ok<NASGU>
        ret(i) = java.lang.String(getString(message('MATLAB:codetools:workspacefunc:ErrorDisplayingValue')));
    end
end
warning(w);

%********************************************************************
function ret = getShortValuesByPropJ(value,props)

w = warning('off', 'all');
ret = javaArray('java.lang.Object', length(props));
for i = 1:length(props)
    try
        ret(i) = getShortValueObjectJ(value.(props{i}));
    catch err %#ok<NASGU>
        % Since this method is callsed from java, do not return '' or []
        % or it will be converted to null by the jmi
        ret(i) = java.lang.String(''); 
    end
end
warning(w);

%********************************************************************
function retval = getStatObjectM(var, baseFunction, showNaNs)

underlyingVar = var;
% First handle timeseries, since they aren't numeric.
isTimeseries = false;
if isa(var, 'timeseries')
    underlyingVar = get(var, 'Data');
    isTimeseries = true;
end
    
if ~builtin('isnumeric', underlyingVar) || isempty(underlyingVar) || issparse(underlyingVar)
    retval = '';
    return;
end

if isinteger(underlyingVar) && ~strcmp(baseFunction, 'max') && ...
        ~strcmp(baseFunction, 'min') && ~strcmp(baseFunction, 'range')
    retval = '';
    return;
end

if isTimeseries
    if strcmp(baseFunction, 'range')
        retval = local_ts_range(var);
    else
        retval = fevalPossibleMethod(baseFunction, var);
    end
else
    if (showNaNs)
        switch(baseFunction)
            case 'min'
                fun = @local_min;
            case 'max'
                fun = @local_max;
            case 'range'
                fun = @local_range;
            case 'mode'
                fun = @local_mode;
            otherwise
                fun = baseFunction;
        end
    else
        switch(baseFunction)
            case 'range'
                fun = @local_nanrange;
            case 'mean'
                fun = @local_nanmean;
            case 'median'
                fun = @local_nanmedian;
            case 'mode'
                fun = @local_mode;
            case 'std'
                fun = @local_nanstd;
            otherwise
                fun = baseFunction;
        end
    end
    % Scalar Objects do not need to be indexed as it is already handled
    % by basefunctions (Min,Max,etc)
    if ~isscalar(var)
        var = var(:);
    end
    
    retval = feval(fun, var);
end

%********************************************************************
function retval = getStatObjectJ(var, baseFunction, showNaNs)
retval = num2complex(getStatObjectM(var, baseFunction, showNaNs));

%********************************************************************
function ret = getStatObjectsJ(vars, baseFunction, showNaNs, numelLimit)

w = warning('off', 'all');
ret = javaArray('java.lang.Object', length(vars));
for i = 1:length(vars)
    ret(i) = getStatObjectJVar(vars{i}, baseFunction, showNaNs, numelLimit);
end
warning(w);

%********************************************************************
function ret = getStatObjectJVar(var, baseFunction, showNaNs, numelLimit)
    if ~isa(var, 'tall') && numel(var) > numelLimit
        ret = java.lang.String(getString(message('MATLAB:codetools:workspacefunc:TooManyElements')));
    else
        try
            ret = getStatObjectJ(var, baseFunction, showNaNs);
        catch err %#ok<NASGU>
            clazz = builtin('class', var);
            if strcmp(clazz, 'int64') || strcmp(clazz, 'uint64')
                ret = num2complex('');
            else
                % Excluded the <ErrorDisplayingValue> to not display this
                % error and display a blank  instead.
                ret = java.lang.String('');
            end
        end
    end

%********************************************************************
function out = fevalPossibleMethod(baseFunction, var)
if ismethod(var, baseFunction)
    out = feval(baseFunction, var);
else
    out = '';
end

%********************************************************************
function out = getShortValueErrorObjects(numberOfVars)

out = javaArray('java.lang.String', length(numberOfVars));
for i=1:numberOfVars
    out(i) = java.lang.String(getString(message('MATLAB:codetools:workspacefunc:ErrorRetrievingValue')));
end

%********************************************************************
function m = local_min(x)
if isfloat(x)
    if any(isnan(x))
        m = cast(NaN, class(x));
    else
        m = min(x);
    end
else
    m = min(x);
end
%********************************************************************
function m = local_max(x)

%Handling the input objects of subclass of Numeric classes with properties
% Modified  the implementation same as Min 
if isfloat(x)
    if any(isnan(x))
        m = cast(NaN, class(x));
    else
        m = max(x);
    end
else
    m = max(x);
end

%********************************************************************
function m = local_range(x)
lm = local_max(x);
if isnan(lm)
    m = cast(NaN, class(x));
else
    m = lm-local_min(x);
end

%********************************************************************
function m = local_ts_range(x)
m = max(x)-min(x);

%********************************************************************
function m = local_nanrange(x)
m = max(x)-min(x);

%********************************************************************
function m = local_nanmean(x)
% Find NaNs and set them to zero
nans = isnan(x);
x(nans) = 0;

% Count up non-NaNs.
n = sum(~nans);
n(n==0) = NaN; % prevent divideByZero warnings
% Sum up non-NaNs, and divide by the number of non-NaNs.
m = sum(x) ./ n;

%********************************************************************
function y = local_nanmedian(x)

% If X is empty, return all NaNs.
if isempty(x)
    y = nan(1, 1, class(x));
else
    x = sort(x,1);
    nonnans = ~isnan(x);

    % If there are no NaNs, do all cols at once.
    if all(nonnans(:))
        n = length(x);
        if rem(n,2) % n is odd
            y = x((n+1)/2,:);
        else        % n is even
            y = (x(n/2,:) + x(n/2+1,:))/2;
        end

    % If there are NaNs, work on each column separately.
    else
        % Get percentiles of the non-NaN values in each column.
        y = nan(1, 1, class(x));
        nj = find(nonnans(:,1),1,'last');
        if nj > 0
            if rem(nj,2) % nj is odd
                y(:,1) = x((nj+1)/2,1);
            else         % nj is even
                y(:,1) = (x(nj/2,1) + x(nj/2+1,1))/2;
            end
        end
    end
end

%********************************************************************
function y = local_nanstd(varargin)
y = sqrt(local_nanvar(varargin{:}));

%********************************************************************
function y = local_nanvar(x)

% The output size for [] is a special case when DIM is not given.
if isequal(x,[]), y = NaN(class(x)); return; end

% Need to tile the mean of X to center it.
tile = ones(size(size(x)));
tile(1) = length(x);

% Count up non-NaNs.
n = sum(~isnan(x),1);

% The unbiased estimator: divide by (n-1).  Can't do this when
% n == 0 or 1, so n==1 => we'll return zeros
denom = max(n-1, 1);
denom(n==0) = NaN; % Make all NaNs return NaN, without a divideByZero warning

x0 = x - repmat(local_nanmean(x), tile);
y = local_nansum(abs(x0).^2) ./ denom; % abs guarantees a real result

%********************************************************************
function y = local_nansum(x)
x(isnan(x)) = 0;
y = sum(x);

%********************************************************************
function y = local_mode(x)

y = mode(x);

%********************************************************************
function out = getWhosInformation(in)

if numel(in) == 0
    out = com.mathworks.mlwidgets.workspace.WhosInformation.getInstance;
else
    % Prune the dataset to only include the deepest nesting level - this
    % is relevant for nested functions when debugging. The desired behavior
    % is to only show the variables in the deepest workspace.
    nesting = [in.nesting];
    level = [nesting.level];
    prunedWhosInformation = in(level == max(level));

    % Perform a case insensitive sort since "whos" returns the variables
    % sorted in case sensitive order. Since this case sensitive order
    % puts capital letters ahead of lower case, reverse it first, so that
    % the sort resolves matching lower case names with capital letters
    % after lower case. This ensures that the variables are sorted with an
    % order that matches the details pane of CSH (944091)
    names = {prunedWhosInformation.name};
    [~,I] = sort(lower(names(end:-1:1)));
    I = length(names)-I+1;
    sortedWhosInformation = prunedWhosInformation(I);

    siz = {sortedWhosInformation.size}';
    names = {sortedWhosInformation.name};
    inbytes = [sortedWhosInformation.bytes];
    inclass = {sortedWhosInformation.class};
    incomplex = [sortedWhosInformation.complex];
    insparse = [sortedWhosInformation.sparse];
    inglobal = [sortedWhosInformation.global];
    
    try
        out = com.mathworks.mlwidgets.workspace.WhosInformation(names, ...
            siz, inbytes, inclass, incomplex, insparse, inglobal);
    catch
        % This may have failed because the number of dimensions in one of
        % the variables is so large that the java array of dimensions fails
        % to be created.  Retry using a size of -1x-1, and set the
        % sizeLengths to be used instead.   Note - using a try/catch
        % instead of checking beforhand so there's no change in performance
        % under normal circumstances.
        sizeLengths = cellfun(@length, siz);
        siz(sizeLengths > 100000) = {[-1, -1]};
        out = com.mathworks.mlwidgets.workspace.WhosInformation(names, ...
            siz, inbytes, inclass, incomplex, insparse, inglobal, sizeLengths);
    end
end

%********************************************************************
function isReadOnly = areAnyVariablesReadOnly(values, valueNames)
values = fliplr(values);
valueNames = fliplr(valueNames);
isReadOnly = false;
for i = 1:length(valueNames)-1
    thisFullValue = values{i};
    if ~isstruct(thisFullValue)
        thisFullValueName = valueNames{i};
        nextFullValueName = valueNames{i+1};
        delim = nextFullValueName(length(thisFullValueName)+1);
        if delim == '.'
            nextShortIdentifier = nextFullValueName(length(thisFullValueName)+2:end);
            metaclassInfo = metaclass(values{i});
            properties = metaclassInfo.Properties;
            for j = 1:length(properties)
                thisProp = properties{j};
                if strcmp(thisProp.Name, nextShortIdentifier)
                    if ~strcmp(thisProp.SetAccess, 'public')
                        isReadOnly = true;
                        return;
                    end
                end
            end
        end
    end
end

function cleaner = getCleanupHandler(swl)
cleaner = onCleanup(@(~,~) com.mathworks.mlwidgets.workspace.MatlabWorkspaceListener.swl(swl));

function showError(whichcall, e)
msg = e.message;
stack = e.stack;
[~,file] = fileparts(stack(1).file);
line = num2str(stack(1).line);
com.mathworks.mlwidgets.array.ArrayDialog.showErrorDialog([whichcall 10 msg 10 file 10 line])

%********************************************************************
function varargout = copyPasteStorage(action,values)
mlock

persistent variableNames       % Cell array of currently stored variable names
persistent copiedVariables     % Structure of stored variables

if isempty(variableNames)
    variableNames = {};
end

if isempty(copiedVariables)
    copiedVariables = struct();
end

varargout = {};

if nargin < 1 || nargin > 2
    return;
end

if ischar(action)
    switch action
        case '-clearAllVariables'
            clear variableNames copiedVariables;
        
        case '-clearVariables'
            clear variableNames;
            
            % Determine which fields should be deleted from "copiedVariables"
            storedVariables = fieldnames(copiedVariables);
            saveVariables   = csv2cell(values);
            deleteVariables = setdiff(storedVariables,saveVariables);
            
            % Delete each field one at a time so that any errors do not
            % prevent the rest of the fields from being deleted.
            for idx = 1:numel(deleteVariables)
                try
                    copiedVariables = rmfield(copiedVariables,deleteVariables{idx});
                catch
                    % Field does not exist, so do nothing
                end
            end
        case '-setVarNames'
            if ~isempty(values)
                % Determine which field names need to be initialized
                variableNames = csv2cell(values);
                storedVariables = fieldnames(copiedVariables);
                initializeVariables = setdiff(variableNames,storedVariables);
                
                % Initialize the fields which do not currently exist
                for idx = 1:numel(initializeVariables)
                    if isempty(initializeVariables)
                        copiedVariables.(initializeVariables{idx}) = [];
                    end
                end
            end
        case '-getVarNames'
            % Returns all fieldnames of "copiedVariables".
            varargout = {fieldnames(copiedVariables)};
        case '-setVarValues'
            % sets the appropriate fields of "copiedVariables" to the input
            % values
            for idx = 1:numel(variableNames)
                copiedVariables.(variableNames{idx}) = values{idx};
            end
        case '-getVarValues'
            % Returns the values stored in "copiedVariables"
            varargout = {copiedVariables.(values)};
        case '-isempty'
            % Checks if any fieldnames exist in "copiedVariables"
            varargout = {isempty(fieldnames(copiedVariables))};
        otherwise
            return;
    end
else
    return;
end

%********************************************************************
function cellValues = csv2cell(commaSeparatedValues)
% Convert a comma separated list into a cell array of strings
if ischar(commaSeparatedValues)
    cellValues = regexp(commaSeparatedValues,', ','split');
elseif iscell(commaSeparatedValues)
    cellValues = commaSeparatedValues;
else
    error('CSV2CELL:WORKSPACEFUNC','Unexpected input data type.')
end

%********************************************************************
function commaSeparatedValues = cell2csv(cellValues)
% Convert a cell array of strings into a comma separated list
if ischar(cellValues)
    commaSeparatedValues = cellValues;
elseif iscell(cellValues)
    commaSeparatedValues = cellValues(:);
    commaSeparatedValues = [commaSeparatedValues,repmat({', '},numel(commaSeparatedValues),1)]';
    commaSeparatedValues = commaSeparatedValues(:)';
    commaSeparatedValues = cell2mat(commaSeparatedValues(1:end-1));
else
    error('CELL2CSV:WORKSPACEFUNC','Unexpected input data type.')
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
function b = localIsDistributedType(var)
    b = isa(var, 'distributed') || isa(var, 'codistributed') || ...
        isa(var, 'gpuArray');
