function RGB = localtonemap(varargin)
%LOCALTONEMAP Render HDR image for viewing while enhancing local contrast
%
%   RGB = localtonemap(HDR) converts the high dynamic range image HDR to a
%   lower dynamic range image, RGB, suitable for display, using a process
%   called tone mapping while preserving its local contrast.
%
%   RGB = localtonemap(HDR, Name, Value, ...) performs tone mapping where
%   parameters control various aspects of the operation. Parameter names
%   can be abbreviated. Parameters include:
%
%     'RangeCompression' - Numeric scalar specifying the amount of
%                          compression applied to the dynamic range of HDR.
%                          Must be in [0,1]. A value of 1 represents
%                          maximum compression using local Laplacian
%                          filtering. A value of 0 represents minimum
%                          compression, which consists in only remapping
%                          the middle 99% intensities to a dynamic range of
%                          100:1 followed by gamma correction with an
%                          exponent of 1/2.2.
%
%                          Default: 1.
%
%     'EnhanceContrast'  - Numeric scalar specifying the amount of local
%                          contrast enhancement applied. Must be in [0,1].
%                          A value of 0 leaves the local contrast
%                          unchanged. A value of 1 represents maximum local
%                          contrast enhancement.
%
%                          Default: 0.
%
%   Class Support
%   -------------
%   HDR must be a real, non-sparse M-by-N or M-by-N-by-3 matrix of class
%   single. The values of the parameters 'RangeCompression' and
%   'EnhanceContrast' must be numeric scalar in [0,1].
%
%   Notes
%   -----
%   LOCALTONEMAP uses local Laplacian filtering in logarithmic space to
%   compress the dynamic range of HDR while preserving or enhancing its
%   local contrast. The 99% middle intensities of the compressed image are
%   then remapped to a fixed 100:1 dynamic range to give the output image a
%   consistent look. Gamma correction is then applied to produce the final
%   image, RGB, for display.
%
%   Example
%   -------
%   Compress the dynamic range of an HDR image for viewing
%
%   % Load a high dynamic range image
%   HDR = hdrread('office.hdr');
%
%   % Apply local tone mapping with a small
%   % amount of dynamic range compression
%   RGB = localtonemap(HDR, 'RangeCompression', 0.1);
%
%   % Display the resulting tone-mapped image
%   imshow(RGB)
%
%   % Repeat the operation but, this time, accentuate
%   % the details to give the image a dramatic look
%   RGB = localtonemap(HDR, ...
%       'RangeCompression', 0.1, ...
%       'EnhanceContrast', 0.5);
%
%   % Display the resulting tone-mapped image with increased details
%   imshow(RGB)
%
%   See also TONEMAP, LOCALLAPFILT.

%   Copyright 2016 The MathWorks, Inc.

%   Reference
%   ---------
%   Paris, Sylvain, Samuel W. Hasinoff, and Jan Kautz. "Local Laplacian
%   filters: edge-aware image processing with a Laplacian pyramid."
%   ACM Trans. Graph. 30.4 (2011): 68.

inputs = parseInputs(varargin{:});

HDR = inputs.HDR;
compression = inputs.RangeCompression;
enhancement = inputs.EnhanceContrast;

if (enhancement == 0)
    numIntensityLevels = 'auto';
else
    numIntensityLevels = 50;
end

% equivalent beta parameter for LLF
beta = 1 - compression;
% enhancement \in [0,1] <=> alpha \in [0.01,1]
alpha = 1 - 0.99 * enhancement;
% fix sigma
sigma = log(2.5);

% Convert to grayscale if needed
if ismatrix(HDR)
    L1 = HDR;
else
    % rgb2gray clips the output to [0,1], so convert manually
    L1 = single(0.298936021293776) * HDR(:,:,1) + ...
         single(0.587043074451121) * HDR(:,:,2) + ...
         single(0.114020904255103) * HDR(:,:,3);
    ratios = HDR ./ repmat(L1 + eps('single'), [1 1 3]);
end

% Get the log intensity
% In log space, pixel differences correspond directly to contrast.
logL1 = log(L1 + eps('single'));

% If logL1 isn't real, then HDR contained negative values.
% Error early with a nice message.
if ~isreal(logL1)
    validateattributes(-1,{'double'},{'nonnegative'},mfilename,'HDR',1);
