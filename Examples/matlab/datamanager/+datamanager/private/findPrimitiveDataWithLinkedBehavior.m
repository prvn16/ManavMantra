function gCustom = findPrimitiveDataWithLinkedBehavior(container)

% Copyright 2011-2015 The MathWorks, Inc.

% Find matlab.graphics.primitive.Data objects which can support linking
% via a linked behavior object
gCustom = findobj(container,'-isa','matlab.graphics.primitive.Data',...
        '-and','-not',{'Behavior',struct},...
       '-function',@localHasLinkedBehavior);

function state = localHasLinkedBehavior(h)

state = ~isempty(hggetbehavior(h,'linked','-peek'));


