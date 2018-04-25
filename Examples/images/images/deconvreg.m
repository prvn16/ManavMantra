function [J, LAGRA] = deconvreg(varargin)
%DECONVREG Deblur image using regularized filter.
%   J = DECONVREG(I,PSF) deconvolves image I using regularized 
%   filter algorithm, returning deblurred image J. The assumption is
%   that the image I was created by convolving a true image with a
%   point-spread function PSF and possibly by adding noise. The algorithm
%   is a constrained optimum in a sense of least square error between the
%   estimated and the true images under requirement of preserving image
%   smoothness. 
%   
%   I can be an N-Dimensional array.
%
%   To improve the restoration, additional parameters can be passed in
%   (use [] as a place holder if an intermediate parameter is unknown):
%   J = DECONVREG(I,PSF,NP)
%   J = DECONVREG(I,PSF,NP,LRANGE)
%   J = DECONVREG(I,PSF,NP,LRANGE,REGOP), where
%
%   NP     (optional) is the additive noise power. Default is 0.
%
%   LRANGE (optional) is a vector specifying range where search for the
%   optimal solution is performed. The algorithm finds an optimal 
%   Lagrange multiplier, LAGRA, within the LRANGE range. If LRANGE is a 
%   scalar, the algorithm assumes that LAGRA is given and equal to
%   LRANGE; the NP value is then ignored. Default is [1e-9 and 1e9].
%
%   REGOP  (optional) is the regularization operator to constrain the
%   deconvolution. To retain the image smoothness, the Laplacian
%   regularization operator is used by default. The REGOP array
%   dimensions must not exceed the image dimensions, any non-singleton
%   dimensions must correspond to the non-singleton dimensions of PSF.
%
%   [J, LAGRA] = DECONVREG(I,PSF,...) outputs value of the Lagrange
%   multiplier, LAGRA, in addition to the restored image J.
%
%   Note that the output image J could exhibit ringing introduced by the
%   discrete Fourier transform used in the algorithm. To reduce the
%   ringing use I = EDGETAPER(I,PSF) prior to calling DECONVREG.
%
%   Class Support
%   -------------
%   I can be uint8, uint16, int16, double, or single. Other inputs have to be
%   double. J has the same class as I.
%
%   Example
%   -------
%
%      I = checkerboard(8);
%      PSF = fspecial('gaussian',7,10);
%      V = .01;
%      BlurredNoisy = imnoise(imfilter(I,PSF),'gaussian',0,V);
%      NP = V*prod(size(I));% noise power
%      [J LAGRA] = deconvreg(BlurredNoisy,PSF,NP);
%      subplot(221);imshow(BlurredNoisy);
%                     title('A = Blurred and Noisy');
%      subplot(222);imshow(J);
%                     title('[J LAGRA] = deconvreg(A,PSF,NP)');
%      subplot(223);imshow(deconvreg(BlurredNoisy,PSF,[],LAGRA/10));
%                     title('deconvreg(A,PSF,[],0.1*LAGRA)');
%      subplot(224);imshow(deconvreg(BlurredNoisy,PSF,[],LAGRA*10));
%                     title('deconvreg(A,PSF,[],10*LAGRA)');
%
%   See also DECONVWNR, DECONVLUCY, DECONVBLIND, EDGETAPER, IMNOISE, PADARRAY, 
%            PSF2OTF, OTF2PSF.

%   Copyright 1993-2013 The MathWorks, Inc.


%   References
%   ----------
%   "Digital Image Processing", R. C. Gonzalez & R. E. Woods,
%   Addison-Wesley Publishing Company, Inc., 1992.
%   "Fundamentals of digital image processing", A. K. Jain, 
%   Prentice Hall, NJ, 1989.

% Parse inputs to verify valid function calling syntaxes and arguments
[I, PSF, NP, LR, REGOP, sizeI, classI, sizePSF, numNSdim] = parse_inputs(varargin{:});

% First, Optical transfer function has the same size/dims as I
otf = psf2otf(PSF,sizeI);% even if PSF does not

% Second, define the regulazation operator REGOP and minimization parameter
% LAGRA. We'll need K=LAGRA*REGOP^2 for the image reconstruction 

if isempty(REGOP),%The Laplacian is the default regularization operator. Its
  % dimensionality is determined by the non-singleton dimensions of PSF
  
  NSD = length(numNSdim);% total number of non-singleton dimensions

  if NSD == 1,
    regop = [1 -2 1];
    
  else % REGOP dimensions = number of PSF non-singleton dimensions
    
    % total ND Laplacian array consists of 3x3 matrixes
    regop = repmat(zeros(3),[1 1 3*ones(1,NSD-2)]);
    
    % edge matrixes of ND Laplacian (first and third matrix on either
    for n = 3:NSD,% side) have 1 in (2,2) position.
      idx = [repmat({2},[1 n-1]), {[1 3]}, repmat({2},[1 (NSD-n)])];
      regop(idx{:}) = 1;
    end

    % center matrix of ND Laplacian (second matrix from either edge)
    idx = [{':'}, {':'}, repmat({2},[1 NSD-2])];
    regop(idx{:}) = [0 1 0;1 -NSD*2 1;0 1 0];
  end

  % reshape REGOP to the right dimensions to include PSF singletons
  idx1 = repmat({1},[1 length(sizePSF)]);
  idx1(numNSdim) = repmat({':'},[1 NSD]);
  REGOP(idx1{:}) = regop;
  
end
REGOP = psf2otf(REGOP,sizeI);

