function score = niqe(varargin)
%NIQE Naturalness image quality evaluator (NIQE) no-reference image quality score
%
%   SCORE = NIQE(A) calculates the no-reference image quality score NIQE for
%   image A with respect to a default model computed from images of natural
%   scenes. Image A can be both RGB and grayscale.
%
%   SCORE = NIQE(A, MODEL) calculates the NIQE score with respect to a
%   custom NIQE MODEL. The custom MODEL can be computed using the FITNIQE
%   function.
%
%   Class Support
%   -------------
%   A must be a real, non-sparse, M-by-N or M-by-N-by-3 matrix of one of
%   the following classes: uint8, uint16, int16, single or double. MODEL
%   must be a niqeModel object. SCORE is a scalar of class double.
%
%   Notes
%   -----
%   1.  NIQE measures the distance between the natural scene statistics
%       (NSS) based feature set calculated from an image A to those
%       obtained from a corpus of images used to compute the model
%       parameters. The NSS based features are modeled as multi-dimensional
%       Gaussian distributions.
%
%   2.  The NIQE score is a scalar value in the range [0, Inf]. Lower
%       values of NIQE score reflects better perceptual quality of A with
%       respect to the MODEL.
%
%   References:
%   -----------
%   [1] A. Mittal, R. Soundararajan and A. C. Bovik, "Making a Completely
%       Blind Image Quality Analyzer" , IEEE Signal processing Letters, pp.
%       209-212, vol. 22, no. 3, March 2013.
%
%   Example
%   -------
%   % This example shows how to compute the NIQE score for an image and its
%   % distorted versions using the default model.
%
%   I = imread('lighthouse.png');
%   Inoise = imnoise(I,'salt & pepper', 0.02);
%   Iblur = imgaussfilt(I,2);
%
%   figure
%   imshow(I)
%   title('Original Image');
%
%   figure
%   imshow(Inoise)
%   title('Noisy Image');
%
%   figure
%   imshow(Iblur)
%   title('Blurry Image');
%
%   niqeI = niqe(I);
%   niqeInoise = niqe(Inoise);
%   niqeIblur = niqe(Iblur);
%
%   fprintf('NIQE score for original image is  %0.4f \n',niqeI);
%   fprintf('NIQE score for noisy image is  %0.4f \n',niqeInoise);
%   fprintf('NIQE score for blurry image is  %0.4f \n',niqeIblur);
%
%   See also FITNIQE, niqeModel, IMMSE, SSIM, PSNR, BRISQUE, FITBRISQUE.

%   Copyright 2016-2017 The MathWorks, Inc.


narginchk(1,2);
validateInputImage(varargin{1});
im = varargin{1};

if(size(im,3)==3)
    if isa(im,'int16')
        % Since rgb2gray does not support int16
        im = im2double(im);
    end
    im = rgb2gray(im);
end
im = round(255*im2double(im));

if nargin == 1
    model = niqeModel();
else
    validateInputModel(varargin{2});
    model = varargin{2};
end
score = model.calculateNIQEscore(im);
end

function validateInputImage(A)
    supportedClasses = {'uint8','uint16','single','double','int16'};
    attributes = {'nonempty','nonsparse','real','nonnan','finite'};

    validateattributes(A,supportedClasses,attributes,...
        mfilename,'A',1);

    validColorImage = (ndims(A) == 3) && (size(A,3) == 3);
    if ~(ismatrix(A) || validColorImage)
        error(message('images:validate:invalidImageFormat','A'));
    end
end

function validateInputModel(model)
    if(~isa(model,'niqeModel'))
        error(message('images:niqe:expectNIQEModel'));
    end    
end
