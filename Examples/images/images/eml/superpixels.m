function [L,numSuperpixels] = superpixels(A_,N_,varargin) %#codegen
%superpixels 2-D superpixel oversegmentation of images for code generation

%   Copyright 2015 The MathWorks, Inc.

%   Syntax
%   ------
%
%       [L,numSuperpixels] = superpixels(A,N)
%       [L,numSuperpixels] = superpixels(A,N,NAME,VALUE,...)
%
%   Input Specs
%   -----------
%
%     A:
%       MxN grayscale image or MxNx3 color image
%       can be in RGB color space (sRGB only) or in L*a*b*
%       if RGB, then must be either uint8, uint16, single or double
%       if L*a*b*, then must be either single or double
%       real
%       nonsparse
%
%     N:
%       numeric: single, double, int8, int16, int32,
%                int64, uint8, uint16, uint32, uint64
%       scalar
%       positive ( >0 and non-complex )
%       finite (NaN and Inf forbidden)
%       nonempty
%       nonsparse
%
%     Compactness:
%       numeric: single, double, int8, int16, int32,
%                int64, uint8, uint16, uint32, uint64
%       scalar
%       nonnegative ( >=0 and non-complex )
%       finite (NaN and Inf forbidden)
%       nonempty
%       nonsparse
%       default: 10 if Method is 'slic', 1 if Method is 'slic0'
%
%     IsInputLab:
%       logical or numeric (cast to bool)
%       scalar
%       finite
%       nonempty
%       nonsparse
%       default: false
%
%     Method:
%       string with value either 'slic' or 'slic0'
%       must be a compile-time constant
%       default: 'slic0'
%
%     NumIterations:
%       numeric: single, double, int8, int16, int32,
%                int64, uint8, uint16, uint32, uint64
%       scalar
%       positive ( >0 and non-complex)
%       finite
%       nonempty
%       nonsparse
%       default: 10
%
%   OutputSpecs
%   -----------
%
%     L:
%       2-D double matrix of size [size(A,1),size(A,2)]
%
%     numSuperpixels:
%       scalar of class double
%

% Parse the optional parameters
[isInputLab,compactness,useSLIC0,numIters] = parseInputs(varargin{:});
coder.internal.prefer_const(isInputLab,compactness,useSLIC0,numIters);

% Check the input image and convert to L*a*b* if necessary
A = validateImage(A_,isInputLab);

% Check the desired number of superpixels
N = validateDesiredNumSuperpixels(N_,A);

% Run the algorithm
solver = images.internal.coder.SLICSuperpixels(A,N,compactness,useSLIC0);
[L,numSuperpixels] = solver.generateSuperPixels(numIters);

%--------------------------------------------------------------------------
function [isInputLab,compactness,isSLIC0,numIters] = parseInputs(varargin)

narginchk(0,8);

[compactnessIn,isInputLabIn,methodIn,numItersIn] = parsePVPairs(varargin{:});

% Validate Method
method = validatestring(methodIn,{'slic','slic0'},mfilename,'Method');
isSLIC0 = (numel(method) == 5);

% If the compactness was not specified by the user,
% set it to the default based on the chosen method.
if isequal(compactnessIn,-3.14)
    if isSLIC0
        compactnessIn = cast(1,'like',compactnessIn);
    else
        compactnessIn = cast(10,'like',compactnessIn);
    end
end

% Validate Compactness
validateattributes(compactnessIn,{'numeric'}, ...
    {'nonempty','real','scalar','positive','finite','nonsparse'}, ...
    mfilename,'Compactness');
compactness = double(compactnessIn);

% Validate IsInputLab
validateattributes(isInputLabIn,{'numeric','logical'}, ...
    {'real','scalar','finite','nonempty','nonsparse'}, ...
    mfilename,'IsInputLab');
isInputLab = logical(isInputLabIn);

% Validate NumIterations
validateattributes(numItersIn,{'numeric'}, ...
    {'nonempty','real','scalar','positive','finite','nonsparse','integer'}, ...
    mfilename,'NumIterations');
numIters = coder.internal.indexInt(numItersIn);

%--------------------------------------------------------------------------
% Parse optional PV pairs:
% 'Compactness', 'IsInputLab', 'Method', 'NumIterations'
function [compactness,isInputLab,method,numIters] = parsePVPairs(varargin)

coder.internal.prefer_const(varargin{:});

% Default values
defaultCompactness   = -3.14; % magic number!
defaultIsInputLab    = false;
defaultMethod        = 'slic0';
defaultNumIterations = 10;

params = struct( ...
    'Compactness',uint32(0), ...
    'IsInputLab',uint32(0), ...
    'Method',uint32(0), ...
    'NumIterations',uint32(0));

options = struct( ...
    'CaseSensitivity',false, ...
    'StructExpand',   true, ...
    'PartialMatching',true);

optarg = eml_parse_parameter_inputs(params,options,varargin{:});

compactness = eml_get_parameter_value( ...
    optarg.Compactness, ...
    defaultCompactness, ...
    varargin{:});

isInputLab = eml_get_parameter_value( ...
    optarg.IsInputLab, ...
    defaultIsInputLab, ...
    varargin{:});

method = eml_get_parameter_value( ...
    optarg.Method, ...
    defaultMethod, ...
    varargin{:});

numIters = eml_get_parameter_value( ...
    optarg.NumIterations, ...
    defaultNumIterations, ...
    varargin{:});

%--------------------------------------------------------------------------
function A = validateImage(A_,isInputLab)

coder.internal.prefer_const(isInputLab);

% The 3rd dimension of A must be determined at compile time
coder.internal.errorIf( ...
    ~coder.internal.isConst(size(A_,3)), ...
    'images:superpixels:codegenThirdDimensionMustBeFixed');

% A must be a MxN grayscale image or a MxNx3 color image
validColorImage = (ndims(A_) == 3) && (size(A_,3) == 3);
coder.internal.errorIf( ...
    ~(ismatrix(A_) || validColorImage), ...
    'images:superpixels:expectGrayscaleOrColor');

attributes = {'nonempty','nonsparse','real','nonnan','finite'};

if isInputLab
    % L*a*b*
    validateattributes(A_,{'single','double'}, ...
        attributes,mfilename,'A',1);
    
    % A could be a 2D array with only the L* component
    % or a 3D array with L*, a* and b*
    A = A_;
else
    validateattributes(A_,{'single','double','uint8','uint16'}, ...
        attributes,mfilename,'A',1);
    
    if ismatrix(A_)
        % Grayscale
        temp = rgb2lab(repmat(A_,[1 1 3]));
        A = temp(:,:,1);
    else
        % RGB
        A = rgb2lab(A_);
    end
end

%--------------------------------------------------------------------------
function N = validateDesiredNumSuperpixels(N_,A)

validateattributes(N_,{'numeric'}, ...
    {'nonempty','scalar','positive','finite','integer','nonsparse'}, ...
    mfilename,'N',2);

coder.internal.errorIf(N_ > size(A,1)*size(A,2), ...
    'images:superpixels:tooManySuperpixelsRequested');

N = double(N_);