fftnI = fftn(I);
clear I;
R2 = abs(REGOP).^2;
clear REGOP;
H2 = abs(otf).^2;

% Third, calculate minimization parameter LAGRA: find LAGRA for which the
% power of the deconvolution residuals near equals the noise power.

if (numel(LR)==1) || isequal(diff(LR),0),% LAGRA is given
  LAGRA = LR(1);

else % prepare coefficients for the optimization function (to speed it up)
  R4G2 = (R2.*abs(fftnI)).^2;
  H4 = H2.^2;
  R4 = R2.^2;
  H2R22 = 2*H2.*R2;
  ScaledNP = NP*prod(sizeI);
  
  LAGRA = fminbnd(@ResOffset,LR(1),LR(2),[],R4G2,H4,R4,H2R22,ScaledNP);
  clear H4 R4 H2R22 R4G2;
end;

% Forth, reconstruct the image
Denom = H2 + LAGRA*R2;
clear R2 H2;
Nomin = conj(otf).*fftnI;
clear fftnI otf;

% Make sure that the denominator is not extremely small.  Note that 
% the denominator is nonnegative, so we can use max.
Denom = max(Denom, sqrt(eps));

J = real(ifftn(Nomin./Denom));
clear Denom Nomin;

% Convert to the original class 
if ~strcmp(classI,'double'),
  J = images.internal.changeClass(classI,J);
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Function: parse_inputs
function [I, PSF, NP, LR, REGOP, sizeI, classI, sizePSF, numNSdim] = parse_inputs(varargin)
% Outputs:
% I        the input array (could be any numeric class, 2D, 3D)
% PSF      operator that distorts the ideal image
% NP       noise power - must be a number
% LR       min max value for the range of search for minimum, could be
%          just one number
% REGOP      regularization operator (Laplacian is the default). Its
%          dimensionality is determined by the non-singleton dimensions of PSF
% numNSdim non-singleton dimensions of PSF
% Defaults:
%
NP = 0;
LR = [1e-9 1e9];
REGOP = [];

narginchk(2,5)

% First, check validity of class/real/finite for all except image:
for n = 2:nargin,
  if ~isa(varargin{n},'double'),
    error(message('images:deconvreg:invalidParameterClass', n));
  elseif ~isreal(varargin{n}),
    error(message('images:deconvreg:expectedRealParam', n));
  elseif ~all(isfinite(varargin{n}(:))),
    error(message('images:deconvreg:expectedFiniteParam', n));
  end;
end;

% Second, assign the inputs:
I = varargin{1};%        deconvreg(I,PSF)
PSF = varargin{2};
switch nargin
case 3,%                 deconvreg(I,PSF,NOISEPOWER)
  NP = varargin{3};
case 4,%                 deconvreg(I,PSF,NOISEPOWER,LRANGE)
  NP = varargin{3};
  LR = varargin{4};
case 5,%                 deconvreg(I,PSF,NOISEPOWER,LRANGE,REGOP)
  NP = varargin{3};
  LR = varargin{4};
  REGOP = varargin{5};
end

% Third, Check validity of the input parameters: 

% Input image I
sizeI = size(I);
classI = class(I);
valid_classes = {'uint8','uint16','double','int16','single'};
idx = strncmp(classI,valid_classes,length(classI));
if ~any(idx,2),
  error(message('images:deconvreg:invalidType'))
elseif isempty(I) || length(I)<3,
  error(message('images:deconvreg:tooSmall'))
elseif ~isreal(I),
  error(message('images:deconvreg:expectedRealImage'))
elseif idx<3,
  I = im2double(I);
end
if ~all(isfinite(I(:))),
  error(message('images:deconvreg:expectedFiniteImage'))
end;

% PSF array
sizePSF = size(PSF);
if prod(sizePSF)<2,
  error(message('images:deconvreg:psfTooSmall'))
elseif all(PSF(:)==0),
  error(message('images:deconvreg:psfAllZero'))
end

% Noise Power
if isempty(NP),
  NP = 0;% default;
elseif numel(NP) > 1
  error(message('images:deconvreg:expectedScalar'))
end

% LRANGE
if isempty(LR)
  LR = [1e-9 1e9];
elseif numel(LR) > 2
  error(message('images:deconvreg:invalidLRangeSize'))
elseif diff(LR)<0,
  error(message('images:deconvreg:invalidLRange'))
end

% REGOP & PSF sizes cannot exceed the image size in any non-singleton dimension
[sizeI, sizePSF, sizeREGOP] = padlength(sizeI, sizePSF, size(REGOP));
numNSdim = find(sizePSF~=1);
if any(sizeI(numNSdim) < sizePSF(numNSdim))
  error(message('images:deconvreg:psfTooBig'))
end
numNSdimR = find(sizeREGOP~=1);
if ~isempty(numNSdimR),
  if any(sizeI(numNSdimR) < sizeREGOP(numNSdimR))
    error(message('images:deconvreg:regopTooBig'))
  elseif any(sizePSF(numNSdimR)==1) && ~isempty(REGOP),
    error(message('images:deconvreg:regopPsfMismatch'))
  end
end;

function f = ResOffset(LAGRA,R4G2,H4,R4,H2R22,ScaledNP)
% Compute the power of the deconvolution residuals
% using Parseval's theorem and its difference with noise power
Residuals = R4G2./(H4 + LAGRA*H2R22 + LAGRA^2*R4 + sqrt(eps));
f = abs(LAGRA^2*sum(Residuals(:)) - ScaledNP);
