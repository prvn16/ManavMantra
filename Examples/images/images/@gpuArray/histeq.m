function [out,T] = histeq(varargin)
%HISTEQ Enhance contrast using histogram equalization.
%   HISTEQ enhances the contrast of images by transforming the values in an
%   intensity image so that the histogram of the output image approximately
%   matches a specified histogram.
%
%   J = HISTEQ(I,HGRAM) transforms the gpuArray intensity image I so that
%   the histogram of the output gpuArray image J with length(HGRAM) bins
%   approximately matches HGRAM. The gpuArray vector HGRAM should contain
%   integer counts for equally spaced bins with intensity values in the
%   appropriate range: [0,1] for images of class double or single, [0,255]
%   for images of class uint8, [0,65535] for images of class uint16, and
%   [-32768, 32767] for images of class int16. HISTEQ automatically scales
%   HGRAM so that sum(HGRAM) = NUMEL(I). The histogram of J will better
%   match HGRAM when length(HGRAM) is much smaller than the number of
%   discrete levels in I.
%
%   J = HISTEQ(I,N) transforms the gpuArray intensity image I, returning in
%   J a gpuArray intensity image with N discrete levels. A roughly equal
%   number of pixels is mapped to each of the N levels in J, so that the
%   histogram of J is approximately flat. (The histogram of J is flatter
%   when N is much smaller than the number of discrete levels in I.) The
%   default value for N is 64.
%
%   [J,T] = HISTEQ(I) returns the gray scale transformation that maps gray
%   levels in the intensity image I to gray levels in J.
%
%   Class Support
%   -------------
%   For syntaxes that include a gpuArray intensity image I as input, I can 
%   be uint8, uint16, int16, double or single. The output gpuArray image J 
%   has the same class as I.
%
%   Also, the optional output T (the gray level transform) is always a
%   gpuArray of class double.
%
%   Note
%   ----
%   I and X can be N-Dimentional images.
%
%   Example 1
%   ---------
%   Enhance the contrast of an intensity image using histogram
%   equalization.
%
%       I = gpuArray(imread('tire.tif'));
%       J = histeq(I);
%
%       % Display the original and enhanced images
%       figure
%       subplot(1,2,1)
%       imshow(I)
%       subplot(1,2,2)
%       imshow(J)
%
%   Example 2
%   ---------
%   Enhance the contrast of a volumetric image using histogram
%   equalization.
%
%       load mristack
%       mristack = gpuArray(mristack);
%       enhanced = histeq(mristack);
%
%       % Display the first slice of data
%       figure
%       subplot(1,2,1)
%       imshow(mristack(:,:,1))
%       subplot(1,2,2)
%       imshow(enhanced(:,:,1))
%
%   See also ADAPTHISTEQ, BRIGHTEN, GPUARRAY/IMADJUST, GPUARRAY/IMHIST,
%            IMHISTMATCH, GPUARRAY.

%   Copyright 2013-2016 The MathWorks, Inc.

narginchk(1,2);
nargoutchk(0,2);

im = varargin{1};

%Dispatch to CPU
if ~isa(im,'gpuArray')
    args = gatherIfNecessary(varargin{:});
    switch nargout
        case 0
            histeq(args{:});
            return;
        case 1
            out = histeq(args{:});
            return;
        case 2
            [out,T] = histeq(args{:});
            return;
    end
end

%Check image
hValidateAttributes(im,...
    {'uint8','uint16','int16','single','double'}, ...
    {'real','nonsparse'},mfilename,'I',1);
   
   
nLevelsIn = 256;  %Number of levels used in computing histogram over
                  %input image.

if nargin == 1
   %HISTEQ(I)
   nLevelsSpec = 64;          %Default number of levels for histogram equalization.
   hgramSpec = gpuArray.ones(nLevelsSpec,1)*(numel(im)/nLevelsSpec);
   
elseif nargin == 2
   if isscalar(varargin{2})
      %HISTEQ(I,N) 
      nLevelsSpec = gather(varargin{2});
      validateattributes(nLevelsSpec,{'single','double'},...
          {'nonsparse','integer','real','positive','scalar'},...
          mfilename,'N',2);    
      hgramSpec = gpuArray.ones(nLevelsSpec,1)*(numel(im)/nLevelsSpec);
   else
      %HISTEQ(I,HGRAM)
      hgramSpec = varargin{2};
      nLevelsSpec = numel(hgramSpec);
      if isa(hgramSpec,'gpuArray')
          hValidateAttributes(hgramSpec,...
              {'single','double'},...
              {'real','nonsparse','vector','nonempty'},mfilename,'hgram',2);
      else
          validateattributes(hgramSpec,...
              {'single','double'},...
              {'real','nonsparse','vector','nonempty'},...
              mfilename,'hgram',2);
      end
      
      %Convert hgram to a column vector.
      if ~iscolumn(hgramSpec)
          hgramSpec = hgramSpec';
      end
      
      %Normalize hgram so sum(hgram)=numel(im)
      hgramSpec = hgramSpec*(numel(im)/sum(hgramSpec));
   end
