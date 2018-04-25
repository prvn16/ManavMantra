function b = varfun(fun,a,varargin)
%VARFUN Apply a function to each variable of a table or timetable.
%   B = VARFUN(FUN,A) applies the function FUN separately to each variable of the
%   table A, and returns the results in the table B. FUN is a function handle,
%   specified using @, to a function that takes one input argument and returns arrays
%   with the same number of rows each time it is called.  The I-th variable in B,
%   B{:,I}, is equal to FUN(A{:,I}).
%
%   B = VARFUN(FUN,A, 'PARAM1',val1, 'PARAM2',val2, ...) allows you to specify
%   optional parameter name/value pairs to control how VARFUN uses the variables
%   in A and how it calls FUN.  Parameters are:
%
%      'InputVariables'    - Specifies which variables in A are inputs to FUN.
%      'GroupingVariables' - Specifies one or more variables in A that define groups
%                            of rows.  Each group consists of rows in A that have the
%                            same combination of values in those variables.  VARFUN
%                            applies FUN to each group of rows within each of A's
%                            variables, rather than to each entire variable.  B has
%                            one row for each group when you specify 'OutputFormat'
%                            as 'uniform' or 'cell'.  When you specify 'OutputFormat'
%                            as 'table', the sizes of FUN's outputs determine how
%                            many rows of B correspond to each group.  For
%                            timetables, 'GroupingVariables' can be either the time
%                            vector or data variables, but not a mix of the two.
%
%   'GroupingVariables' and 'InputVariables' are each a positive integer, a
%   vector of positive integers, a variable name, a cell array containing one or
%   more variable names, or a logical vector.  'InputVariables' may also be a
%   function handle that returns a logical scalar.  In this case, only those
%   variables in A for which that function returns true are treated by VARFUN as
%   data variables.
%
%      'OutputFormat' - Specifies the form in which VARFUN returns the values
%                       computed by FUN.  Choose from the following:
%
%           'uniform'   - VARFUN concatenates the values into a vector.  FUN must
%                         return a scalar with the same type each time it is called.
%           'table'     - VARFUN returns a table with one variable for each variable
%                         in A (or each variable specified with 'InputVariables').
%                         For grouped computation, B also contains the grouping
%                         variables.  'table' allows you to use a function that
%                         returns values of different sizes or types for the different
%                         variables in A.  However, for ungrouped computation, FUN
%                         must return arrays with the same number of rows each time
%                         it is called.  For grouped computation, FUN must return
%                         values with the same number of rows each time it is called
%                         for a given group.  'table' is the default OutputFormat if
%                         A is a table.
%           'timetable' - VARFUN returns a timetable with one variable for each
%                         variable in A (or each variable specified with
%                         'InputVariables').  For grouped computation, B also
%                         contains the grouping variables.  B's time vector is
%                         created from the row times of A.  If these times do not
%                         make sense in the context of FUN, use 'table' OutputFormat.
%                         'timetable' is the default OutputFormat if A is a
%                         timetable.
%           'cell'      - B is a cell array.  'cell' allows you to use a function
%                         that returns values of different sizes or types.
%
%      'ErrorHandler' - a function handle, specifying the function VARFUN is to
%                       call if the call to FUN fails.   VARFUN calls the error
%                       handling function with the following input arguments:
%                       -  a structure with fields named "identifier", "message",
%                          "index", and "name" containing, respectively, the
%                          identifier of the error that occurred, the text of
%                          the error message, and the index and name of the
%                          variable at which the error occurred.  For grouped
%                          computation, the structure also contains a field
%                          named "group" containing the group index within that
%                          variable.
%                       -  the set of input arguments at which the call to the
%                          function failed.
%
%                       The error handling function should either throw an error,
%                       or return the same number and type and size of outputs as
%                       FUN.  These outputs are then returned in B.  For example:
%
%                          function [A, B] = errorFunc(S, varargin)
%                          warning(S.identifier, S.message); A = NaN; B = NaN;
%
%                       If an error handler is not specified, VARFUN rethrows
%                       the error from the call to FUN.
%
%   Examples:
%
%      Example 1 - Exponentiate all variables in a table.
%
%         t = table(randn(15,1),rand(15,1),'VariableNames',{'x' 'y'})
%         expVars = varfun(@exp,t)
%
%      Example 2 - Compute the means of all variables in a table.
%
%         t = table(randn(15,1),rand(15,1),'VariableNames',{'x' 'y'})
%         varMeans = varfun(@mean,t,'OutputFormat','uniform')
%
%      Example 3 - Compute the group-wise means, and return them as rows in a table.
%
%         t = table(randi(3,15,1),randn(15,1),rand(15,1),'VariableNames',{'g' 'x' 'y'})
%         groupMeansTable = varfun(@mean,t,'GroupingVariables','g','OutputFormat','table')
%
%      Example 4  - Timetable: Compute group-wise mean, grouping by time, and return
%      them as rows in a timetable.
%
%         dt = datetime(2016,1,1)+days([0 1 1 2 3 3])';
%         tt = timetable(dt, randn(6,1), randn(6,1), randn(6,1),'VariableNames',{'x' 'y' 'z'})
%         groupMeansTimetable = varfun(@mean,tt,'GroupingVariables','Time');
%
%   See also ROWFUN, CELLFUN, STRUCTFUN, ARRAYFUN.

