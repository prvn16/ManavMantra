function model = fitniqe(varargin)
%FITNIQE Fit a custom model for calculating Naturalness Image Quality
%   Evaluator (NIQE) no-reference image quality score
%
%   MODEL = FITNIQE(IMDS) computes a NIQE model from custom image dataset
%   provided as an ImageDatastore object IMDS.
%
%   MODEL = FITNIQE( ___, Name, Value, ___) computes a NIQE model from
%   custom image dataset provided as an image datastore IMDS. Additional
%   parameters controlling the model calculation can be provided as name
%   value pairs.
%
%   Parameters are:
%
%   'BlockSize'             -   Specifies the blocksize used to partition
%                               the image into non-overlapping blocks for
%                               which the natural scene statistics(NSS)
%                               used to define the model are calculated. It
%                               is a two element vector of even integers specifying the
%                               blocksize in the format [row, column]. 
%                               The default is [96, 96].
%   
%   'SharpnessThreshold'    -   This is a sharpness threshold s in the
%                               range [0,1] which controls the image blocks
%                               which are used to compute the model. All
%                               blocks which have sharpness more than
%                               s*max(sharpness among all blocks) are used
%                               to compute the model. 
%                               The default is 0.
%
%   Class Support
%   -------------
%   The image datastore IMDS must contain images which are real,
%   non-sparse, M-by-N or M-by-N-by-3 matrices of one of the following
%   classes: uint8, uint16, int16, single or double. The MODEL is a
%   niqeModel object which can be used to calculate the NIQE
%   score of an image using the NIQE function.
%
%   Notes
%   -----
%   1.  The custom dataset provided as the image datastore
%       should ideally consist of images which are perceptually pristine to
%       human subjects with respect to the target application. The
%       definition of pristine would change based on the target
%       application. A set of images which can be termed pristine from a
%       microscopy dataset might have potentially a different set of
%       quality criteria compared to a dataset of natural scenes. It is
%       advisable to have a custom model for datasets having drastically
%       varied image content and potentially different set of quality
%       criteria.
%
%   References:
%   -----------
%   [1] A. Mittal, R. Soundararajan and A. C. Bovik, “ Making a Completely
%       Blind Image Quality Analyzer ”, IEEE Signal processing Letters, pp.
%       209-212, vol. 22, no. 3, March 2013.
%
%   Example
%   -------
%   This example shows how to compute the NIQE model from a set of custom
%   images.
%
%   setDir = fullfile(toolboxdir('images'),'imdata');
%   imds = imageDatastore(setDir, 'FileExtensions',{'.jpg'});
%
%   model = fitniqe(imds);
%
%   I = imread('lighthouse.png');
%   Inoise = imnoise(I,'salt & pepper', 0.02);
%   Iblur = imgaussfilt(I,2);
%
%   niqeI = niqe(I, model);
%   niqeInoise = niqe(Inoise, model);
%   niqeIblur = niqe(Iblur, model);
%
%   fprintf('NIQE score for original image is  %0.4f \n',niqeI);
%   fprintf('NIQE score for noisy image is  %0.4f \n',niqeInoise);
%   fprintf('NIQE score for blurry image is  %0.4f \n',niqeIblur);
%
%   See also NIQE, niqeModel, FITBRISQUE, BRISQUE.

%   Copyright 2016 The MathWorks, Inc.


narginchk(1,5);


options = parseInputs(varargin{:});

model = niqeModel.computeNIQEModel(varargin{1}, ... 
    options.BlockSize, options.SharpnessThreshold);
end

function options = parseInputs(varargin)

parser = inputParser();
parser.addRequired('IMDS',@validateImagedatastore);
parser.addParameter('BlockSize',[96 96],@validateBlockSize);
parser.addParameter('SharpnessThreshold',0,@validateSharpness);

parser.parse(varargin{:});
options = parser.Results;
end

function B = validateImagedatastore(ds)

validateattributes(ds, {'matlab.io.datastore.ImageDatastore'}, ...
                    {'nonempty','vector'}, mfilename, 'IMDS');

validateattributes(ds.Files, {'cell'}, ...
                    {'nonempty'}, mfilename, 'IMDS');
                
B = true;

end

function B = validateBlockSize(BlockSize)

validateattributes(BlockSize,images.internal.iptnumerictypes,{'nonempty','real','size',[1 2], ...
    'positive','integer','finite','nonsparse','nonnan','nonzero','even'},...
    mfilename,'BlockSize');

B = true;

end

function B = validateSharpness(SharpnessThreshold)

validateattributes(SharpnessThreshold,{'single','double'},{'nonempty','real', ... 
    'scalar','>=',0,'<=',1,'finite','nonsparse','nonnan'},...
    mfilename,'SharpnessThreshold');

B = true;

end
