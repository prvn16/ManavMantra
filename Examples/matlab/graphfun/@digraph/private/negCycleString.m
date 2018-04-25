function s = negCycleString(pred, nodeNames)
%NEGCYCLESTRING String description of negative cycle
%
%  Utility function for error messages. When there is a negative
%  cycle, this constructs the string description for the error message.
%  Used in shortestpath, shortestpathtree, nearest, distances.

%   Copyright 2014-2016 The MathWorks, Inc.

if isempty(nodeNames)
    
    if numel(pred) <= 20
        s = sprintf('%d ', pred);
    else
        s = sprintf('%d ', pred(1:20));
        s = [s '... '];
    end
    
    s = [s sprintf('%d', pred(1))];
    
else
    nodeNames = nodeNames.';
    pred = nodeNames(pred);
    
    if numel(pred) <= 20
        s = sprintf('%s ', pred{:});
    else
        s = sprintf('%s ', pred{1:20});
        s = [s '... '];
    end
    
    s = [s sprintf('%s', pred{1})];

end