%   Copyright 2012-2017 The MathWorks, Inc.

import matlab.internal.datatypes.ordinalString

% Set default output for table or timetable.
if isa(a, 'timetable')
    dfltOut = 4; % timetable
    allowedOutputFormats = {'uniform' 'table' 'cell' 'timetable' };
else
    dfltOut = 2; % table
    allowedOutputFormats = {'uniform' 'table' 'cell'};
end

pnames = {'GroupingVariables' 'InputVariables' 'OutputFormat'   'ErrorHandler'};
dflts =  {                []               []        dfltOut               [] };
[groupVars,dataVars,outputFormat,errHandler,supplied] ...
    = matlab.internal.datatypes.parseArgs(pnames, dflts, varargin{:});

% Do a grouped calculation if GroupingVariables is supplied, even if it's empty
% (the latter is the same as ungrouped but with a GroupCounts variable).
grouped = supplied.GroupingVariables;
if grouped
    groupVars = a.getVarOrRowLabelIndices(groupVars);
    isRowLabels = (groupVars == 0);
    groupByRowLabels = any(isRowLabels);
else
    groupByRowLabels = false;
end

if ~supplied.InputVariables
    if grouped
        dataVars = setdiff(1:a.varDim.length,groupVars);
    else
        dataVars = 1:a.varDim.length;
    end
elseif isa(dataVars,'function_handle')
    a_data = a.data;
    nvars = length(a_data);
    try
        isDataVar = zeros(1,nvars);
        for j = 1:nvars, isDataVar(j) = dataVars(a_data{j}); end
    catch ME
        if strcmp(ME.identifier,'MATLAB:matrix:singleSubscriptNumelMismatch')
            error(message('MATLAB:table:varfun:InvalidInputVariablesFun'));
        else
            rethrow(ME);
        end
    end
    dataVars = find(isDataVar);
else
    try
        dataVars = a.varDim.subs2inds(dataVars);
    catch ME
        a.subs2indsErrorHandler(dataVars,ME,'varfun');
    end
end
a_data = a.data;
a_varnames = a.varDim.labels;
ndataVars = length(dataVars);

if supplied.OutputFormat
    if isempty(outputFormat)
        error(message('MATLAB:table:varfun:InvalidOutputFormat',strjoin(allowedOutputFormats, ', ')));
    end
    outputFormat = find(strncmpi(outputFormat,allowedOutputFormats,length(outputFormat)));
    
    if isempty(outputFormat) || ~isscalar(outputFormat)
        error(message('MATLAB:table:varfun:InvalidOutputFormat',strjoin(allowedOutputFormats, ', ')));
    end
end
uniformOutput = (outputFormat == 1);
tableOutput = (outputFormat == 2);
timetableOutput = (outputFormat == 4);
tabularOutput = (outputFormat == 2 || outputFormat == 4);

if ~isa(fun,'function_handle')
    error(message('MATLAB:table:varfun:InvalidFunction'));
end
funName = func2str(fun);

if ~supplied.ErrorHandler
    errHandler = @(s,varargin) dfltErrHandler(grouped,funName,s,varargin{:});
end

% Create variable names for the output table based on the input
if tabularOutput
    % Anonymous/nested functions lead to unusable function names, use a default
    if isvarname(funName)
        funPrefix = funName;
    else
        funPrefix = 'Fun';
    end
    b_dataVarNames = a.varDim.makeValidName(strcat(funPrefix,{'_'},a_varnames(dataVars)),'warn');
