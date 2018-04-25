function [b,ia] = unstack(a,dataVars,indicatorVar,varargin)
%UNSTACK Unstack data from a single variable into multiple variables
%   U = UNSTACK(S,DATAVAR,INDVAR) converts the table or timetable S to an
%   equivalent table or timetable U that is in "unstacked format", by
%   "unstacking" a single variable in S into multiple variables in U. In general
%   U contains more variables, but fewer rows, than S.
%
%   DATAVAR specifies the data variable in S to unstack. INDVAR specifies an
%   indicator variable in S that determines which variable in U each value in
%   DATAVAR is unstacked into, as described below. If S is a table, UNSTACK
%   treats the remaining variables in S as grouping variables. Each unique
%   combination of their values defines a group of rows in S that will be
%   unstacked into a single row in U. If S is a timetable, UNSTACK ignores the
%   remaining variables and groups by the row times.
%
%   UNSTACK creates M data variables in U, where M is the number of unique
%   values in INDVAR. The values in INDVAR indicate which of those M variables
%   receive which values from DATAVAR. The J-th data variable in U contains
%   the values from DATAVAR that correspond to rows whose INDVAR value was the
%   J-th of the M possible values. Elements of those M variables for which no
%   corresponding data value in S exists contain a default value.
%
%   DATAVAR is a positive integer, a variable name, or a logical vector
%   containing a single true value. INDVAR is a positive integer, a variable
%   name, or a logical vector containing a single true value.
%
%   [U,IS] = UNSTACK(S,DATAVAR,INDVAR) returns an index vector IS
%   indicating the correspondence between rows in U and those in S. For
%   each row in U, IS contains the index of the first in the corresponding
%   group of rows in S.
%
%   Use the following parameter name/value pairs to control how variables in S
%   are converted to variables in U.
%
%      'GroupingVariables'  Grouping variables in S that define groups of
%                           rows. A positive integer, a vector of positive
%                           integers, a variable name, a cell array containing
%                           one or more variable names, or a logical vector.
%                           The default is all variables in S not listed
%                           in DATAVAR or INDVAR.
%
%      'ConstantVariables'  Variables in S to be copied to U without
%                           unstacking. The values for these variables in U
%                           are taken from the first row in each group in S,
%                           so these variables should typically be constant
%                           within each group. A positive integer, a vector of
%                           positive integers, a variable name, a cell array
%                           containing one or more variable names, or a logical
%                           vector. The default is no variables.
%
%      'NewDataVariableNames'  A cell array of character vectors containing names for the
%                           data variables to be created in U. Default is
%                           the group names of the grouping variable specified
%                           in INDVAR.
%
%      'AggregationFunction'  A function handle that accepts a subset of values
%                           from DATAVAR and returns a single value. UNSTACK
%                           applies this function to rows from the same group that
%                           have the same value of INDVAR. The function must
%                           aggregate the data values into a single value, and in
%                           such cases it is not possible to recover S from
%                           U using STACK. The default is @SUM for numeric
%                           data variables. For non-numeric variables, there is
%                           no default, and you must specify 'AggregationFunction'
%                           if multiple rows in the same group have the same
%                           values of INDVAR.
%
%   You can also specify more than one data variable in S, each of which
%   will become a set of M variables in U. In this case, specify DATAVAR
%   as a vector of positive integers, a cell array containing variable names,
%   or a logical vector. You may specify only one variable with INDVAR. The
%   names of each set of data variables in U are the name of the
%   corresponding data variable in S concatenated with the names specified
%   in 'NewDataVariableNames'. The function specified in 'AggregationFunction'
%   must return a value with a single row.
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
%   See also STACK, JOIN, INNER2OUTER, ROWS2VARS.

%   Copyright 2012-2017 The MathWorks, Inc.

pnames = {'GroupingVariables' 'ConstantVariables' 'NewDataVariableNames' 'AggregationFunction'};
dflts =  {                []                  []                     []                    [] };

[groupVars,constVars,wideVarNames,fun,supplied] ...
    = matlab.internal.datatypes.parseArgs(pnames,dflts,varargin{:});

% Row labels are not allowed as a data variable or an indicator variable, but
% are allowed as a grouping variable. Otherwise they are treated as a constant
% variable.
rowLabelsName = a.metaDim.labels(1);
if any(strcmp(rowLabelsName,dataVars))
    a.throwSubclassSpecificError('unstack:CantUnstackRowLabels');
