function J = deconvwnr(varargin)
%DECONVWNR Deblur image using Wiener filter.
%   J = DECONVWNR(I,PSF,NSR) deconvolves image I using the Wiener filter
%   algorithm, returning deblurred image J. Image I can be an N-dimensional
%   array. PSF is the point-spread function with which I was convolved. NSR
%   is the noise-to-signal power ratio of the additive noise. NSR can be a
%   scalar or a spectral-domain array of the same size as I. Specifying 0
%   for the NSR is equivalent to creating an ideal inverse filter.
%
%   The algorithm is optimal in a sense of least mean square error between
%   the estimated and the true images. 
%
%   J = deconvwnr(I,PSF,NCORR,ICORR)deconvolves image I, where NCORR is the
%   autocorrelation function of the noise and ICORR is the autocorrelation
%   function of the original image. NCORR and ICORR can be of any size or
%   dimension, not exceeding the original image. If NCORR or ICORR are
%   N-dimensional arrays, the values correspond to the autocorrelation
%   within each dimension. If NCORR or ICORR are vectors, and PSF is also a
%   vector, the values represent the autocorrelation function in the first
%   dimension. If PSF is an array, the 1-D autocorrelation function is
%   extrapolated by symmetry to all non-singleton dimensions of PSF. If
%   NCORR or ICORR is a scalar, this value represents the power of the
%   noise of the image.
%
%   Note that the output image J could exhibit ringing introduced by the
%   discrete Fourier transform used in the algorithm. To reduce the ringing
%   use I = EDGETAPER(I,PSF) prior to calling DECONVWNR.
%
%   Class Support
%   -------------
%   I can be uint8, uint16, int16, double, or single. Other inputs have to
%   be double. J has the same class as I.
%
%   Example
%   -------
%
%      I = im2double(imread('cameraman.tif'));
%      imshow(I);
%      title('Original Image (courtesy of MIT)');
% 
%      % Simulate a motion blur.
%      LEN = 21;
%      THETA = 11;
%      PSF = fspecial('motion', LEN, THETA);
%      blurred = imfilter(I, PSF, 'conv', 'circular');
% 
%      % Simulate additive noise.
%      noise_mean = 0;
%      noise_var = 0.0001;
%      blurred_noisy = imnoise(blurred, 'gaussian', ...
%                         noise_mean, noise_var);
%      figure, imshow(blurred_noisy)
%      title('Simulate Blur and Noise')
% 
%      % Try restoration assuming no noise.
%      estimated_nsr = 0;
%      wnr2 = deconvwnr(blurred_noisy, PSF, estimated_nsr);
%      figure, imshow(wnr2)
%      title('Restoration of Blurred, Noisy Image Using NSR = 0')
% 
%      % Try restoration using a better estimate of the noise-to-signal-power 
%      % ratio.
%      estimated_nsr = noise_var / var(I(:));
%      wnr3 = deconvwnr(blurred_noisy, PSF, estimated_nsr);
%      figure, imshow(wnr3)
%      title('Restoration of Blurred, Noisy Image Using Estimated NSR');
%
%   See also DECONVREG, DECONVLUCY, DECONVBLIND, EDGETAPER, IMNOISE, PADARRAY, 
%            PSF2OTF, OTF2PSF.

%   Copyright 1993-2013 The MathWorks, Inc.


%   References
%   ----------
%   "Digital Image Processing", R. C. Gonzalez & R. E. Woods,
%   Addison-Wesley Publishing Company, Inc., 1992.

% Parse inputs to verify valid function calling syntaxes and arguments
[I, PSF, ncorr, icorr, sizeI, classI, sizePSF, numNSdim] = ...
    parseInputs(varargin{:});

% Compute H so that it has the same size as I.
H = psf2otf(PSF, sizeI);

if isempty(icorr)
    % noise-to-signal power ratio is given
    S_u = ncorr;
    S_x = 1;
    