end

if grouped
    [group,grpNames,grpRowLoc] = a.table2gidx(groupVars); % leave out categories not present in data
    ngroups = length(grpNames);
    grpRows = matlab.internal.datatypes.getGroups(group,ngroups);
    grpCounts = histc(group,1:ngroups);
    
    if uniformOutput || tabularOutput
        % Each cell will contain the result from applying FUN to one variable,
        % an ngroups-by-.. array with one row for each group's result
        b_data = cell(1,ndataVars);
    else % cellOutput
        % Each cell will contain the result from applying FUN to one group
        % within one variable
        b_data = cell(ngroups,ndataVars);
    end
    
    % Each cell will contain the result from applying FUN to one group
    % within the current variable
    outVals = cell(ngroups,1);
    if timetableOutput && ~groupByRowLabels
        outTime = cell(ngroups,1);
    end
    grpNumRows = ones(1,ngroups); % need this even when ndataVars is 0
    uniformClass = '';
    for jvar = 1:ndataVars
        jj = dataVars(jvar);
        varname_j = a_varnames{jj};
        for igrp = 1:ngroups
            inArg = getVarRows(a_data{jj},grpRows{igrp});
            try
                outVals{igrp} = fun(inArg);
            catch ME
                s = struct('identifier',ME.identifier, 'message',ME.message, 'index',jj, 'name',varname_j, 'group',igrp);
                outVals{igrp} = errHandler(s,inArg);
            end
        end
        if uniformOutput
            % For each group of rows, fun's output must have the same type across all variables.
            if jvar == 1 && ngroups > 0
                uniformClass = class(outVals{1});
            end
            b_data{jvar} = vertcatWithUniformScalarCheck(outVals,uniformClass,funName,varname_j);
        elseif tabularOutput
            % For each group of rows, fun's output must have the same number of rows across
            % all variables. Only do this the first time through the loop over variables.
            if jvar == 1 && ngroups > 0
                for igrp = 1:ngroups
                    grpNumRows(igrp) = size(outVals{igrp},1); 
                    if timetableOutput && ~groupByRowLabels
                        % Save the leading row times for each group, as many as there are output
                        % rows for each group.
                        if grpNumRows(igrp) <= size(grpRows{igrp},1)
                            outTime{igrp} = a.rowDim.labels(grpRows{igrp}(1:grpNumRows(igrp)));
                        else
                            error(message('MATLAB:table:varfun:TimetableCannotGrow',funName));
                        end
                    end
                end
            end
            b_data{jvar} = vertcatWithNumRowsCheck(outVals,grpNumRows,funName,varname_j);                
        else % cellOutput
            b_data(:,jvar) = outVals;
        end
    end
    
    if uniformOutput
        b = [b_data{:}]; % already validated: all ngroups-by-1, same class
    elseif tabularOutput
        % Create the output by first concatenating the unique grouping var combinations, one row
        % per group, and the group counts. Replicate to match the number of rows from the function
        % output for each group, and concatenate that with the function output.
        
        % Get the grouping variables for the output from the first row in each group of
        % rows in the input. If the grouping vars include input's row labels, i.e.
        % any(groupVars==0), the row labels part of the "unique grouping var combinations"
        % are automatically carried over.
        bg = a.subsrefParens({grpRowLoc,groupVars(~isRowLabels)});
        
        if tableOutput && isa(a,'timetable')
            % Convert to a table, discarding the row times but preserving the grouping
            % variable metadata and the second dim name.
            bg = table.init(bg.data, ...
                            bg.rowDim.length, {}, ...
                            bg.varDim.length, bg.varDim.labels, ...
                            a.metaDim.labels(2));
            bg.varDim = bg.varDim.moveProps(a.varDim,groupVars(~isRowLabels),find(~isRowLabels)); %#ok<FNDSB>
        end
        if bg.rowDim.requireUniqueLabels
            assert(~bg.rowDim.requireLabels)
            % Remove existing row names. Could assign row names using grpNames, but when the
            % function returns multiple rows (e.g. a "within-groups" transformation
            % function), ensuring that the row names are unique is time-consuming, and in
            % any case group names are really only useful when there is only one grouping
            % variable.
            bg.rowDim = bg.rowDim.removeLabels();
            if groupByRowLabels
                % When grouping by row labels, add them as an explicit grouping variable in the
                % output table. There's a guaranteed var/dim name collision if the input was a
                % table, a possible collision if the input was a timetable. Modify the existing
                % row labels dim name if necessary to avoid the collision.
                gvnames = [bg.varDim.labels a.metaDim.labels(1)];
                bg.metaDim = bg.metaDim.checkAgainstVarLabels(gvnames,'silent');
                bg.data{end+1} = a.rowDim.labels(grpRowLoc);
                bg.varDim = bg.varDim.lengthenTo(bg.varDim.length+1,{a.metaDim.labels{1}});
                if ~isscalar(groupVars)
                    % Put the row labels grouping var in its specified order among the other
                    % grouping vars, insert multiple copies if specified more than once.
                    reord = repmat(bg.varDim.length,1,bg.varDim.length);
                    reord(~isRowLabels) = 1:sum(~isRowLabels);
                    bg = bg.subsrefParens({':',reord});
                end
            end
        end
        
        % Replicate rows of the grouping vars and the group count var to match the
        % number of rows in the function output for each group.
        bg = bg.subsrefParens({repelem(1:ngroups,grpNumRows),':'});
        grpCounts = grpCounts(repelem(1:ngroups,grpNumRows),1);
        
        if timetableOutput && ~groupByRowLabels && any(grpNumRows > 1)
            % When there are multiple rows per group in the output, subsrefParens will have
            % replicated values of the first row time within each group. That's correct
            % when grouping by time, but otherwise use the "leading" row times saved earlier.
            b_time = vertcat(outTime{:});
            bg.rowDim = bg.rowDim.setLabels(b_time);
        end
        
        % Make sure that constructed var names don't clash with the grouping var names
        % or the dim names.
        vnames = [{'GroupCount'} b_dataVarNames];
        avoidVarNames = [bg.metaDim.labels bg.varDim.labels];
        vnames = matlab.lang.makeUniqueStrings(vnames,avoidVarNames,namelengthmax);
        
        b = bg;
        b.data = [b.data {grpCounts} b_data];
        b.varDim = b.varDim.lengthenTo(b.varDim.length+length(vnames),vnames);
    else % cellOutput
        b = b_data;
    end
    
