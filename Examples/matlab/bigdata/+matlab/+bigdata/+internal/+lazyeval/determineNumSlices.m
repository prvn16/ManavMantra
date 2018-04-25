function numSlices = determineNumSlices(varargin)
%DETERMINENUMSLICES Determines the number of slices in the input.
%
% This makes the assumption that all inputs are equally sized or singleton
% in the first dimension.

%   Copyright 2016 The MathWorks, Inc.

if ~nargin
    numSlices = 0;
    return;
end

for ii = 1:numel(varargin)
    height = size(varargin{ii}, 1);
    if height ~= 1
        numSlices = height;
        return;
    end
end

numSlices = 1;