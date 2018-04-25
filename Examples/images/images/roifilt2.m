function J = roifilt2(varargin)
%ROIFILT2 Filter region of interest.
%   J = ROIFILT2(H,I,BW) filters the data in I with a 2-D filter H. BW is a
%   binary image the same size as I that is used as a mask for
%   filtering. ROIFILT2 returns an image that consists of filtered values for
%   pixels in locations where BW contains 1's, and unfiltered values for
%   pixels in locations where BW contains 0's. For this syntax, ROIFILT2 calls
%   IMFILTER to implement the filter.
%
%   J = ROIFILT2(I,BW,FUN) processes the data in I using the function FUN. The
%   result J contains computed values for pixels in locations where BW
%   contains 1's, and the actual values in I for pixels in locations where BW
%   contains 0's.
%
%   FUN must be a FUNCTION_HANDLE.
%
%   Class Support
%   -------------
%   For the syntax that includes a filter H, the input image can be logical or
%   numeric, and the output array J has the same class as the input image. For
%   the syntax that includes a function, I can be any class supported by FUN,
%   and the class of J depends on the class of the output from FUN.
%
%   Example
%   -------
%       I = imread('eight.tif');
%       c = [222 272 300 270 221 194];
%       r = [21 21 75 121 121 75];
%       BW = roipoly(I,c,r);
%       H = fspecial('unsharp');
%       J = roifilt2(H,I,BW);
%       figure, imshow(I), figure, imshow(J)
%
%   See also IMFILTER, FILTER2, FUNCTION_HANDLE, ROIPOLY.

%   Copyright 1993-2011 The MathWorks, Inc.

% Obsolete syntax:
%   J = ROIFILT2(I,BW,FUN,P1,P2,...) passes the additional parameters
%   P1,P2,..., to FUN.

[H, J, BW, params, fcnflag] = parse_inputs(varargin{:});

% Assigning default value to minrow.  In the case when J = ROIFILT2(H, I,
% BW), minrow will be set to at least one.
minrow = 0;

if fcnflag == 1 
    %case when J = ROIFILT2(I, BW, 'fun', P1,...)
    filtI = feval(H, J, params{:});
    
    if ~isa(J, class(filtI))
        J = feval(class(filtI), J);  
    end
else 
    % case when J = ROIFILT2(H, I, BW).  Determine rectangle that encloses
    % the non-zero elements in BW.  The rectangle vector is chosen so that
    % no non-zero element in J is considered to be a boundary pixel by
    % imfilter.  In other words, the row and column padding should be equal
    % to the row size and column size of H, respectively.  Also, rectangle
    % cannot be bigger than size of original image.
    [row, col] = find(BW==1);
    colpad = ceil(size(H, 2) / 2);
    rowpad = ceil(size(H, 1) / 2);
    mincol = max(1, min(col(:)) - colpad);
    minrow = max(1, min(row(:)) - rowpad); 
    maxcol = min(size(J, 2), max(col(:)) + colpad);
    maxrow = min(size(J, 1), max(row(:)) + rowpad);
    
    % perform filtering on y that is cropped to the rectangle. 
    I = J;
    J = J(minrow:maxrow, mincol:maxcol);
    BW = BW(minrow:maxrow, mincol:maxcol);
    filtI = imfilter(J, H);
end

if ~isequal(size(filtI), size(J)) 
    error(message('images:roifilt2:imageSizeMismatch'));
end

J(BW) = filtI(BW);

if minrow ~= 0
    % case when J = ROIFILT2(H ,I, BW).
    I(minrow: maxrow, mincol: maxcol) = J;
    J = I;
end

%------------------------------------------------------------------------
function [filter, I, mask, param, flag] = parse_inputs(varargin)
% filter    filter for image: can be a function or array
% I         image: 2-D array
% mask      mask: logical array to delineate the ROI
% param     function parameters if filter is function
% flag      flag to indicate that filter is a function

       
% check number of inputs
narginchk(3, inf)

% initialize elements
flag = 0;
param = varargin(4:end);

[fun,fcnchk_msg] = fcnchk(varargin{3}, length(param));

if isempty(fcnchk_msg)
    % J = ROIFILT2(I,BW,'fun',P1,...)
    I = varargin{1};      
    mask = varargin{2};
    filter = fun;
    flag = 1;
else
    % J = ROIFILT2(H, I, BW)
    filter = varargin{1};
    I = varargin{2};
    mask = varargin{3};
end

if (ndims(I) ~=  2)
    error(message('images:roifilt2:imageMustBe2D'));
end

if ~islogical(mask)
    mask = mask ~= 0;
end

if ~isequal(size(mask),size(I))
    error(message('images:roifilt2:imageMaskSizeMismatch'));
end