else % ungrouped
    b_data = cell(1,ndataVars);
    for jvar = 1:ndataVars
        jj = dataVars(jvar);
        varname_j = a_varnames{jj};
        try
            b_data{jvar} = fun(a_data{jj});
        catch ME
            s = struct('identifier',ME.identifier, 'message',ME.message, 'index',jj, 'name',varname_j);
            b_data{jvar} = errHandler(s,a_data{jj});
        end
    end
    if uniformOutput
        b = horzcatWithUniformScalarCheck(b_data,funName,a_varnames(dataVars));
    elseif isa(a,'timetable') && tableOutput % table output from a timetable; ungrouped case
        % Make sure the generated output var names don't clash with the dim names.
        newDimNames = [matlab.internal.tabular.private.metaDim.dfltLabels(1), a.metaDim.labels(2)];
        b_varnames = matlab.lang.makeUniqueStrings(b_dataVarNames,newDimNames,namelengthmax);
        
        % Check that fun returned equal-length outputs for all vars, and create a table
        % from those outputs. Discard the input's row times and all per-variable metadata.
        [b_data,b_height] = numRowsCheck(b_data);
        b = table.init(b_data, ...
                       b_height, {}, ...
                       ndataVars, b_varnames, ...
                       a.metaDim.labels(2));
    elseif tabularOutput
        if ndataVars > 0
            % Check that fun returned equal-length outputs for all vars, then copy the
            % input and overwrite its data with fun's outputs.
            b = a;
            [b.data,b_height] = numRowsCheck(b_data);
            
            % Update the var names, but discard per-variable metadata. Make sure the
            % generated output var names don't clash with the dim names.
            b_varnames = matlab.lang.makeUniqueStrings(b_dataVarNames,a.metaDim.labels,namelengthmax);
            b.varDim = matlab.internal.tabular.private.varNamesDim(length(b_varnames),b_varnames);
            
            % In general the output rows need not correspond to the input rows, but if row
            % labels are required, copy as many as needed from the input. Otherwise discard
            % the input's row labels.
            if a.rowDim.requireLabels
                if b_height > a.rowDim.length
                    error(message('MATLAB:table:varfun:TimetableCannotGrow',funName));
                end
                b.rowDim = b.rowDim.createLike(b_height,a.rowDim.labels(1:b_height));
            else
                b.rowDim = b.rowDim.createLike(b_height,{});
            end
        else
            % Ungrouped varfun on an Nx0 input results in a 0x0 output.
            b = a.subsrefParens({[],[]});
        end
    else % cellOutput
        b = b_data;
    end