end
if any(strcmp(rowLabelsName,indicatorVar))
    a.throwSubclassSpecificError('unstack:CantUnstackWithRowLabelsIndicator');
end

% Convert dataVars to indices. [] is valid, and does not indicate "default".
dataVars = a.varDim.subs2inds(dataVars); % a row vector
ntallVars = length(dataVars);

% Convert indicatorVar to an index.
indicatorVar = a.varDim.subs2inds(indicatorVar);
if ~isscalar(indicatorVar)
    error(message('MATLAB:table:unstack:MultipleIndVar'));
end

if supplied.AggregationFunction && ~isa(fun,'function_handle')
    error(message('MATLAB:table:unstack:InvalidAggregationFun'));
end

% Reconcile groupVars and dataVars. The two must have no variables in common.
% If only dataVars is provided, groupVars defaults to "everything else except
% the indicator" for table, or to "only the row times" for timetables.
if supplied.GroupingVariables
    % Convert groupVars to indices. [] is valid, and does not indicate "default".
    groupVars = a.getVarOrRowLabelIndices(groupVars); % a row vector
    if ~isempty(intersect(groupVars,dataVars))
        error(message('MATLAB:table:unstack:ConflictingGroupAndDataVars'));
    end
else
    % If the row labels are unique, there's no point in making them the default
    % grouping var. Otherwise use them by the default. This default for the grouping
    % vars may be adjusted below after looking at the specified constant vars.
    if a.rowDim.requireUniqueLabels
        groupVars = setdiff(1:size(a,2),[indicatorVar dataVars]);
    else
        groupVars = 0;
    end
end

% indicatorVar must not appear in groupVars or dataVars.
if ismember(indicatorVar,groupVars) || ismember(indicatorVar,dataVars)
    error(message('MATLAB:table:unstack:ConflictingIndVar'));
end

% Reconcile constVars with everything else. [] is the default.
if supplied.ConstantVariables
    % Ignore empty row labels, they are always treated as a const var.
    constVars = a.getVarOrRowLabelIndices(constVars,true); % a row vector
    if ~supplied.GroupingVariables
        groupVars = setdiff(groupVars,constVars);
    elseif any(ismember(constVars,groupVars))
        error(message('MATLAB:table:unstack:ConflictingConstVars'));
    end
    if any(ismember(constVars,dataVars)) || any(ismember(constVars,indicatorVar))
        error(message('MATLAB:table:unstack:ConflictingConstVars'));
    end
    % If the specified constant vars include the input's row labels, i.e.
    % any(constVars==0), those will automatically be carried over as the
    % output's row labels, so clear those from constVars.
    constVars(constVars==0) = [];
else
    constVars = [];
end

% Decide how to de-interleave the tall data, and at the same time create
% default names for the wide data vars.
aNames = a.varDim.labels;
[kdx,dfltWideVarNames] = a.table2gidx(indicatorVar);
nwideVars = length(dfltWideVarNames);

