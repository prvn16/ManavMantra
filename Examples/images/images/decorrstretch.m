function S = decorrstretch(varargin)
%DECORRSTRETCH Apply decorrelation stretch to multichannel image.
%   S = DECORRSTRETCH(A) applies a decorrelation stretch to an
%   M-by-N-by-NBANDS image A and returns the result in S.  S has the
%   same size and class as A. The mean and variance in each band are
%   the same as in A.  A can be an RGB image (NBANDS = 3) or can
%   have any number of spectral bands.
%
%   S = DECORRSTRETCH(A,PARAM1,VAL1,PARAM2,VAL2,...) applies a
%   decorrelation stretch to A subject to optional control parameters.
%
%   Parameter        Value
%   ---------        -----
%   'Mode'           A string or char vector: either 'correlation' or
%                    'covariance'
%
%                    Controls whether the image is decorrelated using the
%                    eigen decomposition of the band-to-band correlation
%                    matrix or the eigen decomposition of the band-to-band
%                    covariance matrix.
%
%                    Default mode: Correlation
%
%   'TargetMean'     A real scalar or vector of length NBANDS
%
%                    Causes the band-means of the output image to match
%                    the value(s) specified.  Results will be affected
%                    if values need to be clamped to the standard range
%                    of the input/output image class.
%
%                    Default:  A 1-by-NBANDS vector containing sample mean
%                    of each band (preserving the band-wise means)
%
%   'TargetSigma'    A real, positive scalar or vector of length NBANDS
%
%                    Causes the standard deviations of the individual
%                    bands to match the values specified.  Results
%                    will be affected if clamping is needed.  Ignored
%                    for uniform (zero-variance) bands.
%
%                    Default:  A 1-by-NBANDS vector containing the standard
%                    deviation of each band (preserving the band-wise
%                    variances)
%
%   'Tol'            A one- or two-element real vector, TOL
%
%                    Designates a linear contrast stretch to be applied
%                    following the decorrelation stretch. Overrides
%                    use of 'TargetMean' or 'TargetSigma.'  TOL has the
%                    same meaning as in STRETCHLIM:
%
%                    TOL = [LOW_FRACT HIGH_FRACT] specifies the fraction
%                    of the image to saturate at low and high intensities. 
%
%                    For scalar TOL, LOW_FRACT = TOL, and HIGH_FRACT = 1 - TOL,
%                    saturating equal fractions at low and high intensities.
%
%                    Default:  The linear contrast stretch is omitted
%                    unless a value is provided for TOL.
%
%   'SampleSubs'     A cell array containing two arrays of pixel
%                    subscripts {ROWSUBS, COLSUBS}
%
%                    ROWSUBS and COLSUBS are vectors or matrices of
%                    matching size that contain row and column subscripts,
%                    respectively. They specify the subset of A used to
%                    compute the band-means, covariance, and correlation.
%                    Use this option to reduce the amount of computation,
%                    to keep invalid or non-representative pixels from
%                    affecting the transformation, or both.  For example,
%                    exclude areas of cloud cover from ROWSUBS and COLSUBS.
%
%                    Default:  Use all the pixels in computing the band
%                    statistics.
%
%   Notes
%   -----
%   The primary purpose of decorrelation stretch is visual enhancement.
%   Small adjustments to TOL can strongly affect the visual appearance
%   of the output.
%
%   The results of a straight decorrelation (without the contrast
%   stretch option) may include values that fall outside the numerical
%   range supported by the class uint8 or uint16 (negative values, or
%   values exceeding 2^8 - 1 or 2^16 - 1, respectively).  In these cases,
%   DECORRSTRETCH clamps its output to the supported range.
%
%   In the case of class double, output is clamped only when a value
%   for TOL is provided, specifying a linear contrast stretch followed
%   by clamping to the interval [0 1].
%
%   The optional parameters do not interact, except that a linear stretch
%   usually alters both the band-wise means and band-wise standard
%   deviations.  Thus while TARGETMEAN and TARGETSIGMA can be specified
%   along with TOL, their effects will be modified.
%
%   TARGETMEAN and TARGETSIGMA must be class double, but they should use
%   the same units as the input image.  For example, if I is class uint8,
%   then 127.5 and 50.0 would be reasonable values for TARGETMEAN and
%   TARGETSIGMA, respectively.
%
%   Class Support
%   -------------
%   The input image can be double, uint8, uint16, int16, or single.
%
%   Example
%   -------
%       [X, map] = imread('forest.tif');
%       S = decorrstretch(ind2rgb(X,map),'tol',0.01);
%       figure, imshow(X,map)
%       figure, imshow(S)
%
%   See also STRETCHLIM, IMADJUST.

