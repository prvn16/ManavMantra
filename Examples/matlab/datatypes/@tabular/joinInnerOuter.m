function [c,il,ir] = joinInnerOuter(a,b,leftOuter,rightOuter,leftKeyVals,rightKeyVals, ...
                                    leftVars,rightVars,leftKeys,rightKeys,leftVarDim,rightVarDim)
%JOININNEROUTER Common calculations for innerJoin and outerJoin.

% C is [A(IA,LEFTVARS) B(IB,RIGHTVARS)], where IA and IB are row indices into A
% and B computed for each row of C from LEFTKEYVALS and RIGHTKEYVALS.  These
% index vectors may include zeros indicating "no source row in A/B)" for some
% rows of C.

%   Copyright 2012-2016 The MathWorks, Inc.

import matlab.internal.datatypes.defaultarrayLike
import matlab.internal.datatypes.coloncat

try
    % Sort each key.
    [lkeySorted,lkeySortOrd] = sort(leftKeyVals);
    [rkeySorted,rkeySortOrd] = sort(rightKeyVals);

    % Get unique key values and counts. This also gives the beginning and end of
    % each block of constant key values in each. All of these end up 0x1 if the
    % corresponding key is empty.
    lbreaks = find(diff(lkeySorted)); % breakpoints from one key value to the next
    rbreaks = find(diff(rkeySorted));
    lones = ones(~isempty(leftKeyVals),1); % scalar 1, or empty 0x1
    rones = ones(~isempty(rightKeyVals),1);
    lstart = [lones; lbreaks+1]; % start of each block of constant key values
    rstart = [rones; rbreaks+1];
    lend = [lbreaks; length(lkeySorted)*lones]; % end of each block of constant key values
    rend = [rbreaks; length(rkeySorted)*rones];
    lunique = lkeySorted(lstart); % unique key values
    runique = rkeySorted(rstart);
    luniqueCnt = lend - lstart + 1; % number of unique key values
    runiqueCnt = rend - rstart + 1;
    clear lbreaks rbreaks lstart lend % clear some potentially large variables no longer needed

    % Use the "block nested loops" algorithm to determine how many times to
    % replicate each row of A and B.  Rows within each "constant" block of keys in
    % A will need to be replicated as many times as there are rows in the matching
    % block of B, and vice versa.  Rows of A that don't match anything in B, or
    % vice versa, get zero.  Rows of A will be replicated row-by-row; rows in B
    % will be replicated block-by-block.
    il = 1;
    ir = 1;
    leftElemReps = zeros(size(lunique));
    rightBlockReps = zeros(size(runique));
    while (il <= length(lunique)) && (ir <= length(runique))
        if lunique(il) < runique(ir)
            il = il + 1;
        elseif lunique(il) == runique(ir)
            leftElemReps(il) = runiqueCnt(ir);
            rightBlockReps(ir) = luniqueCnt(il);
            il = il + 1;
            ir = ir + 1;
        elseif lunique(il) > runique(ir)
            ir = ir + 1;
        else % one must have been NaN
            % NaNs get sorted to end; nothing else will match
            break;
        end
    end

    % Identify the rows of A required for an inner join: expand out the number of
    % replicates within each block to match against the (non-unique) sorted keys,
    % then replicate each row index the required number of times.
    leftElemReps = repelem(leftElemReps,luniqueCnt);
    il = repelem(1:length(lkeySorted),leftElemReps)';

    % Identify the rows of B required for an inner join: replicate the start and
    % end indices of each block of keys the required number of times, then create
    % a concatenation of those start:end expressions.
    rstart = repelem(rstart,rightBlockReps);
    rend = repelem(rend,rightBlockReps);
    ir = coloncat(rstart,rend)';
    clear rstart rend % clear some potentially large variables no longer needed

    % Translate back to the unsorted row indices.
    il = lkeySortOrd(il);
    ir = rkeySortOrd(ir);

    % If this is a left- or full-outer join, add the indices of the rows of A that
    % didn't match anything in B.  Add in zeros for the corresponding B indices.
    if leftOuter
        left = find(leftElemReps(:) == 0); % force a column for one unique left key
        il = [il; lkeySortOrd(left)];
        ir = [ir; zeros(size(left))];
    end

    % If this is a right- or full-outer join, add the indices of the rows of B that
    % didn't match anything in A.  Add in zeros for the corresponding A indices.
    if rightOuter
        rightBlockReps = repelem(rightBlockReps,runiqueCnt);
        right = find(rightBlockReps(:) == 0); % force a column for one unique right key
        il = [il; zeros(size(right))];
        ir = [ir; rkeySortOrd(right)];
    end

    % Now sort the whole thing by the key.  If this is an inner join, that's
    % already done.
    if leftOuter || rightOuter
        pos = (il > 0);
        Key = zeros(size(il));
        Key(pos) = leftKeyVals(il(pos)); % Rows that have an A key value
        Key(~pos) = rightKeyVals(ir(~pos)); % Rows with no A key value must have a B key
        [~,ord] = sort(Key);
        il = il(ord);
        ir = ir(ord);
    end

    % Compute logical indices of where A'a and B's rows will go in C,
    % and the indices of which rows to pick out of A and B.
    ilDest = (il > 0); ilSrc = il(ilDest);
    irDest = (ir > 0); irSrc = ir(irDest);

    % Create a new empty time/table based on the left input, the specified variables
    % from A and from B will be added to that. Don't copy any per-array properties.
    % If duplicate row labels are allowed in the output, replicate/thin from the
    % left and possibly merge from the right. If row labels are required to be
    % unique, only create row labels if they won't need to be replicated, otherwise
    % it's too expensive to create unique row labels.
    c = a.cloneAsEmpty(); % respect the subclass
    c.metaDim = a.metaDim;
    c.rowDim = c.rowDim.createLike(length(il));
    if a.rowDim.hasLabels
        if a.rowDim.requireUniqueLabels
            assert(b.rowDim.requireUniqueLabels) % joinUtil should prevent table/timetable joins
            if any(rightKeys == 0)
                % Preallocate output row labels to account for right-only rows
                if c.rowDim.hasLabels
                    labels = c.rowDim.labels;
                else
                    labels = c.rowDim.defaultLabels();
                end
                % Always copy left row labels to output, even if not a key
                labels(ilDest) = a.rowDim.labels(ilSrc);
                if rightOuter
                    if any(leftKeys == 0)
                        % Merge right row labels into output when left row labels are a key
                        labels(irDest) = b.rowDim.labels(irSrc);
                    else
                        % Otherwise leave output row labels for right-only rows as default values.
                        % The right row labels will be merged into the key var in the output.
                    end
                end
                c.rowDim = c.rowDim.setLabels(labels);
            elseif any(leftKeys == 0)
                % In a table/table join, the right row labels must be a key if the left row
                % labels are. This avoids some situations where the row labels would have to
                % be replicated in the output, but can't be without an expensive deduplication.
                error(message('MATLAB:table:join:TableRowLabelsVarKeyPairNotSupported'));
            else
                % Don't copy row labels in a table/table join if neither input's row labels are
                % a key. This avoids having to replicate them in the output.
            end
        else
            if rightOuter
                % Preallocate output row labels to account for right-only rows
                if c.rowDim.hasLabels
                    labels = c.rowDim.labels;
                else
                    labels = c.rowDim.defaultLabels();
                end
            end
            % Always copy left row labels to output, even if not a key
            labels(ilDest) = a.rowDim.labels(ilSrc);
            if rightOuter
                if any(leftKeys == 0)
                    % Merge right key values into output row labels when left row labels are a key
                    rightMergedKey = rightKeys(find(leftKeys == 0,1,'last'));
                    rightVals = b.getVarOrRowLabelData(rightMergedKey); rightVals = rightVals{1};
                    labels(irDest) = rightVals(irSrc);
                else
                    % Otherwise leave output row labels for right-only rows as default values
                end
            end
            c.rowDim = c.rowDim.setLabels(labels);
        end
    end
    
    % Assign var labels and merge a's and b's per-var properties.
    numLeftVars = length(leftVars);
    numRightVars = length(rightVars);
    c_varDim = leftVarDim.lengthenTo(numLeftVars+numRightVars,rightVarDim.labels);
    c.varDim = c_varDim.moveProps(rightVarDim,1:numRightVars,numLeftVars+(1:numRightVars));
    
    % Move data into C.
    a_data = a.data;
    c_data = cell(1,numLeftVars+numRightVars);
    c_nrows = c.rowDim.length;
    for j = 1:numLeftVars
        leftvar_j = a_data{leftVars(j)};
        szOut = size(leftvar_j); szOut(1) = c_nrows;
        cvar_j = defaultarrayLike(szOut,'Like',leftvar_j);
        if isa(leftvar_j,'tabular')
            c_data{j} = cvar_j.subsasgnParens({ilDest,':'},leftvar_j.subsrefParens({ilSrc,':'}));
        else
            cvar_j(ilDest,:) = leftvar_j(ilSrc,:);
            c_data{j} = reshape(cvar_j,szOut);
        end
    end
    b_data = b.data;
    for j = 1:numRightVars
        rightvar_j = b_data{rightVars(j)};
        szOut = size(rightvar_j); szOut(1) = c_nrows;
        cvar_j = defaultarrayLike(szOut,'Like',rightvar_j);
        if isa(rightvar_j,'tabular')
            c_data{numLeftVars + j} = cvar_j.subsasgnParens({irDest,':'},rightvar_j.subsrefParens({irSrc,':'}));
        else
            cvar_j(irDest,:) = rightvar_j(irSrc,:);
            c_data{numLeftVars + j} = reshape(cvar_j,szOut);
        end
    end
    c.data = c_data;
catch ME
    throwAsCaller(ME)
end
