function [outPa, outAdaptor] = applyIdentCats(inPa, inAdaptor)
%applyIdentCats - take a tall array and force it to have identical categories.

% Copyright 2017 The MathWorks, Inc.

if ~any(strcmp(inAdaptor.Class, {'categorical', 'table', 'timetable'}))
    % No categorical data
    [outPa, outAdaptor] = deal(inPa, inAdaptor);
    return
end

if strcmp(inAdaptor.Class, 'categorical')
    outPa = iApplyIdentCatsToCategorical(inPa);
else
    if ~iIsAnyVarCategorical(inAdaptor)
        [outPa, outAdaptor] = deal(inPa, inAdaptor);
        return
    else
        outPa = iApplyIdentCatsToTabular(inPa);
    end
end

% Trigger caching of preview data if cheap (presumably it is, or we probably
% wouldn't be here). If we get here, then the preview is presumed to be invalid
% because it will have invalid categories lists. Therefore, this block of code
% is attempting to preserve any size information that is in the original preview
% that is not present in the incoming adaptor.
%
% Note that calling getArrayInfo can actually cause the array
% to become gathered, in which case we must not query the cached preview data.
matlab.bigdata.internal.util.getArrayInfo(inPa, inAdaptor);
outAdaptor = inAdaptor;
if ~inPa.ValueFuture.IsDone && inPa.hasCachedPreviewData()
    [previewData, isTruncated] = inPa.getCachedPreviewData();
    % We cannot copy the preview data as it has incorrect categories. But we can
    % copy across size information.
    previewSize = size(previewData);
    if ~isTruncated
        % We know the full size
        outAdaptor = setKnownSize(outAdaptor, previewSize);
    else
        % Just copy the small sizes
        outAdaptor = setSmallSizes(outAdaptor, previewSize(2:end));
    end
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Walk down a tabular adaptor, returning true if any categorical variable
% adaptors are found.
function tf = iIsAnyVarCategorical(inAdaptor)
tf = false;
tabularAdaptorStack = {inAdaptor};
while ~isempty(tabularAdaptorStack)
    % Pop next adaptor off the stack
    thisAdaptor = tabularAdaptorStack{1};
    tabularAdaptorStack = tabularAdaptorStack(2:end);
    
    % Walk over sub-adaptors, looking for categoricals, or further tabular
    % adaptors that must be examined.
    tabularWidth = thisAdaptor.getSizeInDim(2);
    for idx = 1:tabularWidth
        varAdaptor = thisAdaptor.getVariableAdaptor(idx);
        if strcmp(varAdaptor.Class, 'categorical')
            tf = true;
            return
        elseif any(strcmp(varAdaptor.Class, {'table', 'timetable'}))
            tabularAdaptorStack{end+1} = varAdaptor; %#ok<AGROW>
        end
    end
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Actually apply identcats to all categorical variables simultaneously
function outPa = iApplyIdentCatsToTabular(inPa)
import matlab.bigdata.internal.broadcast
[catsPa, catPathPa] = aggregatefun(@iAggregateTableCats, @iReduceTableCats, inPa);
outPa = elementfun(@iApplyTableCategories, inPa, ...
    broadcast(catsPa), broadcast(catPathPa));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Apply categories lists to tabular data. 'cats' is a cell array of cellstrs
% where each element is the list of categories for a table variable. 'catsPath'
% is a cell array of cellstrs - each of which is a path to a categorical to be
% fixed up (i.e. neither ordinal nor protected).
function t = iApplyTableCategories(t, cats, catsPath)
for idx = 1:numel(catsPath)
    thisPath = catsPath{idx};
    substructElements = [repmat({'.'}, 1, numel(thisPath)); ...
                        thisPath];
    ss = substruct(substructElements{:});
    thisVar = subsref(t, ss);
    newVar = setcats(thisVar, cats{idx});
    t = subsasgn(t, ss, newVar);
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Aggregation phase of iApplyIdentCatsToTabular - gather categories from each
% chunk.
function [cats, catsPath] = iAggregateTableCats(t)

% Stack of tables to handle - each row is a table and a path to get there from
% the root table. The path is a list of variable names, i.e. if the categorical
% nested inside the table is accessed as t.Foo.Bar.Baz, the path would 
% be {'Foo', 'Bar', 'Baz'}.
tablesStack = {t, {}};

% Cell array of cellstrs containing the categories from this table
cats = {};
% Cell array of path arrays
catsPath = {};

while ~isempty(tablesStack)
    % Pop a table off the stack
    [thisTable, thisPath] = deal(tablesStack{1, :});
    tablesStack = tablesStack(2:end, :);
    tableVarNames = thisTable.Properties.VariableNames;
    
    for idx = 1:width(thisTable)
        thisVar = thisTable.(idx);
        varPath = [thisPath, tableVarNames{idx}];
        if iscategorical(thisVar) && ~(isprotected(thisVar) || isordinal(thisVar))
            cats{end+1} = categories(thisVar); %#ok<AGROW>
            catsPath{end+1} = varPath; %#ok<AGROW>
        elseif istable(thisVar) || istimetable(thisVar)
            % Push another table on the stack
            tablesStack = [tablesStack; {thisVar, varPath}]; %#ok<AGROW>
        end
    end
end

% Ensure we emit cell array rows so that they can be vertically concatenated.
cats = cats(:).';
catsPath = catsPath(:).';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Reduction phase of iApplyIdentCatsToTabular - collect together the unique list
% of categories discovered from the chunks.
function [cats, catsPath] = iReduceTableCats(inCats, catsPath)
cats = cell(1, size(inCats, 2));
for idx = 1:size(inCats, 2)
    cats{idx} = unique(vertcat(inCats{:, idx}), 'stable');
end
catsPath = catsPath(1,:);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% applyIdentCats for a single categorical array
function outPa = iApplyIdentCatsToCategorical(inPa)
import matlab.bigdata.internal.broadcast
[catsPa, isProtOrOrd] = aggregatefun(@iAggregateCats, @iReduceCats, inPa);
outPa = elementfun(@iMaybeSetcats, inPa, ...
                   broadcast(catsPa), broadcast(isProtOrOrd));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [cats, isProtOrOrd] = iAggregateCats(x)
cats = {categories(x)};
isProtOrOrd = isprotected(x) || isordinal(x);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [cats, isProtOrOrd] = iReduceCats(cats, isProtOrOrd)
cats = vertcat(cats{:});
% It's possible that the categorical array already has correct categories set -
% so use 'stable' argument in UNIQUE to ensure the order is preserved.
cats = {unique(cats, 'stable')};
assert(isscalar(unique(isProtOrOrd)), ...
       'Inconsistent protected/ordinal status for categorical data');
isProtOrOrd = all(isProtOrOrd);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function x = iMaybeSetcats(x, cats, isProtOrOrd)
if ~isProtOrOrd
    x = setcats(x, cats{1});
end
end
