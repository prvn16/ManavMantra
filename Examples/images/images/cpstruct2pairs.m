function [movingPoints,fixedPoints] = cpstruct2pairs(varargin)
%CPSTRUCT2PAIRS Convert CPSTRUCT to control point pairs.
%   [MOVINGPOINTS, FIXEDPOINTS] = CPSTRUCT2PAIRS(CPSTRUCT) takes a CPSTRUCT
%   (produced by CPSELECT) and returns the coordinates of valid control
%   point pairs in MOVINGPOINTS and FIXEDPOINTS.  CPSTRUCT2PAIRS eliminates
%   unmatched points and predicted points.
%
%   Example
%   -------
%   Start cpselect.
%
%       aerial = imread('westconcordaerial.png');
%       cpselect(aerial(:,:,1),'westconcordorthophoto.png')
%
%   Using CPSELECT, pick control points in the images.  Select "Export To
%   Workspace" from the File menu to save the points to the workspace.
%   On the "Save" dialog box, check the "Structure with all points"
%   checkbox and uncheck "Moving points" and "Fixed points."  Click OK.
%   Use CPSTRUCT2PAIRS to extract the input and base points from the
%   CPSTRUCT.
%
%       [movingPoints,fixedPoints] = cpstruct2pairs(cpstruct);
%
%  See also CPSELECT, FITGEOTRANS, IMWARP.

%   Copyright 1993-2013 The MathWorks, Inc.

% MOVINGPOINTS is M-by-2
% FIXEDPOINTS is M-by-2

narginchk(1,1);

movingPoints = [];
fixedPoints = [];

cpstruct = varargin{1};
if ~iscpstruct(cpstruct)
    error(message('images:cpstruct2pairs:invalidCpStruct'));
end

if length(cpstruct) ~= 1
    error(message('images:cpstruct2pairs:onlyOneCpStructCanBeProcessed'));
end

if ~isempty(cpstruct.inputBasePairs)
    predicted_input = cpstruct.isInputPredicted(cpstruct.inputBasePairs(:,1));
    predicted_base = cpstruct.isBasePredicted(cpstruct.inputBasePairs(:,2));
    predicted_pairs = predicted_input | predicted_base;

    valid_pairs = cpstruct.inputBasePairs(~predicted_pairs,:);
    movingPoints = cpstruct.inputPoints(valid_pairs(:,1),:);
    fixedPoints = cpstruct.basePoints(valid_pairs(:,2),:);
end
