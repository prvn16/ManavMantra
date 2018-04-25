function b = splitvars(a,varsToSplit,varargin)
%SPLITVARS Split multi-column variables in table or timetable.
%   T2 = SPLITVARS(T1) splits all multi-column variables in T1 so that they
%   are single-column variables in T2. All single-column variables from T1
%   are unaltered. 
%   - If a variable in T1 has multiple columns, then SPLITVARS makes unique
%   names for the new variables in T2 from the name of the original
%   variable in T1.
%   - If a variable in T1 is, itself, a table, then SPLITVARS uses the name
%   of that table and the names of its variables to make unique names for
%   the new variables in T2.
%
%   T2 = SPLITVARS(T1, VARS) splits only the table variables specified by
%   VARS. VARS is a positive integer, a vector of positive integers, a
%   variable name, a cell array containing one or more variable names, or a
%   logical vector.
%
%   T2 = SPLITVARS(T1, VARS, 'NewVariableNames', NEWNAMES) specifies
%   NEWNAMES as the names of the variables that are split and copied to T2.
%
%   See also ADDVARS, REMOVEVARS, MOVEVARS, MERGEVARS.

%   Copyright 2017 The MathWorks, Inc.

import matlab.internal.datatypes.matricize

% Find the variables that are not simply column vectors. They can be either
% multi-column matrices, higher-dimension arrays, or tables. For
% higher-dimension arrays, later they are matricized before splitting the
% 2nd dimension into multiple variables.
nvars = a.varDim.length;
widthVars = zeros([1,nvars]);
isTabularVars = false([1,nvars]);
for ii= 1:nvars
    data = a.data{ii};
    isTabularVars(ii) = isa(data, 'tabular');
    sz = size(data);
    sz(1) = [];
    widthVars(ii) = prod(sz);
end
if nargin < 2
    varsToSplit = widthVars > 1 | isTabularVars;
end
if nargin > 2
    pnames = {'NewVariableNames'};
    dflts =  {                  []};
    [splitVarNames,supplied] ...
        = matlab.internal.datatypes.parseArgs(pnames, dflts, varargin{:});
else
    splitVarNames = [];
    supplied.NewVariableNames = false;
end
if isa(varsToSplit,'vartype')
    error(message('MATLAB:table:splitvars:VartypeInvalidVars'))
end
varsToSplit = a.varDim.subs2inds(varsToSplit);
b = a.subsrefParens({':',~ismember(1:nvars,varsToSplit)});

if numel(unique(varsToSplit)) ~= numel(varsToSplit)
    % Vars being split should not have duplicates
    error(message('MATLAB:table:splitvars:DuplicateVars'));    
end

% Check if there are any duplicate names between the tables being split,
% and set the flag to true to fix the names later.
duplicateInnerVarnames = false;
vars = a.data(:,varsToSplit(isTabularVars(varsToSplit))); % extract only tabular vars from those being split
innerVarNames = {};
for i = 1:numel(vars)
	innerVarNames = [innerVarNames vars{i}.varDim.labels]; %#ok<AGROW>
end

if numel(unique(innerVarNames)) ~= numel(innerVarNames)
    % Duplicate variable name found from inner tables being split, set the
    % flag to true.
    duplicateInnerVarnames = true;
end

% If splitting multiple variable and NewVariableNames is provided, make
% sure that it's a cell array the same length as the number of variables to
% split, with each cell a cellstr of varnames.
if supplied.NewVariableNames && numel(varsToSplit) > 1
    if numel(varsToSplit) ~= length(splitVarNames)
        error(message('MATLAB:table:splitvars:IncorrectNumVarnamesMultisplit'));
    end
    for v = 1:numel(varsToSplit)
        if ~iscellstr(splitVarNames{v})
            error(message('MATLAB:table:splitvars:IncorrectNumVarnamesMultisplit'));
        end
    end
end

newInds = varsToSplit;

% Loop through each variable to split, create separate tables.
for ii = 1:numel(varsToSplit)
    var = a.subsrefDot({varsToSplit(ii)});
    varname = a.varDim.labels{varsToSplit(ii)};
    istabularVar = isTabularVars(varsToSplit(ii));
    widthVar = widthVars(varsToSplit(ii));
    
    
    % Split
    if ~istabularVar
        if ~ismatrix(var)
            var = matricize(var);
        end
        newvars = num2cell(var,1);
    else % istabular
        newvars = var.data;
        if var.rowDim.hasLabels
            newvars = [{var.rowDim.labels} newvars]; %#ok<AGROW>
        end
    end
    
    % Get new var names to use for after splitting
    if ~supplied.NewVariableNames
        if widthVar == 1 && ~istabularVar
            % If the given var to split has 1 column, and new variable
            % names are not given take the original variable name.
            newvarnames = varname;
        elseif ~istabularVar
            newvarnames = matlab.internal.datatypes.numberedNames([varname,'_'],1:widthVar);
        else % istabular: use existing names from table being split.
            newvarnames = var.varDim.labels;
            % If there are conflicts with existing varnames, add table name
            % at the front.
            if any(ismember(newvarnames,b.varDim.labels)) || duplicateInnerVarnames
                newvarnames = strcat(varname, '_', newvarnames);
            end
            if var.rowDim.hasLabels
                newvarnames = [[varname '_' var.metaDim.labels{1}] newvarnames];
            end
        end
        % Make sure the names are unique w.r.t existing variables.
        newvarnames = matlab.lang.makeUniqueStrings(newvarnames,[b.varDim.labels,b.metaDim.labels],namelengthmax);
    else % supplied.NewVariableNames
        % Convenience, if they are splitting multiple variables, treat each
        % cell of the cell array as containing the variable names for each
        % variable being split. If they are splitting a single variable,
        % the cell array contains names for that one specific variable.
        if ~isscalar(varsToSplit)
            newvarnames = splitVarNames{ii};
        else
            newvarnames = splitVarNames;
        end
    end
    
    % Insert the new split variable, with the new names.
    b = addvars(b,newvars{:},'Before',newInds(ii),'NewVariableNames',newvarnames);
    if isa(var,'table')
        % Move per-variable metadata from the original nested table var
        % into the newly split vars in b.
        b.varDim = b.varDim.moveProps(var.varDim, 1:var.varDim.length, b.varDim.subs2inds(newvarnames));
    else
        % Move per-var metadata from the varsToSplit in a into the newly
        % split vars in b, replicating it to all the split vars.
        b.varDim = b.varDim.moveProps(a.varDim, varsToSplit(ii), b.varDim.subs2inds(newvarnames));
    end
    
    % update indices based on the width of the added split vars (note that
    % the unspit variable counts as one, so subtract 1):
    newInds = newInds + length(newvars)-1;
end
