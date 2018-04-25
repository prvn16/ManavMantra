function bw = grayconnected(I, r, c, tolerance)  %#codegen
%grayconnected   Select contiguous image region with similar gray values.
%   BW = grayconnected(I, ROW, COLUMN, TOLERANCE) creates a logical mask BW
%   of pixels in the grayscale image I with similar values to the seed
%   pixel at ROW and COLUMN. TOLERANCE specifies the range of intensity
%   values to include in the mask, selecting pixel intensities in the range
%   [(seed value - TOLERANCE), (seed value + TOLERANCE)]. All of the fore-
%   ground pixels in BW are 8-connected to the seed pixel at (ROW, COLUMN)
%   by pixels of similar intensity. ROW and COLUMN must be scalars.
%
%   BW = GRAYCONNECTED(I, ROW, COLUMN) finds connected regions of similar
%   intensity using a default TOLERANCE of 32 for integer images and 0.1
%   for floating point images.
%
%   Class Support
%   -------------
%   The input image I must be a real, non-sparse 2D matrix of the following
%   classes: uint8, int8, uint16, int16, uint32, int32, single or double. 
%
%   Example
%   -------
%   % Find pixels connected to pixel (4,1) within 3 gray levels (i.e., in
%   % the range [20, 26]).
%   I = uint8([20 22 24 23 25 20 100
%              21 10 12 13 12 30 6
%              22 11 13 12 13 25 5
%              23 13 13 13 13 20 5
%              24 13 13 12 12 13 5
%              25 26  5 28 29 50 6]);
%
%   BW = grayconnected(I, 4, 1, 3)
%
%   See also imfill, bwselect, imageSegmenter.

% Copyright 2015 The MathWorks, Inc.

%#ok<*EMCA>

allowedInputTypes = {'uint8', 'int8', 'uint16', 'int16', 'uint32', 'int32', 'single', 'double'};

validateattributes(I, allowedInputTypes, {'2d', 'nonempty', 'real', 'nonsparse'}, ...
    'grayconnected', 'I', 1)
validateattributes(r, allowedInputTypes, {'scalar', 'real', 'integer', 'positive', '<=', size(I,1)}, ...
    'grayconnected', 'ROW', 2)
validateattributes(c, allowedInputTypes, {'scalar', 'real', 'integer', 'positive', '<=', size(I,2)}, ...
    'grayconnected', 'COLUMN', 3)

coder.internal.assert(coder.internal.isConst(size(r)), 'images:grayconnected:mustBeConst', 'ROW');
coder.internal.assert(coder.internal.isConst(size(c)), 'images:grayconnected:mustBeConst', 'COLUMN');

if (nargin == 3)
    if isfloat(I)
        tolerance = 0.1;
    else
        tolerance = 32;
    end
else
    validateattributes(tolerance, allowedInputTypes, ...
        {'scalar', 'real', 'nonnegative', 'finite'}, 'grayconnected', 'TOLERANCE', 4)
    coder.internal.assert(coder.internal.isConst(size(tolerance)), 'images:grayconnected:mustBeConst', 'TOLERANCE');
end

bw = images.internal.grayconnectedAlgo(I, double(r(1)), double(c(1)), double(tolerance(1))); % Index into scalars for codegen.

end
