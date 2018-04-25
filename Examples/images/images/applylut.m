function B = applylut(varargin)
%APPLYLUT Neighborhood operations using lookup tables.
%
%   APPLYLUT is not recommended. Use BWLOOKUP instead.
%
%   A = APPLYLUT(BW,LUT) performs a 2-by-2 or 3-by-3 neighborhood
%   operation on binary image BW by using a lookup table (LUT).  LUT is
%   either a 16-element or 512-element vector returned by MAKELUT.  The
%   vector consists of the output values for all possible 2-by-2 or
%   3-by-3 neighborhoods.
%
%   Class Support
%   -------------
%   BW can be numeric or logical, and it must be real,
%   two-dimensional, and nonsparse.
%
%   LUT can be numeric or logical, and it must be a real vector with 16
%   or 512 elements.
%
%   If all the elements of LUT are 0 or 1, then A is logical; otherwise,
%   if all the elements of LUT are integers between 0 and 255, then A is
%   uint8; otherwise, A is double.
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
%       BW2    = applylut(BW1,lut);
%       figure, imshow(BW1);
%       figure, imshow(BW2);
%
%   See also MAKELUT, FUNCTION_HANDLE.

%   Copyright 1993-2012 The MathWorks, Inc.

[A,lut] = ParseInputs(varargin{:});
B       = applylutc(A,lut);

%--------------------------------------------------------------------------
function [A,LUT] = ParseInputs(varargin)

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

inLUT = varargin{2};
% Cast LUT to appropriate class based on range of values.
outputClass = 'uint8';

if(all( inLUT==0.0 ...                     % If all elements are either 0
        | inLUT==1.0 ))                    % or 1
    outputClass = 'logical';
    
elseif( ~all(isfinite(inLUT)) ...          % If at least one is not finite
        || any(inLUT ~= (floor(inLUT)))... % not integer valued
        || any(inLUT<0.0)...               % less than 0
        || any(inLUT>255.0))               % or greater than 255    
    outputClass = 'double';
end



LUT = cast(inLUT, outputClass);