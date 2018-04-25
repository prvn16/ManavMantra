function [L,N] = superpixels(varargin)
%SUPERPIXELS 2-D superpixel over-segmentation of images
%
%   [L,NumLabels] = superpixels(A,N) computes superpixels of image A using
%   N as the requested number of superpixels. A must either be a 2-D
%   grayscale image or a 2-D RGB image. The first output argument, L, is a
%   label matrix of type double. The second output argument, NumLabels, is
%   the actual number of superpixels that were computed.
%
%   [L,NumLabels] = superpixels(___,Name,Value,...) computes superpixels of A
%   with Name-Value pairs used to control aspects of the segmentation.
%
%   Parameters include:
%
%   'Compactness'         - Numeric scalar specifying the compactness
%                           parameter of the SLIC algorithm. Compactness
%                           controls the shape of superpixels. A higher
%                           value for compactness makes superpixels more
%                           regularly shaped/square. A lower value makes
%                           superpixels adhere to boundaries better, making
%                           them irregularly shaped. The allowed range of
%                           Compactness is (0 Inf). Typical values for
%                           compactness are in the range [1, 20]. If this
%                           parameter is not specified, the default value
%                           is chosen as 1.0 if METHOD is 'slic0' and 10.0
%                           if METHOD is 'slic'.
%
%   'IsInputLab'           - Logical scalar specifying whether the input
%                            image data is in the L*a*b* colorspace.
%
%                           Default: false
%
%   'Method'              - String specifying the algorithm used to compute
%                           superpixels. Supported options are 'slic' and
%                           'slic0'. When 'Method' is 'slic0', the SLIC0
%                           algorithm is used to adaptively refine
%                           'Compactness' after the first iteration. When
%                           'Method' is 'slic', 'compactness' is constant
%                           during clustering.
%
%                           Default: 'slic0'
%                                                      
%   'NumIterations'       - Numeric scalar specifying the number of
%                           iterations used in the clustering phase of the
%                           algorithm. For most problems it is not
%                           necessary to adjust this parameter.
%
%                           Default: 10
%
%
%   Class Support
%   -------------
%   The input image A must be a real, non-sparse matrix of the following
%   classes: uint8, uint16, int16 (grayscale only), single, or double. When
%   'isInputLab' is true, the input image A must be single or double.
%
%   Notes
%   -----
%   1. When using the 'slic0' method, it is generally not necessary to adjust
%      'Compactness' parameter. The intention of 'slic0' is to adaptively
%      refine 'Compactness' automatically and eliminate the need for users
%      to determine a good value of 'Compactness' for themselves.
%
%   Example 1
%   ---------
%   Compute superpixels of input RGB image. Form an output image where each
%   pixel is set to the mean color of its corresponding superpixel region.
%   
%   A = imread('kobi.png');
%   [L,N] = superpixels(A,500);
%   figure
%   BW = boundarymask(L);
%   imshow(imoverlay(A,BW,'cyan'))
%
%   % Set color of each pixel in output image to the mean RGB color of the
%   % superpixel region.
%   outputImage = zeros(size(A),'like',A);
%   idx = label2idx(L);
%   numRows = size(A,1);
%   numCols = size(A,2);
%   for labelVal = 1:N
%       redIdx = idx{labelVal};
%       greenIdx = idx{labelVal}+numRows*numCols;
%       blueIdx = idx{labelVal}+2*numRows*numCols;
%       outputImage(redIdx) = mean(A(redIdx));
%       outputImage(greenIdx) = mean(A(greenIdx));
%       outputImage(blueIdx) = mean(A(blueIdx));
%   end
%
%   figure
%   imshow(outputImage)
%   
%   See also superpixels3, boundarymask, imoverlay, label2idx, label2rgb.

%   Copyright 2015-2016, The MathWorks, Inc.