% Use default names for the wide data vars if needed. Make sure they're valid.
useDfltWideVarNames = ~supplied.NewDataVariableNames;
if useDfltWideVarNames
    wideVarNames = a.varDim.makeValidName(dfltWideVarNames(:)','warn'); % allow mods, these are never empty
end

% Create the wide table from the unique grouping var combinations. This carries
% over properties of the tall table. If the grouping vars include input's row
% labels, i.e. any(groupVars==0), the row labels part of the "unique grouping
% var combinations" will automatically be carried over as the output's row
% labels, so clear those from groupVars after getting the group indices.
[jdx,~,idx] = a.table2gidx(groupVars);
groupVars(groupVars==0) = [];
b = a.subsrefParens(struct('type',{'()'},'subs',{{idx groupVars}})); % b = a(idx,groupVars)
nrowsWide = size(b,1);
nrowsTall = size(a,1);

% Leave out rows with missing grouping or indicator var values
missing = isnan(jdx) | isnan(kdx);
jdx(missing) = [];
kdx(missing) = [];

% Append the constant variables
if ~isempty(constVars)
    c = a.subsrefParens(struct('type',{'()'},'subs',{{idx constVars}})); % c = a(idx,constVars)
    b = [b c];
end
b_varDim = b.varDim;

for t = 1:ntallVars
    % For each tall var ...
    tallVar = a.data{dataVars(t)};
    szOut = size(tallVar); szOut(1) = nrowsWide;
    
    % Preallocate room in the table
    j0 = b_varDim.length;
    wideVarIndices = j0 + (1:nwideVars);
    b_varDim = b_varDim.lengthenTo(j0+nwideVars); % fill the names in later
    b.data(wideVarIndices) = cell(1,nwideVars);
    
    % De-interleave the tall variable into a group of wide variables. The
    % wide variables will have the same class as the tall variable.
    %
    % Handle numeric types directly with accumarray
    if isnumeric(tallVar) || islogical(tallVar) % but not char
        [~,ncols] = size(tallVar); % possibly N-D
        
        % Create a fillVal for elements of the wide variables that receive no
        % tall values. This is NaN for float, 0 for int, false for logical.
        fillInNaNs = false;
        if isempty(fun)
            if isfloat(tallVar)
                fillVal = nan(1,'like',tallVar);
            else % isinteger(tallVar) || islogical(tallVar)
                fillVal = 0; % ACCUMARRAY sums integer/logical types in double, match that
            end
        else
            % The aggregation fun has to return something castable to tallVar's class,
            % and ACCUMARRAY requires that fillVal's class match the aggregation
            % function output. If tallVar uses NaN as fillVal, and the aggregation
            % fun returns something whose class can represent that, then no problem.
            % If tallVar uses zero as a fillVal, also no problem. In both cases, let
            % ACCUMARRAY put fillVal into empty cells. Otherwise, let ACCUMARRAY fill
            % in with zeros, but go back and fill in NaN explicitly.
            funVal = fun(tallVar(1));
            if ~(isnumeric(funVal) || islogical(funVal))
                error(message('MATLAB:table:unstack:BadAggFunValueClass', aNames{ dataVars( t ) }));
            elseif isfloat(tallVar) && isfloat(funVal)
                fillVal = nan(1,'like',funVal);
            else % isinteger(tallVar) || islogical(tallVar)
                if isnumeric(funVal)
                    fillVal = zeros(1,'like',funVal);
                else % islogical(funVal)
                    fillVal = false;
                end
            end
            fillInNaNs = isfloat(tallVar) && ~isfloat(funVal); % NaN would be lost
        end

        for k = 1:ncols
            tallVar_k = tallVar(~missing,k); % leave out rows with missing grouping/indicator
            if isempty(fun)
                wideVars_k = accumarray({jdx,kdx},tallVar_k,[nrowsWide,nwideVars],[],fillVal);
            else
                % ACCUMARRAY applies the function even on scalar cells, but not
                % on empty cells. Those get fillVal.
                wideVars_k = accumarray({jdx,kdx},tallVar_k,[nrowsWide,nwideVars],fun,fillVal);
            end
            
            % ACCUMARRAY sums integer/logical types in double, undo that. Or the
            % aggregation function may have returned a class different than tallVar.
            if ~isa(wideVars_k,class(tallVar))
                wideVars_k = cast(wideVars_k,'like',tallVar);
            end
            
            % Explicitly fill empty cells with NaN if necessary.
            if fillInNaNs
                fillInLocs = find(accumarray({jdx,kdx},0,[nrowsWide,nwideVars],[],1));
                wideVars_k(fillInLocs) = NaN; %#ok<FNDSB>, find converts numeric 0/1 to indices
            end

            for j = 1:nwideVars
                if k == 1
                    b.data{j0+j} = reshape(repmat(wideVars_k(:,j),1,ncols),szOut);
                else
                    b.data{j0+j}(:,k) = wideVars_k(:,j);
                end
            end
        end
        
    % Handle non-numeric types indirectly
    else
        % Create fillVal with same class as tallVar.
        if iscellstr(tallVar)
            % Need explicit empty string
            fillVal = {''};
        else
            % Let the variable define the fill value for empty cells
            tmp = tallVar(1); tmp(3) = tmp(1); fillVal = tmp(2); % intentionally a scalar
        end
        
        tallRowIndices = (1:nrowsTall)';
        tallRowIndices(missing) = []; % leave out rows with missing grouping/indicator
        if isempty(fun)
            % First make sure there are no repeated rows
            cellCounts = accumarray({jdx,kdx},1,[nrowsWide,nwideVars]);
            if any(cellCounts(:) > 1)
                error(message('MATLAB:table:unstack:MultipleRows'));
            end
            
            % Get the tall indices and pull values from tallVar
            wideRowIndices = accumarray({jdx,kdx},tallRowIndices,[nrowsWide,nwideVars]);
            for j = 1:nwideVars
                wideRowIndices_j = wideRowIndices(:,j);
                zeroInds = (wideRowIndices_j == 0);
                if any(zeroInds)
                    % Store a fill value at the end of tallVar for the zero indices
                    tallVar(nrowsTall+1,:) = fillVal;
                    wideRowIndices_j(zeroInds) = nrowsTall + 1;
                end
                % Create the wideVar with the same class as tallVar.
                b.data{j0+j} = reshape(tallVar(wideRowIndices_j,:),szOut);
            end
            
        else
            wideRowIndices = accumarray({jdx,kdx},tallRowIndices,[nrowsWide,nwideVars],@(x) {x});
            for j = 1:nwideVars
                % Create the wideVar with the same class as tallVar.
                wideVar_j = repmat(fillVal,[nrowsWide,size(tallVar,2)]);
                for i = 1:nrowsWide
                    % These indices may not be in order, because ACCUMARRAY does
                    % not guarantee that
                    indices_ij = wideRowIndices{i,j};
                    szFunIn = size(tallVar); szFunIn(1) = length(indices_ij);
                    val = fun(reshape(tallVar(indices_ij,:),szFunIn));
                    try
                        wideVar_j(i,:) = val;
                    catch ME
                        szFunOut = size(tallVar); szFunOut(1) = 1;
                        if size(val,1) > 1
                            % The value must be a single row
                            error(message('MATLAB:table:unstack:NonscalarAggFunValue'));
                        elseif ~isequal(size(val),szFunOut)
                            % The value must be the same trailing size as the data
                            error(message('MATLAB:table:unstack:BadAggFunValueSize', aNames{ dataVars( t ) }));
                        else
                            m = message('MATLAB:table:unstack:AssignmentError',aNames{dataVars(t)});
                            throw(addCause(MException(m.Identifier,'%s',getString(m)),ME));
                        end
                    end
                end
                b.data{j0+j} = reshape(wideVar_j,szOut);
            end
        end
    end
    
    if ntallVars == 1
        wideNames = wideVarNames;
    else
        wideNames = strcat(aNames{dataVars(t)},'_',wideVarNames);
    end
    if useDfltWideVarNames
        % If the wide var names have been constructed automatically, make sure
        % they don't conflict with the existing var names or the dim names.
        avoidNames = [b_varDim.labels(1:j0) b.metaDim.labels];
        wideNames = matlab.lang.makeUniqueStrings(cellstr(wideNames),avoidNames,namelengthmax);
    end
    
    % Called-supplied wide var names given by NewDataVariableNames may be duplicate,
    % empty, or invalid; setLabels catches errors here and checkAgainstVarLabels
    % catches conflicts with dim names below. Default names (those taken from the
    % indicator var's values) should never be duplicate or empty; they may have been
    % invalid, but they've already been fixed.
    try
        b_varDim = b_varDim.setLabels(wideNames,wideVarIndices); % error if invalid, duplicate, or empty
    catch me
        if isequal(me.identifier,'MATLAB:table:DuplicateVarNames') ...
                && length(unique(wideNames)) == length(wideNames)
            % The wide var names must have been supplied, not the defaults. Give
            % a more detailed err msg than the one from setLabels if there's a
            % conflict with existing var names
            error(message('MATLAB:table:unstack:ConflictingNewDataVarNames'));
        else
            rethrow(me);
        end
    end
end

% Detect conflicts between the wide var names (which may have been given by
% NewDataVariableNames) and the original dim names.
b.metaDim = b.metaDim.checkAgainstVarLabels(b_varDim.labels);

% Copy tall per-variable properties, appropriately replicated, to wide. 
repDataVars = repmat(dataVars,nwideVars,1);
b.varDim = b_varDim.moveProps(a.varDim,[groupVars constVars repDataVars(:)'],1:b_varDim.length);

% Put the wide table into "first occurrence" order of the tall table
[~,idxInv] = sort(idx);
b = subsref(b,struct('type',{'()'},'subs',{{idxInv ':'}})); % b(idxInv,:)
if nargout > 1
    ia = idx(idxInv);
end
