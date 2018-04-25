function T = adaptthresh(I,varargin)
%ADAPTTHRESH Adaptive image threshold using local first-order statistics.
%   T = ADAPTTHRESH(I) computes a locally adaptive threshold that can be
%   used to convert an intensity image to a binary image with IMBINARIZE.
%   The result, T, is a matrix of the same size as I with normalized
%   intensity values in the range [0, 1]. ADAPTTHRESH chooses the threshold
%   based on first-order statistics in the neighborhood of each pixel.
%
%   T = ADAPTTHRESH(I,SENSITIVITY) computes a locally adaptive threshold
%   with sensitivity factor specified by SENSITIVITY. SENSITIVITY is a
%   scalar in the range [0, 1] that indicates sensitivity towards
%   thresholding more pixels as foreground. A high sensitivity value leads
%   to thresholding more pixels as foreground, at the risk of including
%   some background pixels. When no sensitivity is specified, a default of
%   0.5 is used.
%
%   T = ADAPTTHRESH(...,PARAM1,VAL1,PARAM2,VAL2,...) computes a locally
%   adaptive threshold using name-value pairs to control aspects of the
%   thresholding.
%
%   T = ADAPTTHRESH(V,___) computes a locally adaptive threshold for a 3D 
%   input volume V. 
%
%   Parameters include:
%   
%   'NeighborhoodSize'      Specifies size of the neighborhood used to
%                           compute local statistic around each pixel.
%                           Value can be a scalar or two-element vector of
%                           positive odd integers for a 2D image.
%                           Value can be a scalar or three-element vector 
%                           of possible odd integers for a 3D volume. 
%                           Default value is 2*floor(size(I)/16)+1.
%
%   'ForegroundPolarity'    Specifies the polarity of the foreground with
%                           respect to the background. Available options
%                           are:
%
%               'bright'    : The foreground is brighter than the
%                             background. (Default)
%               'dark'      : The foreground is darker than the background.
%
%   'Statistic'             Specifies the statistic used to compute local
%                           threshold at each pixel. Available options are: 
%
%               'mean'      : The local mean in the neighborhood. (Default)
%
%               'median'    : The local median in the neighborhood.
%
%               'gaussian'  : The gaussian weighted mean in the
%                             neighborhood.
%
%   Class Support 
%   ------------- 
%   The input image I must be a real, non-sparse 2D or 3D matrix of one of the
%   following classes: uint8, uint16, uint32, int8, int16, int32, single or
%   double. The output threshold image T is a double matrix of the same
%   size as I.
%
%   Notes
%   -----
%   1. ADAPTTHRESH computes a locally adaptive threshold for each pixel
%      using the local mean intensity around the neighborhood of the pixel.
%      This technique is also called Bradley's method. See References
%      below.
%
%   2. When the 'Statistic' is set to 'median', computation can be slow.
%      Consider using a smaller neighborhood size to obtain faster results.
%
%   3. If the image contains Infs or NaNs, the behavior of ADAPTTHRESH is
%      undefined. Propagation of Infs or NaNs may not be localized to the
%      neighborhood around Inf or NaN pixels.
%
%
%   References
%   ----------
%   1. Bradley, D., G. Roth, "Adaptive Thresholding Using the Integral
%      Image," Journal of Graphics Tools. Vol. 12, No. 2, 2007, pp.13-21.
%
%
%   Example 1
%   ---------
%   This example segments bright rice grains from a dark background.
%
%   I = imread('rice.png');
%   T = adaptthresh(I, 0.4);
%   BW = imbinarize(I,T);
%
%   figure, imshowpair(I, BW, 'montage')
%
%   Example 2
%   ---------
%   This example segments dark text from a bright background.
%
%   I = imread('printedtext.png');
% 
%   % Compute adaptive threshold and display the local threshold image.
%   % This represents an estimate of average background illumination.
%   T = adaptthresh(I,0.4,'ForegroundPolarity','dark');
%   figure, imshow(T)
% 
%   % Binarize image using locally adaptive threshold
%   BW = imbinarize(I,T);
%   figure, imshow(BW)
%
%   Example 3
%   ---------
%   This example adaptively thresholds an MRI volume to enhance finer
%   details that global thresholding might neglect.
%
%   load mristack;
%   V = mristack;
%   figure
%   montage(V)
% 
%   % Compute adaptive threshold and display a montage of local threshold volume.
%   J = adaptthresh(V,'Statistic','gaussian');
%   figure
%   montage(J)
% 
%   % Binarize volume using locally adaptive threshold
%   BW = imbinarize(V,J);
%   figure
%   montage(BW)
%
%   See also IMBINARIZE, OTSUTHRESH, GRAYTHRESH.

% Copyright 2015-2017 The MathWorks, Inc.

args = matlab.images.internal.stringToChar(varargin);
[I,options] = parseInputs(I, args{:});
nhoodSize   = options.NeighborhoodSize;
statistic   = options.Statistic;
isFGBright  = strcmp(options.ForegroundPolarity,'bright');
sensitivity = options.Sensitivity;

if isempty(I)
    T = zeros(size(I));
    return;
end

scaleFactor = sensitivityToScaleFactor(sensitivity,isFGBright);

% Convert image to double-precision. This scales integer data to [0,1].
I = cvt2double(I);

switch statistic
    case 'mean'
        T = localMeanThresh(I,nhoodSize,scaleFactor);
    case 'median'
        T = localMedianThresh(I,nhoodSize,scaleFactor);
    case 'gaussian'
        T = localGaussThresh(I,nhoodSize,scaleFactor);
    otherwise
        assert(false,'Unknown statistic string.')
end

% Restrict T to [0,1]. Saturate output values to lie in [0,1] data range
% for double-precision images.
T = max(min(T,1),0);
end