%   Copyright 1993-2017 The MathWorks, Inc.


% Parse and validate input arguments.
args = matlab.images.internal.stringToChar(varargin);
[A, mode, targetMean, targetSigma, tol, rowsubs, colsubs] = ...
                                               parseInputs(args{:});

% Convert to double, if necessary.
inputClass = class(A);
if ~strcmp(inputClass,'double')
    A = im2double(A);
    targetMean  = im2double(feval(inputClass,targetMean));
    targetSigma = im2double(feval(inputClass,targetSigma));
end

% Apply decorrelation stretch.
S = decorr(A, strcmp(mode,'correlation'),...
           targetMean, targetSigma, rowsubs, colsubs);

% Apply optional contrast stretch.
if ~isempty(tol)
    low_high = stretchlim(S,tol);
    S = imadjust(S,low_high);
    S(S < 0) = 0;
    S(S > 1) = 1;
end

% Restore input class.
S = images.internal.changeClass(inputClass,S);

%--------------------------------------------------------------------------
function S = decorr(A, useCorr, targetMean, targetSigma, rowsubs, colsubs)
% Decorrelation stretch for a multiband image of class double.

[r c nbands] = size(A);        % Save the shape
npixels = r * c;                % Number of pixels
A = reshape(A,[npixels nbands]);     % Reshape to numPixels-by-numBands

if isempty(rowsubs)
    B = A;
else
    ind = sub2ind([r c], rowsubs, colsubs);
    B = A(ind,:);
end

meanB = mean(B,1);        % Mean pixel value in each spectral band
n = size(B,1);            % Equals npixels if rowsubs is empty
if n == 1
    cov = zeros(nbands);
else
    cov = (B' * B - (n * meanB') * meanB)/(n - 1);  % Sample covariance matrix
end

[T, offset]  = fitdecorrtrans(meanB, cov, useCorr, targetMean, targetSigma);

S = bsxfun(@plus, A*T, offset);
S = reshape(S, [r c nbands]);

%--------------------------------------------------------------------------
function out = imadjust(img,low_high)
% A short, specialized version of IMADJUST that works with
% an arbitrary number of image planes.

low  = low_high(1,:);
high = low_high(2,:);
out = zeros(size(img));

% Loop over image planes and perform transformation.
for p = 1:size(img,3)
    % Make sure img is in the range [low,high].
    img(:,:,p) =  max(low(p),min(high(p),img(:,:,p)));

    % Transform.
    out(:,:,p) = (img(:,:,p)-low(p))./(high(p)-low(p));
end

%--------------------------------------------------------------------------
function [A, mode, targetMean, targetSigma, tol, rowsubs, colsubs] = ...
    parseInputs(varargin)

% Number of arguments passed to DECORRSTRETCH
narginchk(1, 12);

% Defaults.
mode = 'correlation';
targetMean = [];
targetSigma = [];
tol = [];
rowsubs = [];
colsubs = [];

% Validate the image array.
A = varargin{1};

validateattributes(A, {'double','uint8','uint16','int16','single'},...
              {'nonempty','real','nonnan','finite'},...
              'decorrstretch', 'A', 1);
          
if ndims(A) > 3
    error(message('images:decorrstretch:expected2Dor3D'));
end

% Validate the property name-value pairs.
nbands = size(A,3);
validPropertyNames = ...
    {'Mode','TargetMean','TargetSigma','Tolerance','SampleSubscripts'};