%   References: 
%   ----------- 
%   [1] Radhakrishna Achanta, Appu Shaji, Kevin Smith, Aurelien Lucchi,
%   Pascal Fua, and Sabine Susstrunk, SLIC Superpixels Compared to
%   State-of-the-art Superpixel Methods, IEEE Transactions on Pattern
%   Analysis and Machine Intelligence, vol. 34, num. 11, p. 2274 - 2282,
%   May 2012.
%
%   [2] Radhakrishna Achanta, Appu Shaji, Kevin Smith, Aurelien Lucchi,
%   Pascal Fua, and Sabine Susstrunk, SLIC Superpixels, EPFL Technical
%   Report no. 149300, June 2010.

narginchk(2,inf);

options = parseInputs(varargin{:});

[L,N] = slicmex(options.A,...
    options.N,...
    options.Compactness,...
    options.NumIterations,...
    options.RefineCompactness);

end

function options = parseInputs(varargin)

validateInputImage(varargin{1});

validateattributes(varargin{2},{'numeric'},{'nonempty','scalar','positive','finite','integer','nonsparse'},...
    mfilename,'N',2);

parser = inputParser();
parser.addParameter('Compactness',[],@validateCompactness);
parser.addParameter('IsInputLab',false,@validateIsLab);
parser.addParameter('Method','slic0',@validateMethod);
parser.addParameter('NumIterations',10,@validateNumIters);

parser.parse(varargin{3:end});
options = parser.Results;
options.A = varargin{1};
options.N = varargin{2};

if (options.N > numel(options.A))
   error(message('images:superpixels:tooManySuperpixelsRequested')); 
end

% If Compactness was not specified by user, set Compactness based on
% the chosen 'Method' Name/Value.
if isempty(options.Compactness)
    if strcmp(options.Method,'slic0')
        options.Compactness = 1.0;
    else
        options.Compactness = 10.0;
    end
end

options.A = postProcessInputImage(options.A,options.IsInputLab);
options.IsInputLab = logical(options.IsInputLab);
options.RefineCompactness = strcmpi(options.Method,'slic0');
options.N = double(options.N);
options.Compactness = double(options.Compactness);
options.NumIterations = double(options.NumIterations);

end

function Aout = postProcessInputImage(A,isInputLab)

grayscaleInput = false;
if ismatrix(A) && ~isa(A,'int16')
   grayscaleInput = true; 
   A = repmat(A,[1 1 3]);
end

if isInputLab
   if ~isfloat(A)
      error(message('images:superpixels:expectSingleOrDoubleWhenIsInputLab','''isInputLab''')); 
   end
   Aout = A;
elseif isa(A,'int16')
   % Scale to range of luminance channel 
   Aout = im2double(A)*200;
else
   Aout = rgb2lab(A);
end

if grayscaleInput
    Aout = Aout(:,:,1);
end

end

function validateInputImage(A)

supportedClasses = {'uint8','uint16','int16','single','double'};
attributes = {'nonempty','nonsparse','real','nonnan','finite'};
                
validateattributes(A,supportedClasses,attributes,...
                    mfilename,'A',1);
                
validColorImage = (ndims(A) == 3) && (size(A,3) == 3);                
if ~(ismatrix(A) || validColorImage)
    error(message('images:superpixels:expectGrayscaleOrColor'));
end

if isa(A,'int16') && validColorImage
    error(message('images:superpixels:expectGrayscaleInt16'));
end

end


function TF = validateCompactness(C)

validateattributes(C,{'numeric'},{'nonempty','real','scalar','positive','finite','nonsparse'},...
    mfilename,'Compactness',3);

TF = true;

end

function TF = validateNumIters(numIters)

validateattributes(numIters,{'numeric'},{'nonempty','real','scalar','positive','finite','nonsparse','integer'},...
    mfilename,'NumIterations');

TF = true;

end

function TF = validateIsLab(TFin)

validateattributes(TFin,{'logical','numeric'},{'real','scalar','finite','nonempty','nonsparse'},...
    mfilename,'IsInputLab');

TF = true;

end

function TF = validateMethod(method)

validatestring(method,{'slic','slic0'},mfilename,'Method');

TF = true;

end
