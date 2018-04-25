function [b,ia] = stack(a,dataVars,varargin)
%STACK Stack up data from multiple variables into a single variable
%   S = STACK(U,DATAVARS) converts the table U to an equivalent table
%   S that is in "stacked format", by "stacking up" multiple variables in U
%   into a single variable in S.  In general, S contains fewer variables,
%   but more rows, than U.
%
%   DATAVARS specifies a group of M data variables in U.  STACK creates a
%   single data variable in S by interleaving their values, and if U has N
%   rows, then S has M*N rows.  In other words, STACK takes the M data values
%   from each row in U and stacks them up to create M rows in S.  DATAVARS
%   is a positive integer, a vector of positive integers, a variable name, a
%   cell array containing one or more variable names, or a logical vector.
%   STACK also creates a new variable in S to indicate which of the M data
%   variables in U each row in S corresponds to.
%
%   Stack assigns values of any "variable-specific" properties (e.g., VariableUnits
%   and VariableDescriptions) for the new data variable in S from the
%   corresponding property values for the first variable listed in DATAVARS.
%
%   STACK copies the remaining variables from U to S without stacking, by
%   replicating each of their values M times.  Since their values are constant
%   across each group of M rows in S, they serve to identify which row in
%   U a row in S came from, and can be used as grouping variables to
%   unstack S.
%
%   [S,IU] = STACK(U,DATAVARS) returns an index vector IU indicating
%   the correspondence between rows in S and those in U.  STACK creates
%   the "stacked" rows S(IU==I,:) using the "unstacked" row U(I,:).  In other
%   words, STACK creates S(J,:) using U(IU(J),DATAVARS).
%
%   Use the following parameter name/value pairs to control how variables in
%   U are converted to variables in S:
%
%      'ConstantVariables'   Variables in U to be copied to S without
%                            stacking.  A positive integer, a vector of
%                            positive integers, a variable name, a cell array
%                            containing one or more variable names, or a
%                            logical vector.  The default is all variables in
%                            U not specified in DATAVARS.
%      'NewDataVariableName' A name for the data variable to be created in S.
%                            The default is a concatenation of the names of the
%                            M variables that are stacked up.
%      'IndexVariableName'   A name for the new variable to be created in S
%                            that indicates the source of each value in the new
%                            data variable.  The default is based on the
%                            'NewDataVariableName' parameter.
%
%   You can also specify more than one group of data variables in U, each
%   of which will become a variable in S.  All groups must contain the same
%   number of variables.  Use a cell array to contain multiple parameter
%   values for DATAVARS, and a cell array of character vectors to contain multiple
%   'NewDataVariableName'.
%
%   Example: convert "unstacked format" data to "stacked format", and then back to
%   a different "unstacked format".
%
%   % Create a table indicating the amount of snowfall at three locations
%   % from five separate storms. 
%   Storm = categorical({'Storm1';'Storm2';'Storm3';'Storm4';'Storm5'});
%   Natick = [20;5;13;0;17];
%   Boston = [18;9;21;5;12];
%   Worcester = [26;10;16;3;15];
%   U = table(Storm,Natick,Boston,Worcester)
%
%   % Each row in this table contains data that apply to all locations.
%   % Stack the variables Natick, Boston, and Worcester into a single
%   % variable. Name the variable containing the stacked data Snowfall,
%   % and name the new indicator variable Town.   
%   S = stack(U,2:4, 'NewDataVariableName','Snowfall','IndexVariableName','Town')
%
%   % U contains one row for each storm, and now S contains three rows for
%   % each row in U. STACK repeated each value from the variable Storm
%   % three times to account for that. The categorical variable, Town,
%   % identifies which variable in U contains the corresponding Snowfall
%   % data. 
%
%   % Unstack the table to a different "unstacked" format to look at the
%   % snowfall for each storm represented in a column.
%   U2 = unstack(S,'Snowfall','Storm')
%
%   See also UNSTACK, JOIN, INNER2OUTER, ROWS2VARS.

%   Copyright 2012-2017 The MathWorks, Inc.