for k = 2:2:nargin
    propName = validatestring(varargin{k}, validPropertyNames,...
                            mfilename, 'PARAM', k);
    switch propName
      case 'Mode'
        checkExistence(k, nargin, mfilename, 'mode string', propName);
        mode = validatestring(varargin{k+1}, {'correlation','covariance'},...
                            mfilename, 'mode', k+1);
        
      case 'TargetMean'
        checkExistence(k, nargin, mfilename, 'target mean vector', propName);
        targetMean = checkTargetMean(varargin{k+1}, nbands, k+1);
        
      case 'TargetSigma'
        checkExistence(k, nargin, mfilename, 'target sigma vector', propName);
        targetSigma = checkTargetSigma(varargin{k+1}, nbands, k+1);
        
      case 'Tolerance'
        checkExistence(k, nargin, mfilename, 'linear stretch fraction(s)', propName);
        tol = checkTol(varargin{k+1}, k+1);
     
      case 'SampleSubscripts'
        checkExistence(k, nargin, mfilename, 'pixel subscript arrays', propName);
        [rowsubs, colsubs] = ...
            checkSubs(varargin{k+1}, size(A,1), size(A,2), k+1);
        
      otherwise
        error(message('images:decorrstretch:internalProblem', propName));
    end
end

%--------------------------------------------------------------------------

function checkExistence(position, nargs, ~, ...
                        propertyDescription, propertyName)

% Error if missing the property value following a property name.

if (position + 1 > nargs)
    error(message('images:decorrstretch:missingParameterValue', propertyDescription, propertyName));
end

%--------------------------------------------------------------------------

function tol = checkTol(tol, position)

% Validate the linear-stretch tolerance.
validateattributes(tol, {'double'},...
              {'nonempty','real','nonnan','nonnegative','finite'},...
              mfilename, 'TOL', position);

if any(tol < 0) || any(tol > 1)
    error(message('images:decorrstretch:tolOutOfRange'));
end

n = numel(tol);
if n > 2
    error(message('images:decorrstretch:tolHasTooManyElements'));
end

if (n == 2) && ~(tol(1) < tol(2))
    error(message('images:decorrstretch:tolNotIncreasing'));
end

if (n == 1) && (tol(1) >= 0.5)
    error(message('images:decorrstretch:tolOutOfRangeScalar'));
end

if n == 1
    tol = [tol 1-tol];
end

%--------------------------------------------------------------------------

function targetMean = checkTargetMean(targetMean, nbands, position)

validateattributes(targetMean, {'double'},...
              {'nonempty','real','nonnan','finite','vector'},...
              mfilename, 'TARGETMEAN', position);

targetMean = targetMean(:)';  % Make sure it's a row vector.

if (numel(targetMean) > 1) && (size(targetMean,2) ~= nbands)
    error(message('images:decorrstretch:targetMeanWrongSize', nbands));
end
  
%--------------------------------------------------------------------------

function targetSigma = checkTargetSigma(targetSigma, nbands, position)

validateattributes(targetSigma, {'double'},...
              {'nonnegative','nonempty','real','nonnan','finite','vector'},...
              mfilename, 'TARGETSIGMA', position);

targetSigma = targetSigma(:)';  % Make sure it's a row vector.

if (numel(targetSigma) > 1) && (size(targetSigma,2) ~= nbands)
    error(message('images:decorrstretch:targetSigmaWrongSize', nbands));
end

% Convert to a diagonal matrix for convenient computation.
targetSigma = diag(targetSigma);

%--------------------------------------------------------------------------

function [rowsubs, colsubs] = checkSubs(subscell, nrows, ncols, position)

if ~iscell(subscell) || numel(subscell) ~= 2
    error(message('images:decorrstretch:sampleSubsNotTwoElementCell'));
end
    
rowsubs = subscell{1}(:);
colsubs = subscell{2}(:);

validateattributes(rowsubs, {'double'},{'nonempty','integer','positive'},...
              mfilename, 'ROWSUBS', position);

validateattributes(colsubs, {'double'},{'nonempty','integer','positive'},...
              mfilename, 'COLSUBS', position);

if any(rowsubs > nrows)
    error(message('images:decorrstretch:subscriptsOutOfRangeRows'));
end

if any(colsubs > ncols)
    error(message('images:decorrstretch:subscriptsOutOfRangeColumns'));
end

if numel(rowsubs) ~= numel(colsubs)
    error(message('images:decorrstretch:subscriptArraySizeMismatch'));
end
