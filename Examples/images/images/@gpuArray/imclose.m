function B = imclose(A, se)
%IMCLOSE Morphologically close image.
%   IM2 = IMCLOSE(IM,SE) performs morphological closing on the grayscale
%   or binary gpuArray image IM with the structuring element SE.  SE must 
%   be a single structuring element object, as opposed to an array of
%   objects.
%
%   IM2 = IMCLOSE(IM,NHOOD) performs closing with the structuring element
%   STREL(NHOOD), if NHOOD is an array of 0s and 1s that specifies the
%   structuring element neighborhood or STREL(GATHER(NHOOD)) if NHOOD is a
%   gpuArray object with 0s and 1s that specify the structuring element
%   neighborhood.
%
%   The morphological close operation is a dilation followed by an erosion,
%   using the same structuring element for both operations.
%
%   Class Support
%   -------------
%   IM must be a gpuArray of type uint8 or logical. It can have any
%   dimension. The output has the same class as the input.
%
%   Notes
%   -----
%   1.  The structuring element must be flat, and its neighborhood must be 
%       two-dimensional.
%   2.  Packed binary images are not supported on the GPU.
%
%   Example
%   -------
%   Use IMCLOSE on cirles.png image to join the circles together by filling
%   in the gaps between the circles and by smoothening their outer edges.
%   Use a disk structuring element to preserve the circular nature of the
%   object. Choose the disk element to have a radius of 10 pixels so that
%   the largest gap gets filled.
%
%       originalBW = imread('circles.png');
%       figure, imshow(originalBW);
%       se = strel('disk',10);
%       closeBW = imclose(gpuArray(originalBW),se);
%       figure, imshow(closeBW);
%
%   See also GPUARRAY/IMOPEN, GPUARRAY/IMDILATE, GPUARRAY/IMERODE, STREL,
%            GPUARRAY.

%   Copyright 2012-2016 The MathWorks, Inc.


% Dispatch to CPU.
if ~isa(A,'gpuArray')
    args = gatherIfNecessary(A, se);
    B = imclose(args{:});
    return;
end


% Ensure the strel is not a strel array.
if isa(se,'strel') && length(se(:)) > 1
    error(message('images:imclose:nonscalarStrel'));
end

% Parse and validate inputs.
% (Call to parser with 'erode' prevents strel reflection).
[A,se,padfull,unpad,~, padSize] = morphopInputParser(A,se,'erode',mfilename); 

% Pad
pad_val = cast(0,classUnderlying(A));
padSize(end+1:ndims(A))=0;
A = images.internal.gpu.constantpaduint8(A,padSize,pad_val,'both');    

% Dilate and then erode.
B = morphopAlgo(A,reflect2dFlatStrel(se),padfull,unpad,'dilate');
B = morphopAlgo(B,se,padfull,unpad,'erode');


% Unpad
subsUnPad.type = '()';
subsUnPad.subs = {};
for dInd=1:numel(padSize)
    subsUnPad.subs{dInd} = padSize(dInd)+1: size(B,dInd)-padSize(dInd);
end
dInd = dInd+1;
while(dInd<=ndims(A))
    subsUnPad.subs{dInd} = 1: size(B,dInd);
    dInd=dInd+1;
end
B = subsref(B, subsUnPad);
