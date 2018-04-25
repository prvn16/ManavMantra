function out = reduceSummary( in )
% Combine multiple local summary information into a single summary.
%
% "in" should be a 2-D cell array where each row represents info from a
% single chunk. "out" will be a cell row with one entry per variable in the
% table.

%   Copyright 2016-2017 The MathWorks, Inc.

out = in(1,:);
for chunkIdx = 2:size(in, 1)
    for varIdx = 1:size(in, 2)
        baseInfo = out{varIdx};
        incrInfo = in{chunkIdx, varIdx};
        out{varIdx} = iIncrementInfo(baseInfo, incrInfo);
    end
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% In the reduce phase, we need to increment each info structure. Here we simply
% do this pairwise. The fields must match between the original information and
% the increment.
function info = iIncrementInfo(info, increment)

isEmptyInfo = @(x) (prod(x.Size) == 0);

if isEmptyInfo(info) ~= isEmptyInfo(increment)
    % One or other is empty - but not both - return the non-empty version.
    % g1392643
    if isEmptyInfo(info)
        info = increment;
    end
    return
end

fields = { 'Size', @(x, y) [x(1) + y(1), x(2:end)]; ...
           'NumMissing', @plus; ...
           'MinVal', @(x, y) min([x;y], [], 1); ...
           'MaxVal', @(x, y) max([x;y], [], 1); ...
           'true', @plus; ...
           'false', @plus; ...
           'CategoricalInfo', @iAddCategoricalInfos; ...
           'RowLabelDescr', @iReduceRowLabelDescr};
gotFields = isfield(info, fields(:,1));
assert(all(gotFields == isfield(increment, fields(:,1))));

for idx = find(gotFields.')
    [fieldName, fcn] = deal(fields{idx, :});
    info.(fieldName) = fcn(info.(fieldName), increment.(fieldName));
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% All 'RowLabelDescr' fields should be identical, so the reduction doesn't need
% to do anything - but we can assert that all values are indeed the same.
function out = iReduceRowLabelDescr(out, check)
assert(isequal(out, check));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = iAddCategoricalInfos(a, b)

if isequal(a{1}, b{1})
    % Categories were identical for local parts, can simply add together the counts.
    out = { a{1}, a{2} + b{2} };
else
    % Merge category information. This will re-order the category display.
    outCats = union(a{1}, b{1});
    outVals = zeros(numel(outCats),1); % Always use column vectors
    [~, loc] = ismember(a{1}, outCats);
    outVals(loc) = a{2};
    [~, loc] = ismember(b{1}, outCats);
    outVals(loc) = outVals(loc) + b{2};
    out = { outCats, outVals };
end
end
