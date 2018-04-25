function score = brisque(varargin)
%BRISQUE Blind/Referenceless Image Spatial Quality Evaluator (BRISQUE)
%   no-reference image quality score
%
%   SCORE = BRISQUE(A) calculates the no-reference image quality score BRISQUE for
%   image A with respect to a default model computed from images of natural
%   scenes. Image A can be both RGB and grayscale.
%
%   SCORE = BRISQUE(A, MODEL) calculates the BRISQUE score with respect to a
%   custom BRISQUE MODEL. The custom MODEL can be computed using the
%   FITBRISQUE function.
%
%   Notes
%   -----
%   1.  BRISQUE score is predicted by a support vector regression (SVR)
%       model trained on a set of images with their corresponding
%       differential mean opinion score (DMOS) as the target. The set of
%       images contain original images along with their distorted versions
%       corrupted by known distortion effects such as compression
%       artifacts, blurring, noise etc. The image to be scored should have
%       at least one of the distortions for which the model was trained.
%   
%   2.  The BRISQUE score is a scalar value usually in the range [0, 100]. Lower
%       values of BRISQUE score reflects better perceptual quality of A with
%       respect to the MODEL.
%
%   Class Support
%   -------------
%   A must be a real, non-sparse, M-by-N or M-by-N-by-3 matrix of one of
%   the following classes: uint8, uint16, int16, single or double. MODEL
%   must be a brisqueModel object. SCORE is a scalar of class double.
%
%   References:
%   -----------
%   [1] A. Mittal, A. K. Moorthy, and A. C. Bovik.
%       "No-reference Image Quality Assessment in the Spatial Domain." IEEE
%       Transactions on Image Processing 21.12 (2012): 4695-4708.
%
%   [2] A. Mittal, A. K. Moorthy and A. C. Bovik, "Referenceless Image
%       Spatial Quality Evaluation Engine", 45th Asilomar Conference on
%       Signals, Systems and Computers, November 2011
%
%   Example
%   -------
%   % This example shows how to compute the BRISQUE score for an image and its
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
%   brisqueI = brisque(I);
%   brisqueInoise = brisque(Inoise);
%   brisqueIblur = brisque(Iblur);
%   
%   fprintf('BRISQUE score for original image is  %0.4f \n',brisqueI);
%   fprintf('BRISQUE score for noisy image is  %0.4f \n',brisqueInoise);
%   fprintf('BRISQUE score for blurry image is  %0.4f \n',brisqueIblur);
%
%   See also FITBRISQUE, brisqueModel, IMMSE, SSIM, PSNR, NIQE, FITNIQE.

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
    model = brisqueModel();
else
    validateInputModel(varargin{2});
    model = varargin{2};
end
score = model.calculateBRISQUEscore(im);
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
    if(~isa(model,'brisqueModel'))
        error(message('images:brisque:expectBRISQUEModel'));
    end
end
