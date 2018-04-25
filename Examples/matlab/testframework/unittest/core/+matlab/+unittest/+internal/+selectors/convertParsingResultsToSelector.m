function selector = convertParsingResultsToSelector(selectionCriteria)

% Copyright 2013-2016 The MathWorks, Inc.

selectors = {};

selectors = [selectors, {handleSelectorInput(selectionCriteria)}];
selectors = [selectors, {handleParameterization(selectionCriteria)}];
selectors = [selectors, {handleName(selectionCriteria)}];
selectors = [selectors, {handleBaseFolder(selectionCriteria)}];
selectors = [selectors, {handleTag(selectionCriteria)}];
selectors = [selectors, {handleProcedureName(selectionCriteria)}];
selectors = [selectors, {handleSuperclass(selectionCriteria)}];

selector = combineSelectors(selectors);
end

function selector = handleSelectorInput(selectionCriteria)
if isfield(selectionCriteria, 'Selector')
    validateattributes(selectionCriteria.Selector, ...
        {'matlab.unittest.internal.selectors.Selector'}, {'scalar'}, '', 'selector');
    selector = selectionCriteria.Selector;
else
    selector = {};
end
end

function selector = handleParameterization(selectionCriteria)
import matlab.unittest.selectors.HasParameter;

% Need to create a HasParameter selector when one or both of
% 'ParameterProperty' and 'ParameterName' was specified.
hasParameterProperty = isfield(selectionCriteria, 'ParameterProperty');
hasParameterName = isfield(selectionCriteria, 'ParameterName');

if hasParameterProperty || hasParameterName
    propertyArgs = {};
    if hasParameterProperty
        propertyArgs = {'Property', convertValueToMatchesConstraint(selectionCriteria.ParameterProperty,'ParameterProperty')};
    end
    
    nameArgs = {};
    if hasParameterName
        nameArgs = {'Name', convertValueToMatchesConstraint(selectionCriteria.ParameterName,'ParameterName')};
    end
    
    selector = HasParameter(propertyArgs{:}, nameArgs{:});
else
    selector = {};
end
end

function selector = handleName(selectionCriteria)
import matlab.unittest.selectors.HasName;

if isfield(selectionCriteria, 'Name')
    selector = HasName(convertValueToMatchesConstraint(selectionCriteria.Name,'Name'));
else
    selector = {};
end
end

function selector = handleBaseFolder(selectionCriteria)
import matlab.unittest.selectors.HasBaseFolder;

if isfield(selectionCriteria, 'BaseFolder')
    constraint = convertValueToMatchesConstraint(selectionCriteria.BaseFolder,'BaseFolder');
    if ispc
        constraint = constraint.ignoringCase;
    end
    selector = HasBaseFolder(constraint);
else
    selector = {};
end
end

function selector = handleTag(selectionCriteria)
import matlab.unittest.selectors.HasTag;

if isfield(selectionCriteria, 'Tag')
    selector = HasTag(convertValueToMatchesConstraint(selectionCriteria.Tag,'Tag'));
else
    selector = {};
end
end

function selector = handleProcedureName(selectionCriteria)
import matlab.unittest.selectors.HasProcedureName
if isfield(selectionCriteria, 'ProcedureName')
    selector = HasProcedureName(convertValueToMatchesConstraint(selectionCriteria.ProcedureName,'ProcedureName'));
else
    selector = {};
end
end

function selector = handleSuperclass(selectionCriteria)
import matlab.unittest.selectors.HasSuperclass
if isfield(selectionCriteria, 'Superclass')
    selector = HasSuperclass(selectionCriteria.Superclass);
else
    selector = {};
end
end

function constraint = convertValueToMatchesConstraint(value, criteria)
import matlab.unittest.constraints.Matches;
matlab.unittest.internal.validateNonemptyText(value,criteria);
value = char(value);
constraint = Matches(['^', regexptranslate('wildcard',value), '$']);
end

function selector = combineSelectors(selectors)
import matlab.unittest.internal.selectors.NeverFilterSelector;

selectors = selectors(cellfun(@(s)~isempty(s), selectors));

if isempty(selectors)
    selector = NeverFilterSelector;
else
    % Use AND operator to combine all the individual selectors together
    % into a single AndSelector.
    selector = selectors{1};
    for idx = 2:numel(selectors)
        selector = selector & selectors{idx};
    end
end
end
