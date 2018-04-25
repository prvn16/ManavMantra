function b = rowfun(fun,a,varargin)
%ROWFUN Apply a function to rows of a table or timetable.
%   B = ROWFUN(FUN,A) applies the function FUN to each row of the table A, and
%   returns the results in the table B.  B contains one variable for each output of
%   FUN.  FUN accepts M separate inputs, where M is SIZE(A,2).
%
%   B = ROWFUN(FUN,A, 'PARAM1',val1, 'PARAM2',val2, ...) allows you to specify
%   optional parameter name/value pairs to control how ROWFUN uses the variables
%   in A and how it calls FUN.  Parameters are:
%
%      'InputVariables'      - Specifies which variables in A are inputs to FUN.
%      'GroupingVariables'   - Specifies one or more variables in A that define groups
%                              of rows.  Each group consists of rows in A that have the
%                              same combination of values in those variables.  ROWFUN
%                              applies FUN to each group of rows, rather than separately
%                              to each row of A.  B has one row for each group.  For
%                              timetables, specify either the row times by name or
%                              variables from A.  When you specify grouping variables
%                              as variables from A, you cannot include row times as
%                              one of the grouping variables.  
%
%   'GroupingVariables' and 'InputVariables' are each a positive integer, a
%   vector of positive integers, a variable name, a cell array containing one or
%   more variable names, or a logical vector.  'InputVariables' may also be a
%   function handle that returns a logical scalar.  In this case, ROWFUN treats
%   as data variables only those variables in A for which that function returns
%   true.
%
%      'SeparateInputs'      - Specifies whether FUN expects separate inputs, or one
%                              vector containing all inputs.  When true (the default),
%                              ROWFUN calls FUN with one argument for each data variable.
%                              When false, ROWFUN creates the input vector to FUN by
%                              concatenating the values in each row of A, and the data
%                              variables in A must be compatible for that concatenation.
%      'ExtractCellContents' - When true, ROWFUN extracts the contents of cell variables
%                              in A and passes the values, rather than the cells, to FUN.
%                              Default is false.  This parameter is ignored when
%                              SeparateInputs is false.  For grouped computation, the
%                              values within each group in a cell variable must allow
%                              vertical concatenation.
%      'OutputVariableNames' - Specifies the variable names for the outputs of FUN.
%      'NumOutputs'          - Specifies the number of outputs with which ROWFUN
%                              calls FUN.  This may be less than the number of
%                              output arguments that FUN declares, and may be zero.
%      'OutputFormat'        - Specifies the form in which ROWFUN returns the values
%                              computed by FUN.  Choose from the following:
%
%           'uniform'   - ROWFUN concatenates the values into a vector.  All of FUN's
%                         outputs must be scalars with the same type.
%           'table'     - ROWFUN returns a table with one variable for each output of
%                         FUN.  For grouped computation, B also contains the grouping
%                         variables.  'table' allows you to use a function that returns
%                         values of different sizes or types.  However, for ungrouped
%                         computation, all of FUN's outputs must have one row each
%                         time it is called.  For grouped computation, all of FUN's
%                         outputs for one call must have the same number of rows.
%                         'table' is the default OutputFormat if A is a table.
%           'timetable' - ROWFUN returns a timetable with one variable for each
%                         output of FUN.  For grouped computation, B also
%                         contains the grouping variables.  B's time vector is
%                         created from the row times of A.  If these times do not
%                         make sense in the context of FUN, use 'table' OutputFormat.
%                         For example, when you calculate the means of groups of
%                         data, it might not make sense to return the first row
%                         time of each group as a row time that labels the group. If
%                         this is the case for your data, then return the grouped
%                         variables in a table. 'timetable' is the default
%                         OutputFormat if A is a timetable.
%           'cell'    -   B is a cell array.  'cell' allows you to use a function
%                         that returns values of different sizes or types.
%
%      'ErrorHandler' - a function handle, specifying the function ROWFUN is to
%                       call if the call to FUN fails.   ROWFUN calls the error
%                       handling function with the following input arguments:
%                       -  a structure with fields named "identifier", "message",
%                          and "index" containing, respectively, the identifier
%                          of the error that occurred, the text of the error
%                          message, and the row or group index at which the error
%                          occurred.
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
%                       If an error handler is not specified, ROWFUN rethrows
%                       the error from the call to FUN.
%  
%   Examples:
%
%      Example 1 - Simulate a geometric brownian motion model for a range of parameters
%         mu = [-.5; -.25; 0; .25; .5];
%         sigma = [.1; .2; .3; .2; .1];
%         params = table(mu,sigma);
%         stats = rowfun(@gbmSim,params, ...
%                           'OutputVariableNames',{'simulatedMean' 'trueMean' 'simulatedStd' 'trueStd'});
%         [params stats]
%
%         function [m,mtrue,s,strue] = gbmSim(mu,sigma)
%         % Discrete approximation to geometric Brownian motion
%         numReplicates = 1000; numSteps = 100;
%         y0 = 1;
%         t1 = 1;
%         dt = t1 / numSteps;
%         y1 = y0*prod(1 + mu*dt + sigma*sqrt(dt)*randn(numSteps,numReplicates));
%         m = mean(y1); s = std(y1);
%         % Theoretical values
%         mtrue = y0 * exp(mu*t1); strue = mtrue * sqrt(exp(sigma^2*t1) - 1);
%
%      Example 2 - Compute the average difference between a pair of variables, by group.
%         t = table(randi(3,15,1),randn(15,1),rand(15,1),'VariableNames',{'g' 'x' 'y'})
%         rowfun(@(x,y) mean(x-y),t,'GroupingVariable','g', ...
%                        'InputVariables',{'x' 'y'}, 'OutputVariableName','MeanDiff')
%
%      Example 3 - Convert units of ozone air quality timeseries data
%         Time = datetime(2015,12,31,20,0,0)+hours(0:8)';
%         OzoneData = [32.5 32.3 31.7 32.0 62.5 61.0 60.8 61.2 60.3]';
%         Unit = categorical([1 1 1 1 2 2 2 2 2]', [1 2], {'ppbv', 'ug_m3'});
%         tt = timetable(Time, OzoneData,Unit);
%         % The unit changes between years of data.  Create a function to convert
%         % ug/m3 to ppbv.
%         function dataPPBV = OzoneConcToMixingRatio(data,unit)
%           if unit == 'ppbv'
%               dataPPBV = data;
%           elseif unit == 'ug_m3'
%               % Assume standard T,P.
%               dataPPBV = data./2.00;
%           else
%               dataPPBV = nan;
%           end
%         end
%         
%         % Use rowfun to make a timetable with consistent units for all data
%         ttPPBV = rowfun(@OzoneConcToMixingRatio, tt, 'OutputVariableName','Ozone_ppbv')
%
%      Example 4 - Find largest outlier from annual mean in terms of number of standard deviations
%         % Make some sample data in a table
%         Time = datetime(2016,3,1) + days(randi(1000,50,1));
%         data = randn(50,1)+3;
%         tt = timetable(Time,data);
%         % Shift time to yearly
%         tt.Time = dateshift(tt.Time,'start','year');
%         % Use rowfun to group and normalize to zero mean and unit standard deviation.
%         rf = rowfun(@(x) max(abs((x-mean(x))./std(x))), tt, 'GroupingVariables','Time', 'OutputVariableName', 'MaxStdDev')
%
%   See also VARFUN, CELLFUN, STRUCTFUN, ARRAYFUN.

%   Copyright 2012-2017 The MathWorks, Inc.

import matlab.internal.datatypes.ordinalString
import matlab.internal.datatypes.isCharString
import matlab.internal.datatypes.isScalarInt
import matlab.internal.datatypes.validateLogical

% Set default output for table or timetable.
if isa(a, 'timetable')
    dfltOut = 4; % timetable
    allowedOutputFormats = {'uniform' 'table' 'cell' 'timetable' };
else
    dfltOut = 2; % table
    allowedOutputFormats = {'uniform' 'table' 'cell'};
end

pnames = {'GroupingVariables' 'InputVariables' 'OutputFormat' 'NumOutputs' 'OutputVariableNames' 'SeparateInputs' 'ExtractCellContents'  'ErrorHandler'};
dflts =  {                []               []        dfltOut            1                    {}             true                 false              [] };
[groupVars,dataVars,outputFormat,nout,outNames,separateArgs,extractCells,errHandler,supplied] ...
    = matlab.internal.datatypes.parseArgs(pnames, dflts, varargin{:});

% Do a grouped calculation if GroupingVariables is supplied, even if it's empty
% (the latter is the same as ungrouped but with a GroupCounts variable).
grouped = supplied.GroupingVariables;
if grouped
    groupVars = a.getVarOrRowLabelIndices(groupVars);
    isRowLabels = (groupVars == 0);
    groupByRowLabels = any(isRowLabels);
    
    [group,grpNames,grpRowLoc] = a.table2gidx(groupVars); % leave out categories not present in data
    ngroups = length(grpNames);
    grpRows = matlab.internal.datatypes.getGroups(group,ngroups);
    grpCounts = histc(group,1:ngroups); % ignores NaNs in group
else
    groupByRowLabels = false;
    ngroups = a.rowDim.length;
    grpRows = num2cell(1:ngroups);
end

if ~supplied.InputVariables
    dataVars = setdiff(1:a.varDim.length,groupVars);
elseif isa(dataVars,'function_handle')
    a_data = a.data;
    nvars = length(a_data);
    try
        isDataVar = zeros(1,nvars);
        for j = 1:nvars, isDataVar(j) = dataVars(a_data{j}); end
    catch ME
        if strcmp(ME.identifier,'MATLAB:matrix:singleSubscriptNumelMismatch')
            error(message('MATLAB:table:rowfun:InvalidInputVariablesFun'));
        else
            rethrow(ME);
        end
    end
    dataVars = find(isDataVar);
else
    try
        dataVars = a.varDim.subs2inds(dataVars);
    catch ME
        a.subs2indsErrorHandler(dataVars,ME,'rowfun');
    end
end

if ~isa(fun,'function_handle')
    error(message('MATLAB:table:rowfun:InvalidFunction'));
end
funName = func2str(fun);

if supplied.OutputFormat
    if isempty(outputFormat)
        error(message('MATLAB:table:rowfun:InvalidOutputFormat',strjoin(allowedOutputFormats, ', ')));
    end
    outputFormat = find(strncmpi(outputFormat,allowedOutputFormats,length(outputFormat)));
    if isempty(outputFormat) || ~isscalar(outputFormat) % catch no match or ambiguous match
        error(message('MATLAB:table:rowfun:InvalidOutputFormat',strjoin(allowedOutputFormats, ', ')));
    end
end
uniformOutput = (outputFormat == 1);
tableOutput = (outputFormat == 2);
timetableOutput = (outputFormat == 4);
tabularOutput = (outputFormat == 2 || outputFormat == 4);

if supplied.NumOutputs && ~isScalarInt(nout,0)
    error(message('MATLAB:table:rowfun:InvalidNumOutputs'));
end

if supplied.OutputVariableNames
    if isCharString(outNames), outNames = {outNames}; end
    if supplied.NumOutputs
        if length(outNames) ~= nout
            error(message('MATLAB:table:rowfun:OutputNamesWrongLength'));
        end
    else
        nout = length(outNames);
    end
else
    % If neither NumOutputs nor OutputVariableNames is given, we could use
    % nargout to try to guess the number of outputs, but that doesn't work for
    % anonymous or varargout functions, and for many ordinary functions will be
    % the wrong guess because the second, third, ... outputs are not wanted.
    
    if tabularOutput
        % Choose default names based on the locations in the output table
        if grouped
            ngroupVars = sum(~isRowLabels) + (tableOutput && groupByRowLabels);
            outNames = a.varDim.dfltLabels(ngroupVars+1+(1:nout));
        else
            outNames = a.varDim.dfltLabels(1:nout);
        end
    end
end

extractCells = validateLogical(extractCells,'ExtractCellContents');
separateArgs = validateLogical(separateArgs,'SeparateInputs');

if ~supplied.ErrorHandler
    errHandler = @(s,varargin) dfltErrHandler(grouped,funName,s,varargin{:});
end

% Each row of cells will contain the outputs from FUN applied to one
% row or group of rows in B.
b_data = cell(ngroups,nout);
grpNumRows = ones(ngroups,1); % assume, for now, one row for each group

a_dataVars = a.data(dataVars);
for igrp = 1:ngroups
    if separateArgs
        inArgs = extractRows(a_dataVars,grpRows{igrp},extractCells);
        try
            if nout > 0
                [b_data{igrp,:}] = fun(inArgs{:});
            else
                fun(inArgs{:});
            end
        catch ME
            if nout > 0
                [b_data{igrp,:}] = errHandler(struct('identifier',ME.identifier, 'message',ME.message, 'index',igrp),inArgs{:});
            else
                errHandler(struct('identifier',ME.identifier, 'message',ME.message, 'index',igrp),inArgs{:});
            end
        end
    else
        inArgs = subsrefBraces(a,{grpRows{igrp} dataVars}); % inArgs = a{rows,dataVars}
        try
            if nout > 0
                [b_data{igrp,:}] = fun(inArgs);
            else
                fun(inArgs);
            end
        catch ME
            if nout > 0
                [b_data{igrp,:}] = errHandler(struct('identifier',ME.identifier, 'message',ME.message, 'index',igrp),inArgs);
            else
                errHandler(struct('identifier',ME.identifier, 'message',ME.message, 'index',igrp),inArgs);
            end
        end
    end
    if nout > 0
        if uniformOutput
            for jout = 1:nout
                if ~isscalar(b_data{igrp,jout})
                    if grouped
                        error(message('MATLAB:table:rowfun:NotAScalarOutputGrouped',funName,ordinalString(igrp)));
                    else
                        error(message('MATLAB:table:rowfun:NotAScalarOutput',funName,ordinalString(igrp)));
                    end
                end
            end
        elseif tabularOutput
            numRows = size(b_data{igrp,1},1);
            for jout = 1:nout % repeat j==1 to check any(n ~= 1)
                n = size(b_data{igrp,jout},1);
                if grouped
                    if any(n ~= numRows)
                        error(message('MATLAB:table:rowfun:GroupedRowSize',funName,ordinalString(igrp)));
                    end
                elseif any(n ~= 1) % ~grouped
                    error(message('MATLAB:table:rowfun:UngroupedRowSize',funName,ordinalString(igrp)));
                end
            end
            grpNumRows(igrp) = numRows;
        else
            % leave cell output alone
        end
    end
end

if uniformOutput
    if nout > 0 && ngroups > 0
        uniformClass = class(b_data{1});
        b = cell2matWithUniformCheck(b_data,uniformClass,funName,grouped);
    else
        % The function either produces no outputs, or there was nothing to call
        % it on, assume it would have produced a double result.
        b = zeros(ngroups,nout);
    end
    
elseif tabularOutput
    % Concatenate each of the function's outputs across groups of rows
    b_dataVars = cell(1,nout);
    for jout = 1:nout
        b_dataVars{jout} = vertcat(b_data{:,jout});
    end
    
    if grouped
        % Create the output by first concatenating the unique grouping var combinations, one
        % row per group, and the group counts. Replicate to match the number of rows from the
        % function output for each group, and concatenate that with the function output.
        
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
            % Save the leading row times for each group, as many as there
            % are output. Each cell in grpRows is a vector containing the
            % row numbers for the i'th group's rows. There may be more rows
            % in grpRows than there are output rows, so we need to get rid
            % of the extra rows. If there are more output rows than input
            % rows, error.
            for igrp = 1:ngroups
                grpSz = size(grpRows{igrp},1);
                if grpNumRows(igrp) > grpSz % Check that output doesn't grow beyond group size.
                    error(message('MATLAB:table:rowfun:TimetableCannotGrow'));
                elseif grpNumRows(igrp) < grpSz % Need to throw away extra rows in grpRows.
                    grpRows{igrp}((grpNumRows(igrp)+1):end) = [];
                end
            end
            b_time = a.rowDim.labels(vertcat(grpRows{:}));
            
            % When there are multiple rows per group in the output, subsrefParens will have
            % replicated values of the first row time within each group. That's correct when
            % grouping by time, but otherwise use the "leading" row times saved earlier.
            bg.rowDim = bg.rowDim.setLabels(b_time);
        end

        % Make sure that constructed var names don't clash with the grouping var names
        % or dim names. Specified output names that clash is an error.
        vnames = [{'GroupCount'} outNames];
        if ~supplied.OutputVariableNames
            avoidVarNames = [bg.metaDim.labels bg.varDim.labels];
            vnames = matlab.lang.makeUniqueStrings(vnames,avoidVarNames,namelengthmax);
        end
        
        % Create the output table by concatenating the grouping vars and the group
        % count var with the function output. Update the variable names,
        % using setLabels to validate that user-supplied outNames don't
        % clash.
        b = bg;
        b.data = [b.data {grpCounts} b_dataVars];
        newVarInds = (b.varDim.length+1):(b.varDim.length+length(vnames));
        % First, treat vnames as dummy names so that lengthTo doesn't have to
        % make dummy names and make them unique. Then, pass vnames into
        % setLabels to do the appropriate unique and valid checks.
        b.varDim = b.varDim.lengthenTo(newVarInds(end),vnames);
        b.varDim = b.varDim.setLabels(vnames,newVarInds,false,false,false);
        
    else % ungrouped
        if tableOutput && isa(a,'timetable') % table output from a timetable input
            if ~supplied.OutputVariableNames
                % Make sure the default output var names don't clash with the dim names.
                newDimNames = [a.metaDim.dfltLabels(1), a.metaDim.labels(2)];
                outNames = matlab.lang.makeUniqueStrings(outNames,newDimNames,namelengthmax);
            end
            
            % Create a table the same height as the input, since the output rows correspond
            % 1:1 to the input rows.  Preserve number of rows even if there are no data variables.
            % Discard the input's row times and all per-variable metadata.
            b = table.init(b_dataVars, ...
                           a.rowDim.length, {}, ...
                           length(outNames), outNames, ...
                           a.metaDim.labels(2));
            
        else % output type same as input
            % Copy the input, but overwrite its variables with the function's output
            % variables. Preserve the row labels, since the output rows correspond 1:1 to
            % the input rows.
            b = a;
            b.data = b_dataVars; % already enforced one output row per input row
            
            % Update the var names, but discard per-variable metadata.
            if ~supplied.OutputVariableNames
                % Make sure the default output var names don't clash with the dim names.
                outNames = matlab.lang.makeUniqueStrings(outNames,a.metaDim.labels,namelengthmax);
            end
            b.varDim = matlab.internal.tabular.private.varNamesDim(length(outNames),outNames);
        end
    end
    
    if supplied.OutputVariableNames
        % Detect conflicts between the var names and the dim names. Normally, conflicts
        % in a table's names would be resolved automatically with a warning, but for
        % timetable in/table out, behave as if the output was a timetable.
        if tableOutput && isa(a,'timetable')
            b.metaDim = b.metaDim.checkAgainstVarLabels(outNames,'error');
        else
            b.metaDim = b.metaDim.checkAgainstVarLabels(outNames);
        end
    end
    
else % cellOutput
    b = b_data;
end


%-------------------------------------------------------------------------------
function [varargout] = dfltErrHandler(grouped,funName,s,varargin) %#ok<STOUT>
import matlab.internal.datatypes.ordinalString
% May have guessed wrong about nargout for an anonymous function
if grouped
    m = message('MATLAB:table:rowfun:FunFailedGrouped',funName,ordinalString(s.index),s.message);
else
    m = message('MATLAB:table:rowfun:FunFailed',funName,ordinalString(s.index),s.message);
end
throw(MException(m.Identifier,'%s',getString(m)));


%-------------------------------------------------------------------------------
function outVals = cell2matWithUniformCheck(outVals,uniformClass,funName,grouped)
import matlab.internal.datatypes.ordinalString
[nrows,nvars] = size(outVals);
outValCols = cell(1,nvars);
for jvar = 1:nvars
    for irow = 1:nrows
        if ~isa(outVals{irow,jvar},uniformClass)
            c = class(outVals{irow,jvar});
            if grouped
                error(message('MATLAB:table:rowfun:MismatchInOutputTypesGrouped',funName,c,uniformClass,ordinalString(irow)));
            else
                error(message('MATLAB:table:rowfun:MismatchInOutputTypes',funName,c,uniformClass,ordinalString(irow)));
            end
        end
    end
    outValCols{jvar} = vertcat(outVals{:,jvar});
end
outVals = horzcat(outValCols{:});


%-------------------------------------------------------------------------------
function b = extractRows(t_data,rowIndices,extractCells)
%EXTRACTROWS Retrieve one or more rows from a table's data as a 1-by- cell vector.
nvars = length(t_data);
b = cell(1,nvars);
for j = 1:nvars
    var_j = t_data{j};
    if matlab.internal.datatypes.istabular(var_j)
        b{j} = subsrefParens(var_j,{rowIndices ':'}); % can't use table subscripting directly
    elseif ismatrix(var_j)
        b{j} = var_j(rowIndices,:); % without using reshape, may not have one
    else
        % Each var could have any number of dims, no way of knowing,
        % except how many rows they have.  So just treat them as 2D to get
        % the necessary rows, and then reshape to their original dims.
        sizeOut = size(var_j); sizeOut(1) = numel(rowIndices);
        b{j} = reshape(var_j(rowIndices,:), sizeOut);
    end
    if extractCells && iscell(b{j})
        b{j} = vertcat(b{j}{:});
    end
end
