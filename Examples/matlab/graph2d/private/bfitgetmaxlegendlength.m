function maxLength = bfitgetmaxlegendlength()
% BFITGETMAXLEGENDLENGTH Get the length of the longest legend entry on the
% Data Stats and Basic Fitting GUI figures.

%   Copyright 2011 The MathWorks, Inc.

% Set a minimum length to be 16
minLength = 16;

% Get the IDs of all "static" legend entries
messageIDs = {'MATLAB:graph2d:bfit:DisplayNameSpline', ...
              'MATLAB:graph2d:bfit:DisplayNameShapePreserving', ...
              'MATLAB:graph2d:bfit:DisplayNameLinear', ...
              'MATLAB:graph2d:bfit:DisplayNameQuadratic', ...
              'MATLAB:graph2d:bfit:DisplayNameCubic', ...
              'MATLAB:graph2d:bfit:LegendStringMin', ...
              'MATLAB:graph2d:bfit:LegendStringMax', ...
              'MATLAB:graph2d:bfit:LegendStringMean', ...
              'MATLAB:graph2d:bfit:LegendStringMedian', ...
              'MATLAB:graph2d:bfit:LegendStringMedian', ...
              'MATLAB:graph2d:bfit:LegendStringStd'};
          
% Get the number of elements in all the "static" legend entries
numElements = cellfun(@(input)  numel(getString(message(input))), messageIDs);

% Get the number of elements in the Nth degree with a two digit number
numElementsNthDegree = numel(getString(message('MATLAB:graph2d:bfit:DisplayNameNthDegree', 10)));

% Get the maximum length
maxLength = max([minLength, numElements, numElementsNthDegree]);