import matlab.internal.datatypes.matricize

pnames = {'ConstantVariables' 'NewDataVariableNames' 'IndexVariableName'};
dflts =  {                []                     []                  [] };

[constVars,tallVarNames,indicatorName,supplied] ...
    = matlab.internal.datatypes.parseArgs(pnames,dflts,varargin{:});

% Row labels are not allowed as a data variable. They are always treated as a
% constant variable.
rowLabelsName = a.metaDim.labels(1);
if any(strcmp(rowLabelsName,dataVars))
    a.throwSubclassSpecificError('stack:CantStackRowLabels');
end

% Convert dataVars or dataVars{:} to indices.  [] is valid, and does not
% indicate "default".
if isempty(dataVars)
    dataVars = {[]}; % guarantee a zero length list in a non-empty cell
elseif iscell(dataVars) && ~iscellstr(dataVars)
    for i = 1:length(dataVars)
        dataVars{i} = a.varDim.subs2inds(dataVars{i}); % each cell containing a row vector
    end
else
    dataVars = { a.varDim.subs2inds(dataVars) }; % a cell containing a row vector
end
allDataVars = cell2mat(dataVars);
nTallVars = length(dataVars);

% Reconcile constVars and dataVars.  The two must have no variables in common.
% If only dataVars is provided, constVars defaults to "everything else".
if supplied.ConstantVariables
    % Convert constVars to indices.  [] is valid, and does not indicate "default".
    % Ignore empty row labels, they are always treated as a const var.
    constVars = a.getVarOrRowLabelIndices(constVars,true); % a row vector
    if ~isempty(intersect(constVars,allDataVars))
        error(message('MATLAB:table:stack:ConflictingConstAndDataVars'));
    end
    % If the specified constant vars include the input's row labels, i.e.
    % any(constVarIndicess==0), those will automatically be carried over as the
    % output's row labels, so clear those from constVarIndices.
    constVars(constVars==0) = [];
else
    constVars = setdiff(1:size(a,2),allDataVars);
end
nConstVars = length(constVars);
constVarNames = a.varDim.labels(constVars);

% Make sure all the sets of variables are the same width.
m = unique(cellfun(@numel,dataVars));
if ~isscalar(m)
    error(message('MATLAB:table:stack:UnequalSizeDataVarsSets'));
end

% Replicate rows for each of the constant variables. This carries over
% properties of the wide table.
n = size(a,1);
ia = repmat(1:n,max(m,1),1); ia = ia(:);
b = a.subsref(struct('type',{'()'},'subs',{{ia constVars}})); % a(ia,constVars);
b_varDim = b.varDim;

aNames = a.varDim.labels;

