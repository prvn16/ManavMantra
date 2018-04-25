function J = stdfilt(varargin)
%STDFILT Local standard deviation of image.
%   J = STDFILT(I) returns a gpuArray J, where each output pixel contains
%   the standard deviation value of the 3-by-3 neighborhood around the
%   corresponding pixel in the input gpuArray image I. I can have any
%   dimension. The output image J is the same size as the input image I.
%
%   For pixels on the borders of I, STDFILT uses symmetric padding.  In
%   symmetric padding, the values of padding pixels are a mirror reflection
%   of the border pixels in I.
%
%   J = STDFILT(I,NHOOD) performs standard deviation filtering of the input
%   gpuArray image I where you specify the neighborhood in NHOOD.  NHOOD is
%   either a vector or a 2D matrix of zeros and ones where the nonzero
%   elements specify the neighbors.  NHOOD's size must be odd in each
%   dimension.
%
%   By default, STDFILT uses the neighborhood ones(3). STDFILT determines
%   the center element of the neighborhood by FLOOR((SIZE(NHOOD) + 1)/2).
%   For information about specifying neighborhoods, see Notes.
%
%   Class Support
%   -------------
%   I can be logical or numeric gpuArray and must be real.  NHOOD can
%   be logical or numeric and must contain zeros and/or ones.
%   J is double.
%
%   Remarks
%   -------
%   The GPU implementation of this function only supports 2D neighborhoods.
%
%   Notes
%   -----
%   To specify the neighborhoods of various shapes, such as a disk, use the
%   STREL function to create a structuring element object and then use the
%   GETNHOOD function to extract the neighborhood from the structuring
%   element object.
%
%   Examples
%   --------
%       I = gpuArray(imread('circuit.tif'));
%       J = stdfilt(I);
%       imshow(I);
%       figure, imshow(J,[]);
%
%   See also GPUARRAY/STD2, RANGEFILT, ENTROPYFILT, STREL, STREL/GETNHOOD,
%            GPUARRAY.

%   Copyright 2013-2015 The MathWorks, Inc.

narginchk(1,2);

I = varargin{1};

if(~isa(I,'gpuArray'))
    % This has to be the two input syntax, with NHOOD on the GPU.
    % Call CPU version
    h = gather(varargin{2});
    J = stdfilt(I,h);
    return;
end

if nargin == 2
    h = gpuArray(varargin{2});

    hValidateAttributes(h,...
    {'logical','uint8','int8','uint16','int16','uint32','int32','single','double'},...
    {'real','2d','nonsparse'},mfilename,'NHOOD',2);
    
    % h must contain zeros and/or ones.
    bad_elements = (h ~= 0) & (h ~= 1);
    s.type ='()';
    s.subs = {':'};
    if any(subsref(bad_elements,s))
        error(message('images:stdfilt:invalidNeighborhoodValue'))
    end
    
    % h's size must be a factor of 2n-1 (odd).
    sizeH = size(h);
    if ~all(rem(sizeH,2))
        error(message('images:stdfilt:invalidNeighborhoodSize'))
    end
    
    if ~isa(h,'double')
        h = double(h);
    end
    
else
    h = gpuArray.ones(3);
end

hValidateAttributes(I,...
    {'logical','uint8','int8','uint16','int16','uint32','int32','single','double'},...
    {'real','nonsparse'},mfilename,'I',1);


if (~strcmp(classUnderlying(I),'double'))
    I = double(I);
end

J = images.internal.algstdfilt(I,h);

end