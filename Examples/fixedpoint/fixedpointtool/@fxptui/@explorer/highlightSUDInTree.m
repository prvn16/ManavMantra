function highlightSUDInTree(me)
% HIGHLIGHTSUDINTREE Highlights the system selected for conversion 

% Copyright 2014 The MathWorks, Inc.

if ~isempty(me.ConversionNode)
    me.highlight(me.ConversionNode, [0 0.7 0]);
end
