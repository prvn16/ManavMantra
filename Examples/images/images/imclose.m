function B = imclose(A, se_) %#codegen
%IMCLOSE Morphologically close image.
%   IM2 = IMCLOSE(IM,SE) performs morphological closing on the
%   grayscale or binary image IM with the structuring element SE.  SE
%   must be a single structuring element object, as opposed to an array
%   of objects.
%
%   IMCLOSE(IM,NHOOD) performs closing with the structuring element
%   STREL(NHOOD), where NHOOD is an array of 0s and 1s that specifies the
%   structuring element neighborhood.
%
%   The morphological close operation is a dilation followed by an erosion,
%   using the same structuring element for both operations.
%
%   Class Support
%   -------------
%   IM can be any numeric or logical class and any dimension, and must be
%   nonsparse.  If IM is logical, then SE must be flat.  IM2 has the same
%   class as IM.
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
%       closeBW = imclose(originalBW,se);
%       figure, imshow(closeBW);
%
%   See also IMDILATE, IMERODE, IMOPEN, STREL.

%   Copyright 1993-2017 The MathWorks, Inc.

validateattributes(A, ...
    {'numeric' 'logical'}, ...
    {'real' 'nonsparse'},...
    mfilename, 'I or BW', 1);

se = images.internal.strelcheck(se_, mfilename, 'SE', 2);

coder.internal.errorIf((length(se(:)) > 1),...
    'images:imclose:nonscalarStrel');

strel_is_flat    = coder.const(isflat(se));
input_is_logical = coder.const(islogical(A));
strel_is_2d      = coder.const(ismatrix(getnhood(se)));

coder.internal.errorIf((input_is_logical && ~strel_is_flat), ...
    'images:imclose:binaryImageWithNonflatStrel');

input_is_2d = coder.const(numel(size(A))==2);

pre_pack_ = coder.const(input_is_logical && input_is_2d && strel_is_2d);
coder.extrinsic('images.internal.coder.isCodegenForHost');
coder.extrinsic('images.internal.coder.useSharedLibrary');
if(coder.target('MATLAB'))
    pre_pack = pre_pack_;
else
    % packed inputs are only supported in shared library mode (host)
    pre_pack = pre_pack_ ...
        && ~coder.const(images.internal.coder.isCodegenForHost())...
        && coder.const(images.internal.coder.useSharedLibrary());
end

pre_pack = coder.const(pre_pack);

% Pad with background half strel wide
padSize = ceil(size(getnhood(se))/2);
padSize = padSize(1:min(numel(padSize),ndims(A)));
Ap      = padarray(A,padSize,'both');

M = size(Ap,1);

if pre_pack
    inputImage = bwpack(Ap);
    packopt = 'ispacked';
    outputImage = imerode(imdilate(inputImage,se,packopt,M),se,packopt,M);
    Bp = bwunpack(outputImage,M);
else
    inputImage = Ap;
    packopt = 'notpacked';
    Bp = imerode(imdilate(inputImage,se,packopt,M),se,packopt,M);
end

% un-pad
if ismatrix(A)
    B = Bp(padSize(1)+1:end-padSize(1), ...
        padSize(2)+1:end-padSize(2));
elseif ndims(A)==3
    if numel(padSize)==3
        B = Bp(padSize(1)+1:end-padSize(1), ...
            padSize(2)+1:end-padSize(2), ...
            padSize(3)+1:end-padSize(3));
    else
        B = Bp(padSize(1)+1:end-padSize(1), ...
            padSize(2)+1:end-padSize(2), ...
            :);
    end
else
    if(coder.target('MATLAB')) % Only simulation supports N-D
        subsUnPad.type = '()';
        subsUnPad.subs = {};
        for dInd=1:numel(padSize)
            subsUnPad.subs{dInd} = padSize(dInd)+1: size(Bp,dInd)-padSize(dInd);
        end
        dInd = numel(padSize)+1;
        while(dInd<=ndims(A))
            subsUnPad.subs{dInd} = 1: size(Bp,dInd);
            dInd=dInd+1;
        end
        B = subsref(Bp, subsUnPad);
    else
        % For branch completeness, wont be hit.
        B = Bp;
    end
end

end
