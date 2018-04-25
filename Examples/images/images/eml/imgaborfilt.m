function [M,P] = imgaborfilt(A_,varargin) %#codegen
%IMGABORFILT 2-D Gabor filtering of images.

% Copyright 2015 The MathWorks, Inc.

% imgaborfilt(A,gaborBank) is not a syntax supported in codegen
coder.internal.errorIf(nargin==2,'images:imgaborfilt:syntaxNotSupported');

narginchk(3,7);

% Validate A
validateattributes(A_,{'numeric'},{'2d','finite','nonsparse'},mfilename,'A');

% Work in double precision floating point unless A is passed in as single
if ~isa(A_,'single')
    A = double(A_);
else
    A = A_;
end

% Validate wavelength
validateattributes(varargin{1},{'numeric'}, ...
    {'scalar','nonempty','real','positive','finite','nonsparse','>=',2},...
    mfilename,'wavelength');
wavelength = double(varargin{1});

% Validate orientation
validateattributes(varargin{2},{'numeric'}, ...
    {'scalar','nonempty','real','finite','nonsparse'},...
    mfilename,'orientation');
orientation = double(varargin{2});

% Parse optional input arguments
[spatialAspectRatio,spatialFrequencyBandwidth] = parseOptionalInputs(varargin{3:end});

% Validate SpatialAspectRatio
validateattributes(spatialAspectRatio,{'numeric'}, ...
    {'scalar','nonempty','real','positive','finite','nonsparse'},...
    mfilename,'SpatialAspectRatio');
spatialAspectRatio = double(spatialAspectRatio);

% Validate SpatialFrequencyBandwidth
validateattributes(spatialFrequencyBandwidth,{'numeric'}, ...
    {'scalar','nonempty','real','positive','finite','nonsparse'},...
    mfilename,'SpatialFrequencyBandwidth');
spatialFrequencyBandwidth = double(spatialFrequencyBandwidth);

% Compute sigma_x
sigma_x = wavelength ...
        * sqrt(log(2)/2)/pi ...
        * (2^spatialFrequencyBandwidth+1)/(2^spatialFrequencyBandwidth-1);

% Compute sigma_y
sigma_y = wavelength/spatialAspectRatio ...
        * sqrt(log(2)/2)/pi...
        * (2^spatialFrequencyBandwidth+1)/(2^spatialFrequencyBandwidth-1);

% Store everything in a struct
params.wavelength = wavelength;
params.orientation = orientation;
params.spatialAspectRatio = spatialAspectRatio;
params.spatialFrequencyBandwidth = spatialFrequencyBandwidth;
params.sigma_x = sigma_x;
params.sigma_y = sigma_y;

[M,P] = applyGaborFilterFFT(A,params);

%--------------------------------------------------------------------------
function [spatialAspectRatio,spatialFrequencyBandwidth] = parseOptionalInputs(varargin)

coder.internal.prefer_const(varargin{:});

% Default values
defaultSpatialAspectRatio = 0.5;
defaultSpatialFrequencyBandwidth = 1.0;

params = struct( ...
    'SpatialAspectRatio',uint32(0), ...
    'SpatialFrequencyBandwidth',uint32(0));

options = struct( ...
    'CaseSensitivity',false, ...
    'StructExpand',   true, ...
    'PartialMatching',true);

optarg = eml_parse_parameter_inputs(params,options,varargin{:});

spatialAspectRatio = eml_get_parameter_value( ...
    optarg.SpatialAspectRatio, ...
    defaultSpatialAspectRatio, ...
    varargin{:});

spatialFrequencyBandwidth = eml_get_parameter_value( ...
    optarg.SpatialFrequencyBandwidth, ...
    defaultSpatialFrequencyBandwidth, ...
    varargin{:});

%--------------------------------------------------------------------------
function [M,P] = applyGaborFilterFFT(A,params)

outSize = size(A);

padSize = getPaddingSize(params);
Apadded = padarray(A,padSize,'replicate');
sizeAPadded = size(Apadded);

Af = fft2(Apadded);
H = makeFrequencyDomainTransferFunction(params,sizeAPadded,class(Af));
out = ifft2(Af .* ifftshift(H));

start = padSize+1;
stop = start+outSize-1;

M = abs(out(start(1):stop(1),start(2):stop(2)));
P = angle(out(start(1):stop(1),start(2):stop(2)));

%--------------------------------------------------------------------------
function padSize = getPaddingSize(params)

coder.internal.prefer_const(params);

rx = ceil( 7 * params.sigma_x );
ry = ceil( 7 * params.sigma_y );
r = max(rx,ry);
padSize = [r,r];

%--------------------------------------------------------------------------
function H = makeFrequencyDomainTransferFunction(params,imageSize,classA)
% Directly construct frequency domain transfer function of
% Gabor filter. (Jain, Farrokhnia, "Unsupervised Texture
% Segmentation Using Gabor Filters", 1999)

coder.internal.prefer_const(params, imageSize, classA);

M = imageSize(1);
N = imageSize(2);

u = cast(images.internal.createNormalizedFrequencyVector(N),classA);
v = cast(images.internal.createNormalizedFrequencyVector(M),classA);
[U,V] = meshgrid(u,v);

Uprime = U .*cosd(params.orientation) - V .*sind(params.orientation);
Vprime = U .*sind(params.orientation) + V .*cosd(params.orientation);

sigmau = 1/(2*pi * params.sigma_x);
sigmav = 1/(2*pi * params.sigma_y);
freq = 1/params.wavelength;

A = 2*pi * params.sigma_x * params.sigma_y;

H = A.*exp(-0.5*( ((Uprime-freq).^2)./sigmau^2 + Vprime.^2 ./ sigmav^2) );
