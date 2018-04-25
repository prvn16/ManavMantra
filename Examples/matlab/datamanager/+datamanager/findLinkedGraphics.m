function [gObj,gCustom] = findLinkedGraphics(container)

% Copyright 2010-2015 The MathWorks, Inc.

% Find graphic objects which can support linking.

% Find all objects with data sources
gObj = findobj(container,'-property','YDataSource','-or','-property',...
    'XDataSource','-or','-property','ZDataSource');
gObj = findobj(gObj,'flat','BeingDeleted','off');

% Find all objects with linked behavior objects
if isobject(container)
    gCustom = findPrimitiveDataWithLinkedBehavior(container);
else
    gCustom = findobj(container,...
        '-and','-not',{'Behavior',struct},...
       '-function',@localHasLinkedBehavior);    
end
gCustom = findobj(gCustom,'flat','BeingDeleted','off');

% Exclude objects with disabled behavior objects from both the regular and
% custom lists.
if ~isempty(gCustom)
    gExcluded = findobj(gCustom,'-function',@localHasDisabledLinkedBehavior);
    gObj = setdiff(gObj,gExcluded);
    gCustom = setdiff(gCustom,gExcluded);
end

function state = localHasLinkedBehavior(h)

state = ~isempty(hggetbehavior(h,'linked','-peek'));

function state = localHasDisabledLinkedBehavior(h)

bh = hggetbehavior(h,'linked','-peek');
state = ~isempty(bh) && ~bh.Enable;