else 
    % noise & signal frequency characteristics are given
    NSD = length(numNSdim);
    
    S_u = powerSpectrumFromACF(ncorr, NSD, numNSdim, sizePSF, sizeI);
    S_x = powerSpectrumFromACF(icorr, NSD, numNSdim, sizePSF, sizeI);

end

% Compute the Wiener restoration filter:
%
%                   H*(k,l)
% G(k,l)  =  ------------------------------
%            |H(k,l)|^2 + S_u(k,l)/S_x(k,l)
%
% where S_x is the signal power spectrum and S_u is the noise power
% spectrum.
%
% To minimize issues associated with divisions, the equation form actually
% implemented here is this:
%
%                   H*(k,l) S_x(k,l)
% G(k,l)  =  ------------------------------
%            |H(k,l)|^2 S_x(k,l) + S_u(k,l)
%
%

% Compute the denominator of G in pieces.
denom = abs(H).^2;
denom = denom .* S_x;
denom = denom + S_u;
clear S_u

% Make sure that denominator is not 0 anywhere.  Note that denom at this
% point is nonnegative, so we can just add a small term without fearing a
% cancellation with a negative number in denom.
denom = max(denom, sqrt(eps));

G = conj(H) .* S_x;
clear H S_x
G = G ./ denom;
clear denom

% Apply the filter G in the frequency domain.
J = ifftn(G .* fftn(I));
clear G

% If I and PSF are both real, then any nonzero imaginary part of J is due to
% floating-point round-off error.
if isreal(I) && isreal(PSF)
    J = real(J);
end

% Convert to the original class 
if ~strcmp(classI, 'double')
    J = images.internal.changeClass(classI, J);
end;

%=====================================================================
function S = powerSpectrumFromACF(ACF, NSD, numNSdim, sizePSF, sizeI)
% Compute power spectrum from autocorrelation function.
%
% ACF - autocorrelation function
% NSD - number of nonsingleton dimensions of PSF
% NSD - nonsingleton dimensions of PSF
% sizePSF - size of the PSF
% sizeI  - size of the input image

sizeACF = size(ACF);
if (length(sizeACF)==2) && (sum(sizeACF==1)==1) && (NSD>1)
    %ACF is 1D
    % autocorrelation function and PSF has more than one non-singleton
    % dimension.Therefore, we extrapolate ACF using symmetry to all PSF
    % non-singleton dimensions & reshape it to include singletons.
    ACF = createNDfrom1D(ACF,NSD,numNSdim,sizePSF);
end

% Calculate power spectrum
S = abs(fftn(ACF,sizeI));
%---------------------------------------------------------------------

%=====================================================================
function [I, PSF, ncorr, icorr, sizeI, classI, sizePSF, numNSdim] = ...
    parseInputs(varargin)
% Outputs:  I     the input array (could be any numeric class, 2D, 3D)
%           PSF   operator that applies blurring on the image
%           ncorr is noise power (if scalar), 1D or 2D autocorrelation 
%                 function (acf) of noise, or part of it
%                 it become noise-to-signal power ratio if icorr is empty
%           icorr is signal power (if scalar), 1D or 2D autocorrelation 
%                 function (acf) of signal, or part of it
%           numNSdim non-singleton dimensions of PSF

% Defaults:
ncorr = 0;
icorr = [];

narginchk(2,4);

% First, check validity of class/real/finite for all except image at once:
% J = DECONVWNR(I,PSF,NCORR,ICORR)
input_names={'PSF','NCORR','ICORR'};
for n = 2:nargin,
    validateattributes(varargin{n},{'double'},{'real' 'finite'},...
                  mfilename,input_names{n-1},n);
end;

% Second, assign the inputs:
I = varargin{1};%        deconvwnr(A,PSF)
PSF = varargin{2};
switch nargin
  case 3,%                 deconvwnr(A,PSF,nsr)
    ncorr = varargin{3};
  case 4,%                 deconvwnr(A,PSF,ncorr,icorr)
    ncorr = varargin{3};
    icorr = varargin{4};