function scaleFactor = sensitivityToScaleFactor(sensitivity, isFGBright)
% Convert sensitivity on a 0-1 scale to scaleFactor. For images with a
% bright foreground, map the sensitivity in [0, 1] to scale factor in [1.6,
% 0.6]. For images with a dark foreground, map the sensitivity in [0, 1] to
% scale factor in [0.4, 1.4]. So, a sensitivity of 0.5 corresponds to a
% scale factor of 1.1 for polarity 'bright' and 0.9 for polarity 'dark'.
% This is done to assure that the default choice (0.5) for sensitivity maps
% to a 'good' scale factor for either polarity.

if isFGBright
    scaleFactor = 0.6 + (1-sensitivity);
else
    scaleFactor = 0.4 + sensitivity;
end
end

function T = localMeanThresh(I, nhoodSize, scaleFactor)

outSize = size(I);

% Pad the image
padSize = (nhoodSize-1)/2;
I = padarray(I,padSize,'replicate','both');

% Fold multiplication by scale factor into the normalization factor.
normFactor = scaleFactor/prod(nhoodSize);

if ismatrix(I)
    % Compute the integral image
    intI = integralimagemex(I);
       
    T = images.internal.boxfiltermex(intI, nhoodSize, normFactor, 'double', outSize);
else
    intI = integralImage3(I);
       
    T = images.internal.boxfilter3mex(intI, nhoodSize, normFactor, 'double', outSize);
end
    
end

function T = localMedianThresh(I, nhoodSize, scaleFactor)
if ismatrix(I)
    T = scaleFactor*medfilt2(I,nhoodSize,'symmetric');
else
    T = scaleFactor*medfilt3(I,nhoodSize,'symmetric');
end

end

function T = localGaussThresh(I, nhoodSize, scaleFactor)
if ismatrix(I)
    T = scaleFactor*imgaussfilt(I,nhoodSize);
else
    T = scaleFactor*imgaussfilt3(I,nhoodSize);
end

end

function I = cvt2double(I)
% im2double is not supported for all classes. This function does the
% conversion for other classes too.

switch class(I)
    case {'uint8','uint16','int16','single','double'}
        I = im2double(I);
    case 'int8'
        I = (double(I) + 128) / 255;
    case 'uint32'
        I = double(I) / 4294967295;
    case 'int32'
        I = (double(I) + 2147483648) / 4294967295;
    otherwise
        assert('Incorrect class');
end
end

%--------------------------------------------------------------------------
% Input Parsing
%--------------------------------------------------------------------------
function [I,options] = parseInputs(varargin)

narginchk(1,8);
I = varargin{1};
validateImage(I);

% Default options
options = struct(...
            'NeighborhoodSize',     2*floor(size(I)/16) + 1,...
            'Statistic',            'mean',...
            'ForegroundPolarity',   'bright',...
            'Sensitivity',          0.5);

beginningOfNameVal = find(cellfun(@isstr,varargin),1);

if isempty(beginningOfNameVal) && length(varargin)==1
    %adaptthresh(I)
    return;
elseif beginningOfNameVal==2
    %adaptthresh(I,'Name',Value)
elseif (isempty(beginningOfNameVal) && length(varargin)==2) || (~isempty(beginningOfNameVal) && beginningOfNameVal==3)
    %adaptthresh(I,sensitivity)
    %adaptthresh(I,sensitivity,'Name',Value,...)
    options.Sensitivity = validateSensitivity(varargin{2});
else
    error(message('images:validate:tooManyOptionalArgs'));
end

numPVArgs = length(varargin) - beginningOfNameVal + 1;
if mod(numPVArgs,2)~=0
    error(message('images:validate:invalidNameValue'));
end

ParamNames = {'Statistic', 'ForegroundPolarity', 'NeighborhoodSize'};
ValidateFcn = {@validateStatistic, @validateForegroundPolarity, @validateFilterSize};


for p = beginningOfNameVal : 2 : length(varargin)-1
    
    Name = varargin{p};
    Value = varargin{p+1};
    
    % Index of ParamName 
    idx = find(strncmpi(Name, ParamNames, numel(Name)));
    
    if ~any(idx)
        error(message('images:validate:unknownParamName', Name));
    elseif numel(idx)>1
        error(message('images:validate:ambiguousParamName', Name));
    end
    
    validate = ValidateFcn{idx};
    if idx == 3 % Checking on NeighborhoodSize
        if ismatrix(I)  % 2D image filter
            options.(ParamNames{idx}) = validate(Value,0);
        else            % 3D image filter
            options.(ParamNames{idx}) = validate(Value,1);
        end
    else
        options.(ParamNames{idx}) = validate(Value);
    end
    
end

end

function validateImage(I)

supportedClasses = {'uint8','uint16','uint32','int8','int16','int32','single','double'};
supportedAttribs = {'real','nonsparse','3d'};
validateattributes(I,supportedClasses,supportedAttribs,mfilename,'I');

end

function statistic = validateStatistic(statistic)

statistic = validatestring(statistic,{'mean','median','gaussian'},mfilename,'Statistic');

end

function polarity = validateForegroundPolarity(polarity)

polarity = validatestring(polarity,{'bright','dark'},mfilename,'ForegroundPolarity');

end

function filtSize = validateFilterSize(filtSize,flagIs3D)

if flagIs3D
    filtSize = images.internal.validateThreeDFilterSize(filtSize);
else
    filtSize = images.internal.validateTwoDFilterSize(filtSize);
end

end

function sensitivity = validateSensitivity(sensitivity)

validateattributes(sensitivity,{'numeric'},{'real','scalar','nonnegative','<=',1},mfilename,'Sensitivity');
sensitivity = double(sensitivity);

end
