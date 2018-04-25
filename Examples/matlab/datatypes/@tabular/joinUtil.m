function [leftVars,rightVars,leftVarDim,rightVarDim,leftKeyVals,rightKeyVals,leftKeys,rightKeys] ...
                = joinUtil(a,b,type,leftTableName,rightTableName, ...
                           keys,leftKeys,rightKeys,leftVars,rightVars,keepOneCopy,supplied)
%JOINUTIL Common set-up for join, innerjoin, and outerjoin.

%   Copyright 2012-2016 The MathWorks, Inc.
try
    if supplied.Keys
        if supplied.LeftKeys || supplied.RightKeys
            error(message('MATLAB:table:join:ConflictingInputs'));
        elseif isequal(keys,'RowNames') ...
                 && strcmpi(type,'simple') && isa(a,'table') && isa(b,'table')
            % The reserved name 'RowLabels' is a compatibility special case only for simple
            % joins between two tables.
            if ~(a.rowDim.hasLabels && b.rowDim.hasLabels)
                a.throwSubclassSpecificError('NoRowLabels');
            end
            leftKeys = 0;
            rightKeys = 0;
        else
            leftKeys = a.getVarOrRowLabelIndices(keys);
            rightKeys = b.getVarOrRowLabelIndices(keys);
        end
    else % ~supplied.Keys
        if ~supplied.LeftKeys && ~supplied.RightKeys
            % Default join behavior when no keys specified
            if isa(a,'timetable') && isa(b,'timetable')
                % Join by row times
                leftKeys = 0;
                rightKeys = 0;
            else % at least one is a table
                % Join by vars with common names
                [leftKeys,rightKeys] = ismember(a.varDim.labels,b.varDim.labels);
                leftKeys = find(leftKeys);
                rightKeys = rightKeys(rightKeys>0);
                if isempty(leftKeys)
                    error(message('MATLAB:table:join:CantInferKey'));
                end
            end
        elseif ~supplied.LeftKeys || ~supplied.RightKeys
            error(message('MATLAB:table:join:MissingKeyVar'));
        else
            % Make sure the keys exist in both sides.
            leftKeys = a.getVarOrRowLabelIndices(leftKeys);
            rightKeys = b.getVarOrRowLabelIndices(rightKeys);
            
            if length(leftKeys) ~= length(rightKeys)
                error(message('MATLAB:table:join:UnequalNumKeyVars'));
            end
        end
    end
    
    if ~strcmpi(type,'simple') % {'inner' 'left' 'right' 'full'}
        % Simple joins require a unique match on the right for each row on the left,
        % so row labels in the output can simply be copied from the left (when present)
        % and there are no issues with required uniqueness.
        %
        % Inner/outer joins with a table as the first input have some restrictions to
        % avoid situations where the row labels would have to be replicated in the
        % output, but can't be without an expensive deduplication.
        if a.rowDim.requireUniqueLabels
            if b.rowDim.requireUniqueLabels
                if ~strcmpi(type,'inner') % {'left' 'right' 'full'}
                    % Row labels cannot be mixed with other keys in a table/table outer join.
                    if (any(leftKeys == 0) && any(leftKeys > 0)) ...
                            || (any(rightKeys == 0) && any(rightKeys > 0))
                        error(message('MATLAB:table:join:TableOuterRowLabelsOtherKeysNotSupported'));
                    end
                end
            else
                % The timetable must come first in a mixed-type inner/outer join.
                error(message('MATLAB:table:join:TableTimetableNotSupported'));
            end
        end
    end
    
    % Use all vars from A and B by default, or use the specified vars.
    if supplied.LeftVariables
        try
            leftVars = a.varDim.subs2inds(leftVars);
        catch ME
            a.subs2indsErrorHandler(leftVars,ME,'join');
        end
        if length(unique(leftVars)) < length(leftVars)
            error(message('MATLAB:table:join:DuplicateVars'));
        end
    else
        leftVars = 1:a.varDim.length;
    end
    if supplied.RightVariables
        try
            rightVars = b.varDim.subs2inds(rightVars);
        catch ME
            b.subs2indsErrorHandler(rightVars,ME,'join');
        end
        if length(unique(rightVars)) < length(rightVars)
            error(message('MATLAB:table:join:DuplicateVars'));
        end
    else
        rightVars = 1:b.varDim.length;
        if strcmpi(type,'simple') || strcmpi(type,'inner')
            % Leave B's keys out of the right data vars for simple/inner joins, they
            % are identical to A's keys, which are already included (unless otherwise
            % specified). Row labels are never allowed as a data variable, so no need
            % to worry about removing that from rightVars. In an outer join, row label
            % keys from the right are always merged, and non-row-labels keys are
            % included unless otherwise specified.
            rightVars(rightKeys(rightKeys>0)) = [];
        end
    end

    % Detect and resolve duplicate var names.
    leftVarDim = a.varDim.selectFrom(leftVars);
    rightVarDim = b.varDim.selectFrom(rightVars);
    leftVarNames = leftVarDim.labels;
    rightVarNames = rightVarDim.labels;
    [dups,ia,ib] = intersect(leftVarNames,rightVarNames);
    if supplied.KeepOneCopy && ~isempty(dups)
        [~,keepOneCopy] = intersect(dups,keepOneCopy);
        dropFromB = ib(keepOneCopy);
        rightVars(dropFromB) = [];
        rightVarNames(dropFromB) = [];
        rightVarDim = rightVarDim.deleteFrom(dropFromB);
        [dups,ia,ib] = intersect(leftVarNames,rightVarNames);
    end
    % Also detect duplicates between the left dim names and the right var names.
    % Duplicates between the left dim names and the left var names are not possible,
    % and duplicates between the right dim names and anything is unimportant.
    leftDimNames = a.metaDim.labels;
    [dups2,ib2] = intersect(rightVarNames,leftDimNames);
    dups = unique([dups dups2]);
    ib = unique([ib; ib2]);
    if ~isempty(dups)
        % Uniqueify any duplicate var names.
        if isempty(leftTableName)
            leftTableName = getString(message('MATLAB:table:uistrings:JoinLeftVarSuffix'));
        end
        leftVarNames(ia) = strcat(leftVarNames(ia),['_' leftTableName]);
        if isempty(rightTableName)
            rightTableName = getString(message('MATLAB:table:uistrings:JoinRightVarSuffix'));
        end
        rightVarNames(ib) = strcat(rightVarNames(ib),['_' rightTableName]);
        % Don't allow the uniqueified names on either side to duplicate existing
        % var names from either side, or dim names from the left side
        vn = [leftVarNames rightVarNames leftDimNames];
        vn = matlab.lang.makeUniqueStrings(vn,ia,namelengthmax);
        vn = matlab.lang.makeUniqueStrings(vn,length(leftVarNames)+ib,namelengthmax);
        leftVarDim = leftVarDim.setLabels(vn(1:length(leftVarNames)));
        rightVarDim = rightVarDim.setLabels(vn(length(leftVarNames)+1:end-length(leftDimNames)));
    end

    if isSimpleJoinOnUniqueRowLabels(leftKeys,rightKeys,type,a,b)
        % When row labels are unique, a simple join on them can be done quickly with
        % ismember. First set the right key values to the right's row indices.
        rightKeyVals = 1:b.rowDim.length;
        % Use ismember to find the left's row labels in the right's, the locations are the
        % left key values, and conveniently specify which rows in the right match the left.
        [tf,leftKeyVals] = ismember(a.rowDim.labels,b.rowDim.labels);
        % As with any simple join, the right's row labels must be a superset of the left's.
        if ~all(tf)
            error(message('MATLAB:table:join:UnequalRowNames'));
        end

    else
        % Get the key var values, and check that they are scalar-valued or
        % vector-valued.
        leftKeyVals = a.getVarOrRowLabelData(leftKeys);
        rightKeyVals = b.getVarOrRowLabelData(rightKeys);
        if any(cellfun('ndims',leftKeyVals) > 2) || any(cellfun('ndims',rightKeyVals) > 2)
            error(message('MATLAB:table:join:NDKeyVar'));
        end

        % Convert possibly multiple keys to a single integer-valued key, taking on
        % comparable values across A and B.
        nkeys = length(leftKeys);
        leftlen = size(a,1);
        rightlen = size(b,1);
        lrkeys = zeros(leftlen+rightlen,nkeys);
        for j = 1:nkeys
            if size(leftKeyVals{j},2) ~= size(rightKeyVals{j},2) % already know these are 2-D
                 error(message('MATLAB:table:join:KeyVarSizeMismatch', getVarOrRowLabelsName(a,leftKeys(j)), getVarOrRowLabelsName(b,rightKeys(j))));
            elseif iscell(leftKeyVals{j}) ~= iscell(rightKeyVals{j})
                 error(message('MATLAB:table:join:KeyVarCellMismatch', getVarOrRowLabelsName(a,leftKeys(j)), getVarOrRowLabelsName(b,rightKeys(j))));
            end
            try
                lrkey_j = [leftKeyVals{j}; rightKeyVals{j}];
            catch me
                 error(message('MATLAB:table:join:KeyVarTypeMismatch', getVarOrRowLabelsName(a,leftKeys(j)), getVarOrRowLabelsName(b,rightKeys(j))));
            end
            if size(lrkey_j,2) > 1
                if isnumeric(lrkey_j) || islogical(lrkey_j) || isstring(lrkey_j) || ischar(lrkey_j)
                    [~,~,lrkeys(:,j)] = unique(lrkey_j,'rows');
                else
                    error(message('MATLAB:table:join:MulticolumnKeyVar', class(rightKeyVals)));
                end
            else
                try
                    [~,~,lrkeys(:,j)] = unique(lrkey_j);
                catch me
                    if strcmp(me.identifier,'MATLAB:UNIQUE:InputClass')
                        error(message('MATLAB:table:join:KeyVarNonStringError', getVarOrRowLabelsName(a,leftKeys(j)), getVarOrRowLabelsName(b,rightKeys(j))));
                    else
                        error(message('MATLAB:table:join:KeyVarUniqueError', getVarOrRowLabelsName(a,leftKeys(j)), getVarOrRowLabelsName(b,rightKeys(j)), me.message));
                    end
                end
            end
            if iscell(lrkey_j) || ischar(lrkey_j)
                % unique does not recognize '' in a cellstr or spaces in a char matrix as
                % missing, assign a missing key value in those cases. This is somewhat different
                % from cases where unique _does_ know about missing values; in those cases the
                % missing "raw" key values become unique integers.
                areMissing = ismissing(lrkey_j);
                lrkeys(areMissing,j) = NaN;
            end
        end
        if nkeys > 1
            [~,~,lrkeys] = unique(lrkeys,'rows');
        end
        leftKeyVals = lrkeys(1:leftlen,1); % force these to be columns
        rightKeyVals = lrkeys(leftlen+(1:rightlen),1);
    end
catch ME
    throwAsCaller(ME)
end

%-----------------------------------------------------------------------
function tf = isSimpleJoinOnUniqueRowLabels(leftKeys,rightKeys,type,a,b)
tf = isequal(leftKeys,rightKeys,0) && strcmpi(type,'simple') ...
    && a.rowDim.requireUniqueLabels && b.rowDim.requireUniqueLabels;

%-----------------------------------------------------------------------
function name = getVarOrRowLabelsName(t,index)
if index == 0
    name = t.Properties.DimensionNames{1};
else
    name = t.Properties.VariableNames{index};
end