end

% Filter
logL2 = locallapfilt(logL1, sigma, alpha, beta, ...
    'NumIntensityLevels', numIntensityLevels);

% Convert back to linear intensity
L2 = exp(logL2) - eps('single');

% Remap the middle 99% of intensities to
% a fixed dynamic range of 100:1 with a gamma curve
percentiles = getPercentiles(L2, [0.5, 99.5]);
currentDynamicRange = percentiles(2)/percentiles(1);

if (currentDynamicRange == 1)
    % flat image
    RGB = HDR;
    return
elseif ~isfinite(currentDynamicRange)
    % input contained a NaN or an Inf
    RGB = nan(size(HDR),'like',HDR);
    return
end

targetDynamicRange = 100;
exponent = reallog(targetDynamicRange) / reallog(currentDynamicRange);
L2 = max(0,L2/percentiles(2)) .^ exponent;

% Reintroduce color if needed
if ismatrix(HDR)
    RGB = L2;
else
    RGB = repmat(L2,[1,1,3]) .* ratios;
end

% Clip out of bounds intensities
RGB = max(0,min(1,RGB));

% Gamma-correct linear intensities
RGB = RGB .^ (1/2.2);

%--------------------------------------------------------------------------
function inputs = parseInputs(varargin)

narginchk(1,5);

parser = inputParser();
parser.FunctionName = mfilename;

% HDR
validateHDR = @(x) validateattributes(x, ...
    {'single'}, ...
    {'real','nonsparse','nonempty'}, ...
    mfilename,'HDR',1);
parser.addRequired('HDR', validateHDR);

% NameValue 'RangeCompression'
defaultRangeCompression = 1;
% must be in [0,1]
validateRangeCompression = @(x) validateattributes(x, ...
    {'numeric'}, ...
    {'scalar','real','nonnegative','<=',1,'finite','nonsparse','nonempty'}, ...
    mfilename,'RangeCompression');
parser.addParameter('RangeCompression', ...
    defaultRangeCompression, ...
    validateRangeCompression);

% NameValue 'EnhanceContrast'
defaultEnhanceContrast = 0;
% must be in [0,1]
validateEnhanceContrast = @(x) validateattributes(x, ...
    {'numeric'}, ...
    {'scalar','real','nonnegative','<=',1,'finite','nonsparse','nonempty'}, ...
    mfilename,'EnhanceContrast');
parser.addParameter('EnhanceContrast', ...
    defaultEnhanceContrast, ...
    validateEnhanceContrast);

parser.parse(varargin{:});
inputs = parser.Results;

% Additional input validation

% HDR must be MxN or MxNx3
validColorImage = (ndims(inputs.HDR) == 3) && (size(inputs.HDR,3) == 3);
if ~(ismatrix(inputs.HDR) || validColorImage)
    error(message('images:validate:invalidImageFormat','HDR'));
end

%--------------------------------------------------------------------------
function y = getPercentiles(x, p)

x = x(:);
x = sort(x,1);

% Number of non-NaN values
n = sum(~isnan(x), 1);

% If the column has no valid data,
% set n=1 to get nan in the result
if (n == 0)
    n = 1;
end

y = interpolatePercentiles(x,p,n);
y = reshape(y,size(p)); 

%--------------------------------------------------------------------------
function y = interpolatePercentiles(x, p, n)

% Make p a column vector
p = p(:);

% Form the vector of index values (numel(p) x 1)
r = (p/100)*n;
k = floor(r+0.5); % K gives the index for the row just before r
kp1 = k + 1;      % K+1 gives the index for the row just after r
r = r - k;        % R is the ratio between the K and K+1 rows

% Find indices that are out of the range 1 to n and cap them
k(k<1 | isnan(k)) = 1;
kp1 = bsxfun( @min, kp1, n );

% Use simple linear interpolation for the valid percentages
y = (0.5+r).*x(kp1,:)+(0.5-r).*x(k,:);

% Make sure that values we hit exactly
% are copied rather than interpolated
exact = (r == -0.5);
if any(exact)
    y(exact,:) = x(k(exact),:);
end

% Make sure that identical values are
% copied rather than interpolated
same = (x(k,:)==x(kp1,:));
if any(same(:))
    x = x(k,:); % expand x
    y(same) = x(same);
end
