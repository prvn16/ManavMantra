function B = bwlookup(varargin)
%BWLOOKUP Neighborhood operations using a lookup table.
%   A = BWLOOKUP(BW,LUT) performs a 2-by-2 or 3-by-3 nonlinear neighborhood
%   filtering operation on binary or grayscale image BW. LUT is either a
%   16-element or 512-element vector returned by MAKELUT. The neighborhood
%   of pixels in BW determine an integer value, this value is used as the
%   index to look up the output pixel values from LUT.
%
%   The index is obtained by treating the neighborhood of a pixel as a
%   binary integer with the following bit position assignment (1 denotes
%   the position of the least significant bit):
%
%   2-by-2                    3-by-3
%           1*  3                     1  4  7
%           2   4                     2  5* 8
%                                     3  6  9
%
%                                      * indicates the neighborhood center.
%   Class Support
%   -------------
%   BW can be numeric or logical. In case of the numeric input,
%   any non-zero pixels are considered to be "on". 
%
%   LUT can be numeric or logical, and it must be a real vector with 16
%   or 512 elements.
%
%   A is the same type as LUT.
%
%   Example
%   -------
%   In this example, you perform erosion using a 2-by-2 neighborhood. An
%   output pixel is "on" only if all four of the input pixel's
%   neighborhood pixels are "on." 
%
%       lutfun = @(x)(sum(x(:))==4);
%       lut    = makelut(lutfun,2);
%       BW1    = imread('text.png');
%       BW2    = bwlookup(BW1,lut);
%       figure, imshow(BW1);
%       figure, imshow(BW2);
%
%   See also MAKELUT, FUNCTION_HANDLE.

%   Copyright 2012-2013 The MathWorks, Inc.

[A,lut] = ParseInputs(varargin{:});

B = bwlookupmex(A,lut);

%--------------------------------------------------------------------------
function [A,lut] = ParseInputs(varargin)

narginchk(2,2);
validateattributes(varargin{1}, ...
    {'numeric','logical'},...
    {'real','nonsparse','2d'}, ...
    mfilename, 'A', 1);
validateattributes(varargin{2}, ...
    {'numeric','logical'},...
    {'real','vector'}, ...
    mfilename, 'LUT', 2);

% force A to be logical
A = varargin{1};
if ~islogical(A)
    A = A ~= 0;
end

lut = varargin{2};
if(numel(lut)~=16 && numel(lut)~=512)
    error(message('images:bwlookup:invalidLUTLength'));
end
