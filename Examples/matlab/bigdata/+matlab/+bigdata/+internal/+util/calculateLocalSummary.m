function summaryInfo = calculateLocalSummary( localTable )
% Calculate summary information for a local piece of a partitioned table.
% Output is a cell array containing one info struct per table variable.

%   Copyright 2016-2017 The MathWorks, Inc.

vars = localTable.Properties.VariableNames;

rowLabelDescr = cell(1, numel(vars));

if istimetable(localTable)
    % Prepend RowTimes
    vars = [localTable.Properties.DimensionNames{1}, vars];
    rowLabelDescr = ['RowTimes', rowLabelDescr];
end

summaryInfo = cell(1, numel(vars));
for idx = 1:numel(vars)
    var = localTable.(vars{idx});
    if iscellstr(var)
        clz = 'cell array of character vectors';
    else
        clz = class(var);
    end
    info = struct('Name', vars{idx}, ...
        'Size', size(var), ...
        'Class', clz, ...
        'Type', class(var), ...
        'RowLabelDescr', rowLabelDescr{idx});
    if ismatrix(var)
        if isnumeric(var) || isduration(var)
            info = iAddDatatypeInfo(info, var, NaN, @isnan);
        elseif islogical(var)
            info = iAddLogicalInfo(info, var);
        elseif isa(var, 'categorical')
            info = iAddCategoricalInfo(info, var);
        elseif isa(var, 'datetime')
            info = iAddDatatypeInfo(info, var, NaT, @isnat);
        end
    end
    summaryInfo{idx} = info;
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Add info for numeric/datatime/duration types.
function info = iAddDatatypeInfo(info, var, missingVal, isMissingFcn) %#ok<INUSL> eval!

% Data is always treated column-wise.
numMissing = sum(isMissingFcn(var), 1);


info.NumMissing = numMissing;
if ~(isinteger(var) && ~isreal(var))
    % Here we rely on the fact that omitnan/omitnat is the default.
    info.MinVal = min(var, [], 1);
    info.MaxVal = max(var, [], 1);
end
info.MissingStr = strtrim(evalc('disp(missingVal)'));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function info = iAddLogicalInfo(info, var)
info.true = sum(var, 1);
info.false = size(var, 1) - info.true;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function info = iAddCategoricalInfo(info, var)
numundef = sum(isundefined(var), 1);
cats     = categories(var);
counts   = countcats(var, 1);
if any(numundef > 0)
    cats{end+1,1} = 'NumMissing';
    counts(end+1,:) = numundef;
end
info.CategoricalInfo = { cats, counts };
if isordinal(var)
    info.Class = 'ordinal categorical';
end
end