end

% Third, Check validity of the input parameters: 

% Input image I
sizeI = size(I);
classI = class(I);
validateattributes(I,{'uint8','uint16','int16','double','single'},{'real' ...
                    'finite'},mfilename,'I',1);
if prod(sizeI)<2,
    error(message('images:deconvwnr:mustHaveAtLeast2Elements'))
elseif ~isa(I,'double')
    I = im2double(I);
end

% PSF array
sizePSF = size(PSF);
if prod(sizePSF)<2,
    error(message('images:deconvwnr:psfMustHaveAtLeast2Elements'))
elseif all(PSF(:)==0),
    error(message('images:deconvwnr:psfMustNotBeZeroEverywhere'))
end

% NSR, NCORR, ICORR
if isempty(ncorr) && ~isempty(icorr),
    error(message('images:deconvwnr:invalidInput'))
end

% Sizes: PSF size cannot be larger than the image size in non-singleton dims
[sizeI, sizePSF, sizeNCORR] = padlength(sizeI, sizePSF, size(ncorr));
numNSdim = find(sizePSF~=1);
if any(sizeI(numNSdim) < sizePSF(numNSdim))
    error(message('images:deconvwnr:psfMustBeSmallerThanImage'))
end

if isempty(icorr) && (prod(sizeNCORR)>1) && ~isequal(sizeNCORR,sizeI)
    error(message('images:deconvwnr:nsrMustBeScalarOrArrayOfSizeA'))
end
%---------------------------------------------------------------------

%=====================================================================
%
function f = createNDfrom1D(ACF,NSD,numNSdim,sizePSF)
% create a ND-ACF from 1D-ACF assuming rotational symmetry and preserving
% singleton dimensions as in sizePSF

% First, make a 2D square ACF from the given 1D ACF. Calculate the
% quarter of the 2D square & unfold it symmetrically to the full size. 
% 1. Define grid with a half of the ACF points (assuming that ACF
% is symmetric). Grid is 2D and it values from 0 to 1.
cntr = ceil(length(ACF)/2);%location of the ACF center
vec = (0:(cntr-1))/(cntr-1);
[x,y] = meshgrid(vec,vec);% grid for the quarter
      
% 2. Calculate radius vector to each grid-point and number the points
% above the diagonal in order to use them later for ACF interpolation.
radvect = sqrt(x.^2+y.^2);
nums = [1;find(triu(radvect)~=0)];

% 3. Interpolate ACF at radius-vector distance for those points.
acf1D = ACF(cntr-1+[1:cntr cntr]);% last point is for the corner.
radvect(nums) = interp1([vec sqrt(2)],acf1D,radvect(nums));

% 4. Unfold 45 degree triangle to a square, and then the square
% quarter to a full square matrix.
radvect = triu(radvect) + triu(radvect,1).';
acf = radvect([cntr:-1:2 1:cntr],[cntr:-1:2 1:cntr]);
        
% Second, once 2D is ready, extrapolate 2D-ACF to NSD-ACF
if NSD > 2,% that is create volumetric ACF
    idx0 = repmat({':'},[1 NSD]);
    nextDimACF = [];
    for n = 3:NSD,% make sure not to exceed the PSF size
        numpoints = min(sizePSF(numNSdim(n)),length(ACF));
        % and take only the central portion of 1D-ACF
        vec = cntr-ceil(numpoints/2)+(1:numpoints);
        for m = 1:numpoints,
            idx = [idx0(1:n-1),{m}];
            nextDimACF(idx{:}) = ACF(vec(m))*acf; %#ok<AGROW>
        end;
        acf = nextDimACF;
    end
end

% Third, reshape NSD-ACF to the right dimensions to include PSF
% singletons.
idx1 = repmat({1},[1 length(sizePSF)]);
idx1(numNSdim) = repmat({':'},[1 NSD]);
f(idx1{:}) = acf;
%---------------------------------------------------------------------      