if m > 0
    % Add the indicator variable and preallocate room in the data array
    vars = dataVars{1}(:);
    if nTallVars == 1
        % Unique the data vars for the indicator categories.  This will create
        % the indicator variable with categories ordered by var location in the
        % original table, not by first occurrence in the data.
        uvars = unique(vars,'sorted');
        indicator = categorical(repmat(vars,n,1),uvars,aNames(uvars));
    else
        indicator = repmat(vars,n,1);
    end
    b_varDim = b_varDim.createLike(nConstVars + 1 + nTallVars);
    b_varDim = b_varDim.setLabels(constVarNames,1:nConstVars); % fill the remaining names in later
    indicatorVarIdx = nConstVars + 1;
    b.data{indicatorVarIdx} = indicator;
    b.data{b_varDim.length} = [];
    
    % For each group of wide variables to reshape ...
    for i = 1:nTallVars
        vars = dataVars{i}(:);

        % Interleave the group of wide variables into a single tall variable
        if ~isempty(vars)
            szOut = size(a.data{vars(1)}); szOut(1) = b.rowDim.length;
            tallVar = a.data{vars(1)}(ia,:);
            for j = 2:m
                interleaveIdx = j:m:m*n;
                try
                    tallVar(interleaveIdx,:) = matricize(a.data{vars(j)});
                catch ME
                    msg = message('MATLAB:table:stack:InterleavingDataVarsFailed',a.varDim.labels{vars(j)});
                    throw(addCause(MException(msg.Identifier,'%s',getString(msg)), ME));
                end
            end
            b.data{indicatorVarIdx+i} = reshape(tallVar,szOut);
        end
    end
    
    % Generate default names for the stacked data var(s) if needed, avoiding conflicts
    % with existing var or dim names. If NewDataVariableName was given, duplicate names
    % are an error, caught by setLabels here or by checkAgainstVarLabels below.
    if ~supplied.NewDataVariableNames
        % These will always be valid, no need to call makeValidName
        tallVarNames = cellfun(@(c)strjoin(aNames(c),'_'),dataVars,'UniformOutput',false);
        avoidNames = [b_varDim.labels b.metaDim.labels];
        tallVarNames = matlab.lang.makeUniqueStrings(tallVarNames,avoidNames,namelengthmax);
    end
    try
        b_varDim = b_varDim.setLabels(tallVarNames,(indicatorVarIdx+1):b_varDim.length); % error if invalid, duplicate, or empty
    catch me
        if isequal(me.identifier,'MATLAB:table:DuplicateVarNames') ...
                && length(unique(tallVarNames)) == length(tallVarNames)
            % The tall var names must have been supplied, not the defaults.  Give
            % a more detailed err msg than the one from setLabels if there's a
            % conflict with existing var names.
            if nTallVars == 1
                if iscell(tallVarNames), tallVarNames = tallVarNames{1}; end
                error(message('MATLAB:table:stack:ConflictingNewDataVarName',tallVarNames));
            else
                error(message('MATLAB:table:stack:ConflictingNewDataVarNames'));
            end
        else
            rethrow(me);
        end
    end
    
    % Now that the data var names are OK, we can generate a default name for the
    % indicator var if needed, avoiding a conflict with existing var or dim names.
    % If IndexVariableName was given, a duplicate name is an error, caught by setLabels
    % here or by checkAgainstVarLabels below.
    if ~supplied.IndexVariableName
        % This will always be valid, no need to call makeValidName
        if nTallVars == 1
            indicatorName = [b_varDim.labels{indicatorVarIdx+1} '_' getString(message('MATLAB:table:uistrings:DfltStackIndVarSuffix'))];
        else
            indicatorName = getString(message('MATLAB:table:uistrings:DfltStackIndVarSuffix'));
        end
        avoidNames = [b_varDim.labels b.metaDim.labels];
        indicatorName = matlab.lang.makeUniqueStrings(indicatorName,avoidNames,namelengthmax);
    end
    try
        b_varDim = b_varDim.setLabels(indicatorName,indicatorVarIdx); % error if invalid, duplicate, or empty
    catch me
        if isequal(me.identifier,'MATLAB:table:DuplicateVarNames')
            % The index var name must have been supplied, not the default.  Give
            % a more detailed err msg than the one from setLabels if there's a
            % conflict with existing var names
            if iscell(indicatorName), indicatorName = indicatorName{1}; end
            error(message('MATLAB:table:stack:ConflictingIndVarName',indicatorName));
        else
            rethrow(me);
        end
    end
    
end

% Detect conflicts between the stacked var names (which may have been given by
% NewDataVariableName or IndexVariableName) and the original dim names.
b.metaDim = b.metaDim.checkAgainstVarLabels(b_varDim.labels);

% Copy per-var properties from constant vars and the first data var in each group
if m > 0
    firstDataVars = cellfun(@(x) x(1),dataVars(:)');
    b_varDim = b_varDim.moveProps(a.varDim,[constVars firstDataVars],[1:nConstVars nConstVars+1+(1:nTallVars)]);
else
    b_varDim = b_varDim.moveProps(a.varDim,constVars,1:nConstVars);
end
if b_varDim.hasDescrs
    newDescrs = b_varDim.descrs;
    newDescrs{indicatorVarIdx} = getString(message('MATLAB:table:uistrings:StackIndVarDescr'));
    b_varDim = b_varDim.setDescrs(newDescrs);
end
b.varDim = b_varDim;