end


%-------------------------------------------------------------------------------
function [varargout] = dfltErrHandler(grouped,funName,s,varargin) %#ok<STOUT>
import matlab.internal.datatypes.ordinalString
if grouped
    m = message('MATLAB:table:varfun:FunFailedGrouped',funName,ordinalString(s.group),s.name,s.message);
else
    m = message('MATLAB:table:varfun:FunFailed',funName,s.name,s.message);
end
throw(MException(m.Identifier,'%s',getString(m)));


%-------------------------------------------------------------------------------
function var_ij = getVarRows(var_j,i)
if ismatrix(var_j)
    var_ij = var_j(i,:); % without using reshape, may not have one
else
    % Each var could have any number of dims, no way of knowing,
    % except how many rows they have.  So just treat them as 2D to get
    % the necessary rows, and then reshape to their original dims.
    sizeOut = size(var_j); sizeOut(1) = numel(i);
    var_ij = reshape(var_j(i,:), sizeOut);
end


%-------------------------------------------------------------------------------
function b_data = horzcatWithUniformScalarCheck(b_data,funName,varnames)
nvars = length(b_data);
if nvars > 0
    for jvar = 1:nvars
        if ~isscalar(b_data{jvar})
            error(message('MATLAB:table:varfun:NotAScalarOutput',funName,varnames{jvar}));
        elseif jvar == 1
            uniformClass = class(b_data{1});
        elseif ~isa(b_data{jvar},uniformClass)
            c = class(b_data{jvar});
            error(message('MATLAB:table:varfun:MismatchInOutputTypes',funName,c,uniformClass,varnames{jvar}));
        end
    end
    b_data = horzcat(b_data{:});
else
    % fun is assumed to return a scalar, so in general this function returns a row
    % vector, and this empty edge case should be continuous as a 1x0. If there are
    % no vars, then fun has not been applied to anything, so no way to know what type
    % fun would return. Default to double.
    b_data = zeros(1,0);
end


%-------------------------------------------------------------------------------
function outVals = vertcatWithUniformScalarCheck(outVals,uniformClass,funName,varname)
import matlab.internal.datatypes.ordinalString
ngroups = length(outVals);
if ngroups > 0
    for igrp = 1:ngroups
        if ~isscalar(outVals{igrp})
            error(message('MATLAB:table:varfun:NotAScalarOutputGrouped',funName,ordinalString(igrp),varname));
        elseif ~isa(outVals{igrp},uniformClass)
            c = class(outVals{igrp});
            error(message('MATLAB:table:varfun:MismatchInOutputTypesGrouped',funName,c,uniformClass,ordinalString(igrp),varname));
        end
    end
    outVals = vertcat(outVals{:});
else
    % fun is assumed to return a scalar, so in general this function returns a
    % column vector, and this empty edge case should be continuous as a 0x1. If
    % there are no vars, then fun has not been applied to anything, so no way to
    % know what type fun would return. Default to double.
    outVals = zeros(0,1);
end


%-------------------------------------------------------------------------------
function outVals = vertcatWithNumRowsCheck(outVals,grpNumRows,funName,varname)
import matlab.internal.datatypes.ordinalString
ngroups = length(outVals);
if ngroups > 0
    for igrp = 1:ngroups
        if size(outVals{igrp},1) ~= grpNumRows(igrp)
            error(message('MATLAB:table:varfun:GroupRowsMismatch',funName,ordinalString(igrp),varname));
        end
    end
    try
        outVals = vertcat(outVals{:});
    catch ME
        error(message('MATLAB:table:varfun:VertcatFailed',funName,varname,ME.message));
    end
else
    % If there are no groups, then fun has not been applied to anything, so no way
    % to know what type and size fun would return. Default to [].
    outVals = zeros(0,0);
end


%-------------------------------------------------------------------------------
function [outVals,n] = numRowsCheck(outVals)
nvars = length(outVals);
if nvars > 0
    n = size(outVals{1},1);
    for j = 2:nvars
        if size(outVals{j},1) ~= n
            error(message('MATLAB:table:UnequalVarLengths'));
        end
    end
else
    n = 0;
end
