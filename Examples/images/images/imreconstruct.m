function im = imreconstruct(varargin)
%IMRECONSTRUCT Morphological reconstruction.
%   IM = IMRECONSTRUCT(MARKER,MASK) performs morphological reconstruction
%   of the image MARKER under the image MASK.  MARKER and MASK can be two
%   intensity images or two binary images with the same size; IM is an
%   intensity or binary image, respectively.  MARKER must be the same size
%   as MASK, and its elements must be less than or equal to the
%   corresponding elements of MASK. Values greater than corresponding
%   elements in MASK will be clipped to the MASK level.
%
%   By default, IMRECONSTRUCT uses 8-connected neighborhoods for 2-D
%   images and 26-connected neighborhoods for 3-D images.  For higher
%   dimensions, IMRECONSTRUCT uses CONNDEF(NDIMS(I),'maximal').
%
%   IM = IMRECONSTRUCT(MARKER,MASK,CONN) performs morphological
%   reconstruction with the specified connectivity.  CONN may have the
%   following scalar values:
%
%       4     two-dimensional four-connected neighborhood
%       8     two-dimensional eight-connected neighborhood
%       6     three-dimensional six-connected neighborhood
%       18    three-dimensional 18-connected neighborhood
%       26    three-dimensional 26-connected neighborhood
%
%   Connectivity may be defined in a more general way for any dimension by
%   using for CONN a 3-by-3-by- ... -by-3 matrix of 0s and 1s.  The 1-valued
%   elements define neighborhood locations relative to the center element of
%   CONN.  CONN must be symmetric about its center element.
%
%   Morphological reconstruction is the algorithmic basis for several
%   other Image Processing Toolbox functions, including IMCLEARBORDER,
%   IMEXTENDEDMAX, IMEXTENDEDMIN, IMFILL, IMHMAX, IMHMIN, and
%   IMIMPOSEMIN.
%
%   Class support
%   -------------
%   MARKER and MASK must be nonsparse numeric (including uint64 or int64)
%   or logical arrays with the same class and any dimension.  IM is of the
%   same class as MARKER and MASK.
%
%   Performance Note
%   ----------------
%   This function may take advantage of hardware optimization for datatypes
%   logical, uint8, uint16, single and double to run faster.  Hardware 
%   optimization requires MARKER and MASK to be 2-D images and CONN to be 
%   either 4 or 8.
%
%   Example 1
%   ---------
%   Perform opening-by-reconstruction to identify high intensity snowflakes.
%
%       I = imread('snowflakes.png');
%       mask = adapthisteq(I);
%       se = strel('disk',5);
%       marker = imerode(mask,se);
%       obr = imreconstruct(marker,mask);
%       figure, imshow(mask,[]), figure, imshow(obr,[])
%
%   Example 2
%   ---------
%   Segment the letter "w" from text.png.
%
%       mask = imread('text.png');
%       marker = false(size(mask));
%       marker(13,94) = true;
%       im = imreconstruct(marker,mask);
%       figure, imshow(mask), figure, imshow(im)
%
%   See also IMCLEARBORDER, IMEXTENDEDMAX, IMEXTENDEDMIN, IMFILL, IMHMAX,
%            IMHMIN, IMIMPOSEMIN.

%   Copyright 1993-2016 The MathWorks, Inc.

[marker,mask,conn] = parseInputs(varargin{:});
connb              = images.internal.getBinaryConnectivityMatrix(conn);
modeFlag           = getModeFlag(marker, connb);

im = imreconstructmex(marker, mask, connb, modeFlag);


%---------------------------------------------------
function modeFlag = getModeFlag(marker, connb)

modeFlag = 0;                       % default

if (    images.internal.useIPPLibrary()...
        &&...
        ismatrix(marker)...         % 2D
        && (...
        isa(marker,'logical') ||...
        isa(marker,'uint8')   ||...
        isa(marker,'uint16')  ||...
        isa(marker,'single')  ||...
        isa(marker,'double')    ...
        ))

   if( isequal(connb, [ false true false
                        true  true true
                        false true false]))
       modeFlag = 1;                       % four connectivity
   elseif(isequal(connb, true(3,3)))
       modeFlag = 2;                       % eight connectivity
   end

end


%---------------------------------------------------
function [Marker,Mask,Conn] = parseInputs(varargin)
% Parse input arguments. Choose a default 'maximal' connectivity if one is
% not provided.

narginchk(2,3);
validateattributes(varargin{1},...
    {'numeric','logical'},...
    {'real','nonsparse', 'nonnan'},...
    mfilename, 'MARKER', 1);
validateattributes(varargin{2},...
    {'numeric','logical'},...
    {'real','nonsparse','nonnan'},...
    mfilename, 'MASK', 2);

Marker = varargin{1};
Mask   = varargin{2};

if(~isa(Marker, class(Mask)))
    % marker and mask must be of the same numeric class
    error(message('images:imreconstruct:notSameClass'));
end
if(~isequal(size(Marker), size(Mask)))
    % marker and mask must have the same size
    error(message('images:imreconstruct:notSameSize'));
end

if nargin==3
    iptcheckconn(varargin{3},mfilename,'CONN',3);
    Conn = varargin{3};
else
    Conn = conndef(ndims(Marker), 'maximal');
end
