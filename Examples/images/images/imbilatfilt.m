function B = imbilatfilt(varargin)
% IMBILATFILT Bilateral filtering of images with Gaussian kernels
%
%  B = imbilatfilt(A) applies an edge preserving gaussian bilateral filter
%  to the input grayscale (MxN matrix) or color (MxNx3) image A.
%
%  B = imbilatfilt(A, DegreeOfSmoothing) specifies the amount of smoothing
%  in the output image using DegreeOfSmoothing, a positive scalar. A small
%  value will smooth neighborhoods with small variance (uniform areas) and
%  neighborhoods with larger variance (such as edges) will not be smoothed.
%  Larger values will allow smoothing of higher variance neighborhoods,
%  such as stronger edges, in addition to the relatively uniform
%  neighborhoods. 
%  Default: 0.01*diff(getrangefromclass(A)).^2.
%
%  B = imbilatfilt(A, DegreeOfSmoothing, SpatialSigma) additionally
%  specifies the standard deviation of the spatial Gaussian smoothing
%  kernel. Larger values increase the contribution of further neighboring
%  pixels, effectively increasing the neighborhood size. 
%  Default: 1.
%
%  B = imbilatfilt(___, PARAM, VAL,...) specifies additional parameters.
%  Parameter names can be abbreviated. Parameters include:
%
%   'NeighborhoodSize' -  Scalar odd valued positive integer that
%                         specifies the size of the square neighborhood
%                         around each pixel used in bilateral filtering.
%                         Specified value cannot be greater than the size
%                         of the image. 
%                         Default: 2*ceil(2*SpatialSigma)+1
%
%   'Padding'       -     String, character vector or numeric scalar that
%                         specifies padding to be used on image before
%                         filtering. If a scalar (X) is specified, input
%                         image values outside the bounds of the image are
%                         implicitly assumed to have the value X. If a
%                         string is specified, it can be 'replicate' or
%                         'symmetric'. These options are analogous to the
%                         padding options provided by IMFILTER.
%                         Default: 'replicate'.
%
%   Class Support 
%   ------------- 
%   The input array A must be of one of the following classes: uint8, int8,
%   uint16, int16, uint32, int32, single, or double. It must be
%   nonsparse. Output image B is an array of the same size and type as A.
%
%   Notes
%   -----
%   1. DegreeOfSmoothing corresponds to the variance of the Range Gaussian
%      kernel of the Bilateral Filter [1].
%   2. The Range Gaussian is applied on the Euclidean distance of a pixel
%      value from the values of its neighbors. Convert an RGB image to the
%      CIE L*a*b* space using RGB2LAB before applying this filter to
%      smoothen perceptually closer colors. Convert the result back to RGB
%      using LAB2RGB for viewing the results.
%   3. Increasing SpatialSigma increases NeighborhoodSize, which in turn
%      increases the filter execution time. A non-default, smaller
%      NeighborhoodSize can be specified to trade-off accuracy for
%      execution time.
% 
%   Example: Smoothen a grayscale image
%   -----------------------------------------------------
%     % Read and display the input image. Note the striation artifact in 
%     % the sky region.
%     im = imread('cameraman.tif');
%     figure;
%     imshow(im);
% 
%     % Inspect a patch of the image from the sky region.
%     % imsky = imcrop(im); % use this to crop interactively
%     imsky = imcrop(im, [170, 35, 50 50]);
%     figure; 
%     imshow(imsky);
% 
%     % Compute the variance in this patch
%     patchVar = var(double(imsky(:)));
% 
%     % Set the DegreeOfSmoothing to be higher than the variance of the noise.
%     % Increasing DegreeOfSmoothing further blurs some edges, but doesn't
%     % help reduce the striation artifact further.
%     imsmt = imbilatfilt(im, 2*patchVar);
%     figure;
%     imshowpair(im, imsmt, 'montage');
%     title('DegreeOfSmoothing == 2*patchVar');
%     
%     % Increase the spatial extent of the filter to further improve the smoothing
%     imsmt = imbilatfilt(im, 2*patchVar, 2);
%     figure;
%     imshowpair(im, imsmt, 'montage');
%     title('DegreeOfSmoothing == 2*patchVar, SpatialSigma == 2');
%     
%   Example: Smoothen a color image
%   -------------------------------
%     % Read an RGB image, convert to L*a*b colorspace
%     im = imread('coloredChips.png');
%     iml = rgb2lab(im);
%       
%     % Pick a region using the RGB image that contains noise (part of the
%     % background)
%     rect = [34, 71, 60, 55];
%     % [~, rect] = imcrop(im); % uncomment to run interactively
%     imc  = imcrop(im,  rect);
%     imcl = imcrop(iml, rect);      
%     % Use the 'Measure distance' tool to measure the distance between the
%     % horizontal grains
%     imtool(imc) 
%   
%     % Compute the variance of this patch 
%     edist = imcl.^2;
%     edist = sqrt(sum(edist,3)); % Euclidean distance from origin
%     patchVar = var(edist(:));
%   
%     % Set the DegreeOfSmoothing to be higher than the variance of the patch
%     % that needs to be smoothed.
%     imls = imbilatfilt(iml, 2*patchVar);
%     ims = lab2rgb(imls,'Out','uint8');
%     figure;
%     imshowpair(im, ims,'montage')
%     title('DegreeOfSmoothing == 2*patchVar');
%       
%     % Increase the spatial extent of the filter to expand the effective
%     % neighborhood of the filter to span the space between the horizontal
%     % grains of the background. Also increase the DegreeOfSmoothing to
%     % smoothen these regions more aggressively.
%     imls = imbilatfilt(iml, 4*patchVar, 7);
%     ims = lab2rgb(imls,'Out','uint8');
%     figure;
%     imshowpair(im, ims,'montage')
%     title('DegreeOfSmoothing == 4*patchVar, SpatialSigma == 7');     
%
%   References:
%   -----------
%   [1] C. Tomasi and R. Manduchi. 1998. Bilateral Filtering for Gray and
%       Color Images. In Proceedings of the Sixth International Conference
%       on Computer Vision (ICCV '98). IEEE Computer Society, Washington,
%       DC, USA.
%
%   See also: imguidedfilter, locallapfilt, imfilter, imgaussfilt, nlfilter, rgb2lab, lab2rgb

% Copyright 2017 The MathWorks, Inc.


opts = parseInputs(varargin{:});

% Convert to standard deviation
rangeSigma = sqrt(opts.DegreeOfSmoothing);

if images.internal.useIPPLibrary()
    origClass = class(opts.A);
    if ~( isfloat(opts.A) || isa(opts.A,'uint8'))        
        opts.A = double(opts.A);
    end
    B = bilateralFiltermex(opts.A, [opts.NeighborhoodSize, opts.NeighborhoodSize],...
        rangeSigma, opts.SpatialSigma, opts.Padding, opts.PadVal);
    B = cast(B, origClass);
else
    B = images.internal.algimbilateralfilter(opts.A, [opts.NeighborhoodSize, opts.NeighborhoodSize],...
        rangeSigma, opts.SpatialSigma, opts.Padding, opts.PadVal);
end

end

function opts = parseInputs(varargin)

args = matlab.images.internal.stringToChar(varargin);
parser = inputParser;

parser.CaseSensitive = false;
parser.PartialMatching = true;
parser.FunctionName = mfilename;

parser.addRequired('A', ...
    @(A) validateattributes(...
    A, {'uint8','int8','uint16','int16','uint32','int32','single','double'}, ...
    {'nonsparse','nonempty', 'real'},...
    mfilename, 'A'));
parser.addOptional('DegreeOfSmoothing', [],...
    @(sigma) validateattributes(...
    sigma, {'numeric'},...
    {'scalar','real','finite','positive'},...
    mfilename, 'DegreeOfSmoothing'));
parser.addOptional('SpatialSigma', 1,...
    @(sigma) validateattributes(...
    sigma, {'numeric'},...
    {'scalar','real','finite','positive'},...
    mfilename, 'SpatialSigma'));
parser.addParameter('NeighborhoodSize', [],...
    @(n) validateattributes(...
    n, {'numeric'},...
    {'nonsparse', 'nonempty', 'finite', 'real'},...
    mfilename, 'NeighborhoodSize'));
parser.addParameter('Padding', 'replicate',...
    @(p) validateattributes(...
    p, {'numeric','string','char'},...
    {'nonempty'},...
    mfilename, 'Padding'));

parser.parse(args{:});
opts = parser.Results;

if ismatrix(opts.A)
    % numeric grayscale
    validateattributes(...
        opts.A, {'numeric'}, ...
        {'nonsparse','nonempty', 'real','ndims',2},...
        mfilename, 'A')
else
    %  3 channel color
    validateattributes(...
        opts.A, {'numeric'}, ...
        {'nonsparse','nonempty', 'real','ndims',3},...
        mfilename, 'A')
    if size(opts.A,3)~=3
        error(message('images:validate:invalidImageFormat', 'A'));
    end
end

% Default DegreeOfSmoothing
if any(strcmp(parser.UsingDefaults,'DegreeOfSmoothing'))
    opts.DegreeOfSmoothing = 0.01*diff(getrangefromclass(opts.A)).^2;
end

% Default NeighborhoodSize
if any(strcmp(parser.UsingDefaults,'NeighborhoodSize'))
    opts.NeighborhoodSize = 2*ceil(2*opts.SpatialSigma)+1;
end

if min([size(opts.A,1), size(opts.A,2)]) < opts.NeighborhoodSize
    error(message('images:imbilatfilt:imageNotMinSize', opts.NeighborhoodSize));
end   

% Ensure Neighborhoodsize has 1 oddvalued element. 
validateattributes(opts.NeighborhoodSize, ...
    {'numeric'},...
    {'nonsparse', 'nonempty','positive','integer', 'finite', 'real',...
    'odd', 'scalar', '<', min([size(opts.A,1), size(opts.A,2)])},...
    mfilename, 'NeighborhoodSize');


opts.PadVal = 0;
if ~ischar(opts.Padding)
    validateattributes(opts.Padding,...
        {'numeric','logical'}, ...
        {'real','scalar','nonsparse'}, ...
        mfilename, 'Padding');
    opts.PadVal = double(opts.Padding); % will be cast later
    opts.Padding = 'constant';
else
    opts.Padding = validatestring(opts.Padding,...
        {'replicate','symmetric'}, ...
        mfilename, 'Padding');
end


end
