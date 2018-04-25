function B = imdilate(A,se,varargin) %#codegen
%IMDILATE Dilate image.
%   IM2 = IMDILATE(IM,SE) dilates the grayscale, binary, or packed binary
%   image IM, returning the dilated image, IM2.  SE is a structuring
%   element object, or array of structuring element objects, returned by
%   the STREL or OFFSETSTREL functions.
%
%   If IM is logical (binary), then the structuring element must be flat
%   and IMDILATE performs binary dilation.  Otherwise, it performs
%   grayscale dilation.  If SE is an array of structuring element
%   objects, IMDILATE performs multiple dilations, using each
%   structuring element in SE in succession.  
%
%   IM2 = IMDILATE(IM,NHOOD) dilates the image IM, where NHOOD is a
%   matrix of 0s and 1s that specifies the structuring element
%   neighborhood.  This is equivalent to the syntax IMDILATE(IM,
%   STREL(NHOOD)).  IMDILATE determines the center element of the
%   neighborhood by FLOOR((SIZE(NHOOD) + 1)/2).
%
%   IM2 = IMDILATE(IM,SE,PACKOPT) or IMDILATE(IM,NHOOD,PACKOPT) specifies
%   whether IM is a packed binary image.  PACKOPT can have either of
%   these values:
%
%       'ispacked'    IM is treated as a packed binary image as produced
%                     by BWPACK.  IM must be a 2-D uint32 array and SE
%                     must be a flat 2-D structuring element.  If the
%                     value of PACKOPT is 'ispacked', SHAPE must be
%                     'same'.
%
%       'notpacked'   IM is treated as a normal array.  This is the
%                     default value.
%
%   IM2 = IMDILATE(...,SHAPE) determines the size of the output image.
%   SHAPE can have either of these values:
%
%       'same'        Make the output image the same size as the input
%                     image.  This is the default value.  If the value of
%                     PACKOPT is 'ispacked', SHAPE must be 'same'.
%
%       'full'        Compute the full dilation.
%
%   Class Support
%   -------------
%   IM can be logical or numeric and must be real and nonsparse.  It can
%   have any dimension.  The output has the same class as the input. If
%   the input is packed binary, then the output is also packed binary.
%
%   Examples
%   --------
%   Dilate the binary image in text.png with a vertical line:
%
%       originalBW = imread('text.png');
%       se = strel('line',11,90);
%       dilatedBW = imdilate(originalBW,se);
%       figure, imshow(originalBW), figure, imshow(dilatedBW)
%
%   Dilate the grayscale image in cameraman.tif with a rolling ball:
%
%       originalI = imread('cameraman.tif');
%       se = offsetstrel('ball',5,5);
%       dilatedI = imdilate(originalI,se);
%       figure, imshow(originalI), figure, imshow(dilatedI)
%
%   Determine the domain of the composition of two flat structuring
%   elements by dilating the scalar value 1 with both structuring
%   elements in sequence, using the 'full' option:
%
%       se1 = strel('line',3,0);
%       se2 = strel('line',3,90);
%       composition = imdilate(1,[se1 se2],'full');
%
%   Dilate two points in 3D space using spherical structuring elements, so
%   that they take the shape of spheres:
%
%    % Create a logical 3D volume with two points.
%    BW = false(100,100,100);
%    BW(25,25,25) = true;
%    BW(75,75,75) = true;
%
%    % Dilate the 3D volume by a spherical structuring element
%    se = strel('sphere',25);
%    dilatedBW = imdilate(BW, se);
%
%    % Visualize the dilated image volume
%    figure, isosurface(dilatedBW)
%
%   See also BWHITMISS, BWPACK, BWUNPACK, CONV2, FILTER2, IMCLOSE, 
%            IMERODE, IMOPEN, STREL, OFFSETSTREL.

%   Copyright 1993-2015 The MathWorks, Inc.

% Testing notes
% Syntaxes
% --------
% B = imdilate(A,se)
% B = imdilate(A,se,packopt)
% B = imdilate(...,padopt)
%
% A:       numeric or logical, real, full, N-D array.  May be empty.
%          May contain Infs or NaNs.  Required.
%
% se:      A single STREL object, a STREL array, or a real, full, double,
%          N-D array containing 0s and 1s.  If se is an empty array of
%          strels, then B should be the same as A, unless the input is
%          logical and not packed, in which case B should be
%          uint8(A ~= 0).  If se contains no neighbors (e.g.,
%          strel(zeros(3,3))), then B should be filled with the minimum
%          value for its type.  Must be flat if A is logical.  Required.
%
% packopt: Either 'ispacked' or 'notpacked'.  May be abbreviated; case
%          insensitive match.  Optional.  Defaults to 'notpacked' if not
%          specified.
%
% padopt:  Either 'same' or 'full'.  May be abbreviated; case insensitive
%          match.  Optional.  Defaults to 'same' if not specified.
%
% B:       Array of the same size and class as A.  Exception: if A is
%          logical and the strel is all flat and packopt is 'notpacked',
%          then B is a logical uint8.
%
% Key logic branches:
%
% se:      flat or nonflat?
% se:      array or single strel?
% se:      decomposed or nondecomposed?
% se:      2-D or N-D?
% A:       logical or nonlogical?
% A:       uint8 or not?
% A:       uint32 or not?
% packopt: 'ispacked' or 'notpacked'?
% padopt:  'full' or 'same'?

narginchk(2,4);

B = images.internal.morphop(A,se,'dilate',mfilename,varargin{:});
