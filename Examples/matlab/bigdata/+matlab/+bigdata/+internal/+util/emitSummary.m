function summaryStruct = emitSummary(summaryInfo, tableProperties)
%emitSummary Emit the struct to be returned by 'summary'

% Copyright 2016-2017 The MathWorks, Inc.

summaryStruct = struct();

[min_label, max_label, true_label, false_label] = getSummaryLabels();

emptyCellstr = repmat({''}, 1, numel(summaryInfo));
if isempty(tableProperties.VariableDescriptions)
    varDescrs = emptyCellstr;
else
    varDescrs = tableProperties.VariableDescriptions;
end
if isempty(tableProperties.VariableUnits)
    varUnits = emptyCellstr;
else
    varUnits = tableProperties.VariableUnits;
end
if isempty(tableProperties.VariableContinuity)
    varContinuity = repmat({[]}, 1, numel(summaryInfo));
else
    varContinuity = num2cell(tableProperties.VariableContinuity);
end

for idx = 1:numel(summaryInfo)
    thisInfo    = summaryInfo{idx};
    thisInfo.Description = varDescrs{idx};
    thisInfo.Units = varUnits{idx};
    thisInfo.Continuity = varContinuity{idx};
    thisElement = [];
    infoFields  = {'Size', 'Type', ...
                   'Description', 'Units', ...
                   'Continuity', ...
                   'MinVal', 'MaxVal', ...
                   'NumMissing', 'true', 'false' };
    elFields    = {'Size', 'Type', ...
                   'Description', 'Units', ...
                   'Continuity', ...
                   min_label, max_label, ...
                   'NumMissing', true_label, false_label};
    for jdx = 1:numel(infoFields)
        thisElement = iAddFieldIfPresent(thisElement, thisInfo, ...
                                         infoFields{jdx}, elFields{jdx});
    end
    
    % Trim Description, Units, and Continuity for RowTimes
    if ~isempty(thisInfo.RowLabelDescr)
        thisElement = rmfield(thisElement, {'Description', 'Units', 'Continuity'});
    end
    
    if isfield(thisInfo, 'CategoricalInfo')

        thisElement.Categories = thisInfo.CategoricalInfo{1};
        % Fix up the case of empty categoricals - must be {} not cell(0,1).
        if prod(thisInfo.Size) == 0 && isempty(thisElement.Categories)
            thisElement.Categories = {};
        end
        
        counts = thisInfo.CategoricalInfo{2};
        gotUndef = ~isempty(thisElement.Categories) && ...
            strcmp(thisElement.Categories{end}, 'NumMissing');

        if gotUndef
            % 'Undefined' output is always the final *row* from counts. This isn't
            % completely consistent with the overall 'Counts' output.
            undefCount = counts(end, :);
            counts(end, :) = [];
            % Remove '<undefined>' from categories list
            thisElement.Categories(end) = [];
        else
            undefCount = zeros(1, size(counts, 2));
        end

        thisElement.Counts = counts;
        % Add 'NumMissing' field last to ensure correct struct field ordering.
        thisElement.NumMissing = undefCount;
    end
    
    summaryStruct.(thisInfo.Name) = thisElement;
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copy field from computed summary into result if it is present.
function s = iAddFieldIfPresent(s, info, infoField, sField)
if isfield(info, infoField)
    s.(sField) = info.(infoField);
end
end
