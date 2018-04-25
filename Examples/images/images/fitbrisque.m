function model = fitbrisque(varargin)
%FITBRISQUE Fit a custom model for calculating Blind/referenceless image
%   spatial quality evaluator (BRISQUE) no-reference image quality score
%
%   MODEL = FITBRISQUE(IMDS, OpinionScore) computes the BRISQUE model from
%   an image dataset provided as an ImageDatastore object IMDS with
%   corresponding human perceptual differential mean opinion score (DMOS).
%
%   Notes
%   -----
%   1.  The MODEL is a brisqueModel object which contains a support vector 
%       regressor (SVR) with a Gaussian kernel trained to predict the
%       BRISQUE quality score. Use of FITBRISQUE requires that you have the
%       Statistics and Machine Learning Toolbox.
%
%   2.  The custom dataset provided as the image datastore IMDS should
%       ideally consist of images which have a known set of distortions such as
%       compression artifacts, blurring, noise etc. The corresponding human
%       perceptual differential mean opinion score varies in the range [0,
%       100]. Hence the predicted score for an unknown image is usually in
%       the same range.
%
%   Class Support
%   -------------
%   The image datastore IMDS must contain images which are real,
%   non-sparse, M-by-N or M-by-N-by-3 matrices of one of the following
%   classes: uint8, uint16, int16, single or double. OpinionScore is a
%   numeric vector of the following classes: uint8, uint16, uint32, int8,
%   int16, int32, single and double. The MODEL is a
%   brisqueModel object which can be used to calculate the BRISQUE score of 
%   an image using the BRISQUE function.
%
%   References:
%   -----------
%   [1] A. Mittal, A. K. Moorthy, and A. C. Bovik.
%       "No-reference Image Quality Assessment in the Spatial Domain." IEEE
%       Transactions on Image Processing 21.12 (2012): 4695-4708.
%
%   [2] A. Mittal, A. K. Moorthy and A. C. Bovik, “Referenceless Image
%       Spatial Quality Evaluation Engine", 45th Asilomar Conference on
%       Signals, Systems and Computers, November 2011
%
%   Example
%   -------
%   This example shows how to compute the BRISQUE model from a set of custom
%   images and their corresponding DMOS scores.
%
%   setDir = fullfile(toolboxdir('images'), 'imdata');
%   imds = imageDatastore(setDir, 'FileExtensions', {'.jpg'});
%
%   % The following DMOS scores are for illustrative purposes only and are
%   % not real DMOS scores obtained via experimentation.
%   OpinionScores= 100*rand(1,size(imds.Files,1));
% 
%   model = fitbrisque(imds, OpinionScores');
% 
%   I = imread('lighthouse.png');
%   Inoise = imnoise(I, 'salt & pepper', 0.02);
%   Iblur = imgaussfilt(I, 2);
% 
%   brisqueI = brisque(I, model);
%   brisqueInoise = brisque(Inoise, model);
%   brisqueIblur = brisque(Iblur, model);
% 
%   fprintf('BRISQUE score for original image is  %0.4f \n', brisqueI );
%   fprintf('BRISQUE score for noisy image is  %0.4f \n', brisqueInoise );
%   fprintf('BRISQUE score for blurry image is  %0.4f \n', brisqueIblur );%
%
%   See also BRISQUE, brisqueModel, NIQE, FITNIQE.

%   Copyright 2016 The MathWorks, Inc.

narginchk(2,2);

images.internal.requiresStatisticsToolbox(mfilename);

parser = inputParser();
parser.addRequired('IMDS',@validateImagedatastore);
parser.addRequired('SCORES',@validateScores);
parser.parse(varargin{:});
options = parser.Results;
              
if(numel(options.SCORES)~=size(options.IMDS.Files,1))
    error(message('images:brisque:ScoresNumfilesUnequal'));
end

model = brisqueModel.computeBRISQUEModel(options.IMDS, options.SCORES);
end

function B = validateImagedatastore(ds)

validateattributes(ds, {'matlab.io.datastore.ImageDatastore'}, ...
                    {'nonempty','vector'}, mfilename, 'IMDS');

validateattributes(ds.Files, {'cell'}, ...
                    {'nonempty'}, mfilename, 'IMDS');
                
B = true;

end

function B = validateScores(scores)

validateattributes(scores,images.internal.iptnumerictypes,{'nonempty','real','vector', ...
    'finite','nonsparse','nonnan','>=',0.0,'<=',100.0}, mfilename,'scores');
                
B = true;

end