end

classChanged = false;
if strcmp(classUnderlying(im),'int16')
    classChanged = true;
    im = im2uint16(im);
end

%Compute imput image histogram and CDF.
hgramIn  = (imhist(im,nLevelsIn))';
cumIn    = cumsum(hgramIn);

T = createTransformationToIntensityImage(im,hgramSpec,nLevelsSpec,nLevelsIn,hgramIn,cumIn);

imout = applyTransformation(im,T);

if classChanged
    imout = im2int16(imout);
end

if nargout == 0
    if ismatrix(imout)
        imshow(imout);
        return;
    else
        out = imout;
        return;
    end
else
    out = imout;
end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function T = createTransformationToIntensityImage(a,hgramSpec,nSpec,nIn,hgramIn,cumIn)
%Compute the gray-level transformation needed to match histogram of input
%image hgramIn with specified histogram hgramSpec.

num_a   = numel(a);
cumSpec = cumsum(hgramSpec);
tol_val = num_a*sqrt(eps);

%hgramIn(1)=0,hgramIn(end)=0;
hgramIn = subsasgn(hgramIn,substruct('()',{[1 nIn]}),0);
if nSpec~=nIn
    % Rely on arrayfun to do a repmat-like expansion.
    err = arrayfun(@computeTransformation,cumSpec,cumIn,hgramIn);
else
    % Do the repmat ourselves when m==n
    err = arrayfun(@computeTransformation,repmat(cumSpec,1,nSpec),cumIn,hgramIn);
end

[~,T] = min(err);
T = (T-1)/(nSpec-1);

%Nested function to compute Transformation matrix.
function e = computeTransformation(cd,c,t)
e = cd-c + t/2;
if e < -tol_val
    e = num_a;
end
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = applyTransformation(im,T)
%Apply gray-level transformation defined in T to im.

classname = classUnderlying(im);
nLevels   = 255;
    
switch classname
    case 'uint8'
        scale = nLevels / 255;
        if nLevels == 255
            out = arrayfun(@grayxformUint8,im);
        else
            out = arrayfun(@grayxformUint8Scale,im);
        end
        
    case 'uint16'
        scale = nLevels / 65535;
        if nLevels == 65535
            out = arrayfun(@grayxformUint16,im);
        else
            out = arrayfun(@grayxformUint16Scale,im);
        end
    case 'single'
        out = arrayfun(@grayxformSingleScale,im);
        
    case 'double'
        out = arrayfun(@grayxformDoubleScale,im);
        
    otherwise
       error(message('images:grayxformmex:unsupportedInputClass'));
end

% Nested functions for pixel-wise computation.
function pix_out = grayxformUint8(pix_in)
    %GRAYXFORMUINT8 pixel-wise mapping for uint8 images with standard
    %mapping.
    pix_out = uint8(255.0*T(uint32(pix_in)+1));
end

function pix_out = grayxformUint16(pix_in)
    %GRAYXFORMUINT16 pixel-wise mapping for uint16 images with standard
    %mapping.
    pix_out = uint16(65535.0*T(uint32(pix_in)+1));
end

function pix_out = grayxformUint8Scale(pix_in)
    %GRAYXFORMUINT8SCALE general pixel-wise mapping for uint8 images.
    index = ceil(scale*double(pix_in) + 0.5);
    pix_out = uint8( 255.0*T(index) );
end

function pix_out = grayxformUint16Scale(pix_in)
    %GRAYXFORMUINT8SCALE general pixel-wise mapping for uint16 images.
    index = ceil(scale*double(pix_in) + 0.5);
    pix_out = uint16( 65535.0*T(index) );
end

function pix_out = grayxformDoubleScale(pix_in)
    %GRAYXFORMDOUBLESCALE general pixel-wise mapping for double images.             
    if pix_in>=0 && pix_in<=1
        index = floor(pix_in*nLevels+.5)+1;
        pix_out = T(index);
    elseif pix_in >1
        pix_out = T(nLevels+1);
    else
        pix_out = T(1);
    end
end

function pix_out = grayxformSingleScale(pix_in)
    %GRAYXFORMSINGLESCALE general pixel-wise mapping for single images.
    if pix_in>=0 && pix_in<=1
        index = floor(pix_in*nLevels+.5)+1;
        pix_out = single(T(index));
    elseif pix_in >1
        pix_out = single(T(nLevels+1));
    else
        pix_out = single(T(1));
    end
end
end
