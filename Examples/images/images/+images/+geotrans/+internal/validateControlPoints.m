function validateControlPoints(movingPoints,fixedPoints) %#codegen
%   FOR INTERNAL USE ONLY -- This function is intentionally
%   undocumented and is intended for use only within other toolbox
%   classes and functions. Its behavior may change, or the feature
%   itself may be removed in a future release.
%
%   validateControlPoints(movingPoints,fixedPoints) performs input argument
%   validate on specified matched control point matrices movingPoints and
%   fixedPoints.

% Copyright 2012-2013 The MathWorks, Inc.

%#ok<*EMCA>

validateattributes(movingPoints,{'single','double'},{'2d','real','finite','nonsparse','ncols',2},mfilename,'movingPoints');
validateattributes(fixedPoints,{'single','double'},{'2d','real','finite','nonsparse','ncols',2},mfilename,'fixedPoints');

coder.internal.errorIf(~isequal(size(movingPoints),size(fixedPoints)),...
    'images:geotrans:differentNumbersOfControlPoints','fixedPoints','movingPoints');
