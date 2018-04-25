function printSummary( summaryInfo, tableProperties )
% Print out some previously collected variable summary info

%   Copyright 2016-2017 The MathWorks, Inc.

import matlab.bigdata.internal.util.formatBigSize

isLoose = strcmp(matlab.internal.display.formatSpacing,'loose');
if isLoose
    sep = newline;
else
    sep = '';
end

fprintf('%s', sep);
if ~isempty(tableProperties.Description)
    fprintf('Description:  %s\n%s', tableProperties.Description, sep);
end

% Keep track of whether we've printed the 'Variables:' line
havePrintedVarsNamesLine = false;

% These labels are hard-coded in tabular/summary
[min_label, max_label, true_label, false_label] = getSummaryLabels();

for idx = 1:numel(summaryInfo)

    thisInfo = summaryInfo{idx};

    % Print the 'RowTimes' line if necessary. Here we are assuming that
    % 'calculateLocalSummary' has put the 'RowTimes' data in the first entry in
    % summaryInfo.
    if idx == 1 && ~isempty(thisInfo.RowLabelDescr)
        fprintf('%s:\n%s', thisInfo.RowLabelDescr, sep);
    elseif ~havePrintedVarsNamesLine
        fprintf('%s:\n%s', tableProperties.DimensionNames{2}, sep);
        havePrintedVarsNamesLine = true;
    end
    
    szStr = formatBigSize(thisInfo.Size);
    fprintf('    %s: %s %s\n', ....
            matlab.bigdata.internal.util.emphasizeText(thisInfo.Name), ...
            szStr, thisInfo.Class);
    isVarEmpty = (prod(thisInfo.Size) == 0);

    
    if ~isempty(tableProperties.VariableUnits) && ...
            ~isempty(tableProperties.VariableUnits{idx})
        fprintf('        Units:  %s\n', tableProperties.VariableUnits{idx});
    end
    if ~isempty(tableProperties.VariableDescriptions) && ...
            ~isempty(tableProperties.VariableDescriptions{idx})
        fprintf('        Description:  %s\n', tableProperties.VariableDescriptions{idx});
    end
    if ~isempty(tableProperties.VariableContinuity)
        % VariableContinuity is either completely empty or a vector of Continuity objects.
        fprintf('        Continuity:  %s\n', char(tableProperties.VariableContinuity(idx)));
    end
    
    labelsStr = {};
    if ~isVarEmpty
        if isfield(thisInfo, 'NumMissing')
            % numeric-ish
            missingLabel = 'NumMissing';
            if isfield(thisInfo, 'MinVal') && isfield(thisInfo, 'MaxVal')
                labelsStr = { min_label, max_label };
                valuesMatrix = [thisInfo.MinVal; thisInfo.MaxVal];
            end
            if any(thisInfo.NumMissing > 0)
                % Convert to cellstr for display to ensure we can append the row of number of
                % missing values.
                if isnumeric(valuesMatrix)
                    valuesMatrix = sprintfc('%.5g', valuesMatrix);
                end
                valuesMatrix = [cellstr(valuesMatrix); ...
                                sprintfc('%g', reshape(thisInfo.NumMissing, 1, []))];
                valuesMatrix = strrep(valuesMatrix, '''', ' ');
                labelsStr{end+1} = missingLabel; %#ok<AGROW> incorrect analysis
            end
        elseif isfield(thisInfo, 'true')
            labelsStr = {true_label, false_label};
            valuesMatrix = [thisInfo.true;
                            thisInfo.false];
        elseif isfield(thisInfo, 'CategoricalInfo')
            labelsStr = thisInfo.CategoricalInfo{1};
            valuesMatrix = thisInfo.CategoricalInfo{2};
        end
        if ~isempty(labelsStr)
            vn = matlab.internal.datatypes.numberedNames([thisInfo.Name '_'],...
                                                         1:size(valuesMatrix,2));
            qt = array2table(valuesMatrix, 'RowNames', labelsStr, ...
                             'VariableNames', vn); %#ok<NASGU> used in evalc
            c = evalc('disp(qt,false,12)');
            
            % Might need to remove single quotes here.
            removeSingleQuotes = ~iscategorical(valuesMatrix);
            if removeSingleQuotes
                c = strrep(c, '''', ' ');
            end
            
            if isvector(valuesMatrix)
                lf = newline;
                firstTwoLineFeeds = find(c==lf, 2, 'first');
                c(1:firstTwoLineFeeds(end)) = [];
            end
            if isLoose
                % Strip the extra newline from the end of the display
                assert(~isempty(c) && c(end) == newline);
                c = c(1:end-1);
            end
            fprintf('        Values:\n');
            fprintf('%s',c);
        end
    end
    fprintf('%s', sep);
end

if ~havePrintedVarsNamesLine
    % Get here if there are no variables.
    fprintf('%s:\n%s', tableProperties.DimensionNames{2}, sep);
end
end
