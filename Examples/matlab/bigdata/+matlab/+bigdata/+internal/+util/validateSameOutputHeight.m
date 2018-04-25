function height = validateSameOutputHeight(varargin)
% Validate that all the given outputs have the same height.

%   Copyright 2017 The MathWorks, Inc.

height = cellfun(@iHeight, varargin);
if any(height ~= height(1))
    incorrectIndex = find(height ~= height(1), 1, 'first');
    matlab.bigdata.internal.throw(...
        message('MATLAB:bigdata:array:InvalidOutputTallSize', ...
        incorrectIndex, height(incorrectIndex), height(1)));
end
height = height(1);
end

% Helper function for calculating the height.
function out = iHeight(in)
out = size(in,1);
end
