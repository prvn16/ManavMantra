function [J,P] = deconvblind(varargin)
%DECONVBLIND Deblur image using blind deconvolution.
%   [J,PSF] = DECONVBLIND(I,INITPSF) deconvolves image I using maximum
%   likelihood algorithm, returning both deblurred image J and a restored
%   point-spread function PSF. The resulting PSF is a positive array of
%   the same size as the INITPSF, normalized so its sum adds to 1. The
%   PSF restoration is affected strongly by the size of its initial
%   guess, INITPSF, and less by its values (an array of ones is a safer
%   guess).
%   
%   I can be an N-Dimensional array.
%
%   To improve the restoration, additional parameters can be passed in
%   (use [] as a place holder if an intermediate parameter is unknown):
%   [J,PSF] = DECONVBLIND(I,INITPSF,NUMIT)
%   [J,PSF] = DECONVBLIND(I,INITPSF,NUMIT,DAMPAR)
%   [J,PSF] = DECONVBLIND(I,INITPSF,NUMIT,DAMPAR,WEIGHT)
%   [J,PSF] = DECONVBLIND(I,INITPSF,NUMIT,DAMPAR,WEIGHT,READOUT).
%
%   Additional constraints on PSF can be provided via a user supplied
%   function:
%   [J,PSF] = DECONVBLIND(...,FUN)
%
%   FUN (optional) is a function describing additional constraints on the
%   PSF. FUN must be a FUNCTION_HANDLE. FUN is called at the end of each
%   iteration. FUN must accept the PSF as its first argument and may accept
%   additional parameters, P1, P2, ..., PN. FUN should return one argument,
%   PSF, that is the same size as the INITPSF, and satisfies the positivity
%   and normalization constraints.
%
%   NUMIT   (optional) is the number of iterations (default is 10).
%
%   DAMPAR  (optional) is an array that specifies the threshold deviation
%   of the resulting image from the image I (in terms of the standard 
%   deviation of Poisson noise) below which the damping occurs. The 
%   iterations are suppressed for the pixels that deviate within the 
%   DAMPAR value from their original value. This suppresses the noise 
%   generation in such pixels, preserving necessary image details
%   elsewhere. Default is 0 (no damping).
%
%   WEIGHT  (optional) is assigned to each pixel to reflect its recording
%   quality in the camera. A bad pixel is excluded from the solution by
%   assigning it zero weight value. Instead of giving a weight of one for
%   good pixels, you can adjust their weight according to the amount of
%   flat-field correction. Default is a unit array of the same size as 
%   input image I.
%
%   READOUT (optional) is an array (or a value) corresponding to the
%   additive noise (e.g., background, foreground noise) and the variance 
%   of the read-out camera noise. READOUT has to be in the units of the
%   image. Default is 0.
%
%
%   Note that the output image J could exhibit ringing introduced by the
%   discrete Fourier transform used in the algorithm. To reduce the
%   ringing use I = EDGETAPER(I,PSF) prior to calling DECONVBLIND.
%
%   Note also that DECONVBLIND allows you to resume deconvolution
%   starting from the results of an earlier DECONVBLIND run. To initiate
%   this syntax, the input I and INITPSF have to be passed in as cell
%   arrays, {I} and {INITPSF}. Then the output J and PSF become cell
%   arrays and can be passed as the input arrays into the next
%   DECONVBLIND call. The input cell array can contain one numeric array
%   (on initial call), or four numeric arrays (when it is the output from
%   a previous run of DECONVBLIND). The output J contains four elements,
%   where J{1}=I, J{2} is the image resulted from the last iteration,
%   J{3} is the image from one before last iteration, J{4} is an array
%   used internally by the iterative algorithm.
%
%   Class Support
%   -------------
%   I and INITPSF can be uint8, uint16, int16, double, or single. DAMPAR and
%   READOUT must have the same class as the input image. Other inputs have to
%   be double. The output image J (or the first array of the output cell) has
%   the same class as the input image I. The output PSF is double.
%
%   Example
%   -------
%      
%      I = checkerboard(8);
%      PSF = fspecial('gaussian',7,10);
%      V = .0001;
%      BlurredNoisy = imnoise(imfilter(I,PSF),'gaussian',0,V);
%      WT = zeros(size(I));WT(5:end-4,5:end-4) = 1;
%      INITPSF = ones(size(PSF));
%      [J P] = deconvblind(BlurredNoisy,INITPSF,20,10*sqrt(V),WT);
%      subplot(221);imshow(BlurredNoisy);
%                     title('A = Blurred and Noisy');
%      subplot(222);imshow(PSF,[]);
%                     title('True PSF');
%      subplot(223);imshow(J);
%                     title('Deblurred Image');
%      subplot(224);imshow(P,[]);
%                     title('Recovered PSF');
%
%   See also DECONVWNR, DECONVREG, DECONVLUCY, EDGETAPER,
%            FUNCTION_HANDLE, IMNOISE, PADARRAY, PSF2OTF, OTF2PSF.

%   Copyright 1993-2017 The MathWorks, Inc.

%

%   References
%   ----------
%   "Acceleration of iterative image restoration algorithms, by D.S.C. Biggs 
%   and M. Andrews, Applied Optics, Vol. 36, No. 8, 1997.
%   "Deconvolutions of Hubble Space Telescope Images and Spectra",
%   R.J. Hanisch, R.L. White, and R.L. Gilliland. in "Deconvolution of Images 
%   and Spectra", Ed. P.A. Jansson, 2nd ed., Academic Press, CA, 1997.
%   "Light Microscopic Images Reconstructed by Maximum Likelihood
%   Deconvolution", Timothy J. Holmes et al. in "Handbook of 
%   Biological Confocal Microscopy", Ed. James B. Pawley, Plenum
%   Press, New York, 1995

% Obsolete syntax:
%
%   Additional constraints on PSF can be provided via a user supplied
%   function:
%   [J,PSF] = DECONVBLIND(...,FUN,P1,P2,...,PN)

% Parse inputs to verify valid function calling syntaxes and arguments
args = matlab.images.internal.stringToChar(varargin);
[J,P,NUMIT,DAMPAR,READOUT,WEIGHT,sizeI,classI,sizePSF,FunFcn,FunArg] = ...
    parse_inputs(args{:});

% 1. Prepare parameters for iterations
%
% Create indexes for image according to the sampling rate
idx = repmat({':'},[1 length(sizeI)]);

wI = max(WEIGHT.*(READOUT + J{1}),0);% at this point  - positivity constraint
fw = fftn(WEIGHT);
clear WEIGHT;
DAMPAR22 = (DAMPAR.^2)/2;

% 2. L_R Iterations
%
lambda = 2*any(J{4}(:)~=0);
for k = (lambda + 1) : (lambda + NUMIT),
    
  % 2.a Make an image and PSF predictions for the next iteration    
  if k > 2,% image
    lambda = (J{4}(:,1).'*J{4}(:,2))/(J{4}(:,2).'*J{4}(:,2) + eps);
    lambda = max(min(lambda,1),0);% stability enforcement
  end
  Y = max(J{2} + lambda*(J{2} - J{3}),0);% image positivity constraint
  
  if k > 2,% PSF
    lambda = (P{4}(:,1).'*P{4}(:,2))/(P{4}(:,2).'*P{4}(:,2) + eps);
    lambda = max(min(lambda,1),0);% stability enforcement
  end
  B = max(P{2} + lambda*(P{2} - P{3}),0);% PSF positivity constraint
  sumPSF = sum(B(:));
  B = B/(sum(B(:)) + (sumPSF==0)*eps);% normalization is a necessary constraint, 
  % because given only input image, the algorithm cannot even know how much
  % power is in the image vs PSF. Therefore, we force PSF to satisfy this 
  % type of normalization: sum to one.
  
  % 2.b  Make core for the LR estimation
  CC = corelucy(Y,psf2otf(B,sizeI),DAMPAR22,wI,READOUT,1,idx,[],[]);
  
  % 2.c Determine next iteration image & apply positivity constraint
  J{3} = J{2};
  H = psf2otf(P{2},sizeI);
  scale = real(ifftn(conj(H).*fw)) + sqrt(eps);
  J{2} = max(Y.*real(ifftn(conj(H).*CC))./scale,0);
  clear scale;
  J{4} = [J{2}(:)-Y(:) J{4}(:,1)];
  clear Y H;
  
  % 2.d Determine next iteration PSF & apply positivity constraint + normalization
  P{3} = P{2};
  H = fftn(J{3});
  scale = otf2psf(conj(H).*fw,sizePSF) + sqrt(eps);
  P{2} = max(B.*otf2psf(conj(H).*CC,sizePSF)./scale,0);
  clear CC H;
  
  sumPSF = sum(P{2}(:));
  P{2} = P{2}/(sumPSF + (sumPSF==0)*eps);
  
  if ~isempty(FunFcn),
    FunArg{1} = P{2};
    P{2} = feval(FunFcn,FunArg{:});
  end;
  P{4} = [P{2}(:)-B(:) P{4}(:,1)];
end
clear fw wI;

% 3. Convert the right array (for cell it is first array, for notcell it is
% second array) to the original image class & output the whole thing
num = 1 + strcmp(classI{1},'notcell');
if ~strcmp(classI{2},'double'),
  J{num} = images.internal.changeClass(classI{2},J{num});
end

if num == 2,% the input & output is NOT a cell
  P = P{2};
  J = J{2};
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Function: parse_inputs 
function [J,P,NUMIT,DAMPAR,READOUT,WEIGHT,sizeI,classI,sizePSF,FunFcn,FunArg] ...
      = parse_inputs(varargin)
%
% Outputs:
% I=J{1}   the input array (could be any numeric class, 2D, 3D)
% P=P{1}   the operator that distorts the ideal image
%
% Defaults:
%
NUMIT=[];NUMIT_d = 10;  % Number of  iterations, usually produces good
                        % result by 10.
DAMPAR =[];DAMPAR_d = 0;% No damping is default
WEIGHT =[];             % All pixels are of equal quality, flat-field is one
READOUT=[];READOUT_d= 0;% Zero readout noise or any other
           % back/fore/ground noise associated with CCD camera.
           % Or the Image is corrected already for this noise by user.
FunFcn = '';FunFcn_d = '';
FunArg = {};FunArg_d = {};
funnum = [];funnum_d = nargin+1;

narginchk(2,inf);% no constraint on max number 
                                       % because of FUN args

% First, assign the inputs starting with the cell/not cell image & PSF
%
switch iscell(varargin{1}) + iscell(varargin{2}),  
case 0, % no-cell array is used to do a single set of iterations
  classI{1} = 'notcell';  
  J{1} = varargin{1};% create a cell array in order to do the iterations
  P{1} = varargin{2};
case 1,
  error(message('images:deconvblind:IandInitpsfMustBeOfSameType'))
case 2,% input cell is used to resume the interrupted iterations or 
  classI{1} = 'cell';% to interrupt the iteration to resume them later
  J = varargin{1};
  P = varargin{2};
  if length(J)~=length(P),
    error(message('images:deconvblind:IandInitpsfMustBeOfSameSize'))
  end
end;

% check the Image, which is the first array of the J-cell
[sizeI, sizePSF] = padlength(size(J{1}), size(P{1}));
classI{2} = class(J{1});

validateattributes(J{1},{'uint8' 'uint16' 'double' 'int16' 'single'},...
              {'real' 'nonempty' 'finite'},mfilename,'I',1);

if prod(sizeI)<2,
  error(message('images:deconvblind:inputImageMustHaveAtLeast2Elements'))
elseif ~isa(J{1},'double'),
  J{1} = im2double(J{1});
end

% check the PSF, which is the first array of the P-cell
validateattributes(P{1},{'uint8' 'uint16' 'double' 'int16' 'single'},...
              {'real' 'nonempty' 'finite'},mfilename,'INITPSF',2);

if(all(P{1}(:) == 0))
   error(message('images:deconvblind:initPSFMustHaveAtLeastOneNonZeroElement')) 
end
          
if prod(sizePSF)<2,
  error(message('images:deconvblind:initPSFMustHaveAtLeast2Elements'))
elseif ~isa(P{1},'double'),
  P{1} = double(P{1});
end

% now since the image&PSF are OK&double, we assign the rest of the J & P cells
len = length(J);
if len == 1,% J = {I} will be reassigned to J = {I,I,0,0}
  J{2} = J{1};
  J{3} = 0;
  J{4}(prod(sizeI),2) = 0;
  P{2} = P{1};
  P{3} = 0;
  P{4}(prod(sizePSF),2) = 0;
elseif len ~= 4,% J = {I,J,Jm1,gk} has to have 4 or 1 arrays
  error(message('images:deconvblind:inputCellsMustBe1or4ElementNumArrays'))
else % check if J,Jm1,gk are double in the input cell
  if ~all([isa(J{2},'double'),isa(J{3},'double'),isa(J{4},'double')]),
      error(message('images:deconvblind:ImageCellElementsMustBeDouble'))
  elseif ~all([isa(P{2},'double'),isa(P{3},'double'),isa(P{4},'double')]),
      error(message('images:deconvblind:psfCellElementsMustBeDouble'))
  end
end; 

% Second, Find out if we have a function to put additional constraints on the PSF
%

function_classes = {'inline','function_handle','char'};
idx = [];
for n = 3:nargin,
  idx = strmatch(class(varargin{n}),function_classes);
  if ~isempty(idx),
    [FunFcn,msgStruct] = fcnchk(varargin{n}); %only works on char, making it inline
    if ~isempty(msgStruct)
	error(msgStruct)
    end
    FunArg = [{0},varargin(n+1:nargin)];
    try % how this function works, just in case.
      feval(FunFcn,FunArg{:});
    catch ME
      Ftype = {'inline object','function_handle','expression ==>'};
      Ffcnstr = {' ',' ',varargin{n}};
      error(message('images:deconvblind:userSuppliedFcnFailed', Ftype{ idx }, Ffcnstr{ idx }, ME.message))
    end
    funnum = n;
    break
  end
end

if isempty(idx),
  FunFcn = FunFcn_d;
  FunArg = FunArg_d;
  funnum = funnum_d;
end

%
% Third, Assign the inputs for general deconvolution:
%
if funnum>7
    error(message('images:validate:tooManyInputs',mfilename));
end

switch funnum,
case 4,%                      deconvblind(I,PSF,NUMIT,fun,...)
  NUMIT = varargin{3};
case 5,%                 deconvblind(I,PSF,NUMIT,DAMPAR,fun,...)
  NUMIT = varargin{3};
  DAMPAR = varargin{4};
case 6,%                 deconvblind(I,PSF,NUMIT,DAMPAR,WEIGHT,fun,...)
  NUMIT = varargin{3};
  DAMPAR = varargin{4};
  WEIGHT = varargin{5};
case 7,%                 deconvblind(I,PSF,NUMIT,DAMPAR,WEIGHT,READOUT,fun,...)
  NUMIT = varargin{3};
  DAMPAR = varargin{4};
  WEIGHT = varargin{5};
  READOUT = varargin{6};
end

% Forth, Check validity of the gen.conv. input parameters: 
%
% NUMIT check number of iterations
if isempty(NUMIT),
  NUMIT = NUMIT_d;
else  %verify validity
    validateattributes(NUMIT,{'double'},...
                  {'scalar' 'positive' 'integer' 'finite'},...
                  mfilename,'NUMIT',3);
end

% DAMPAR check damping parameter
if isempty(DAMPAR),
  DAMPAR = DAMPAR_d;
elseif (numel(DAMPAR)~=1) && ~isequal(size(DAMPAR),sizeI),
  error(message('images:deconvblind:damparMustBeSizeOfInputImage'));
elseif ~isa(DAMPAR,classI{2}),
  error(message('images:deconvblind:damparMustBeSameClassAsInputImage'));
elseif ~strcmp(classI{2},'double'),
  DAMPAR = im2double(DAMPAR);
end    

if ~isfinite(DAMPAR),
  error(message('images:deconvblind:damparMustBeFinite'));
end

% WEIGHT check weighting
if isempty(WEIGHT),
    WEIGHT = ones(sizeI);
else
    numw = numel(WEIGHT);
    validateattributes(WEIGHT,{'double'},{'finite'},mfilename,'WEIGHT',5);
    if (numw ~= 1) && ~isequal(size(WEIGHT),sizeI),
        error(message('images:deconvblind:weightMustBeSizeOfInputImage'));
    elseif numw == 1,
        WEIGHT = repmat(WEIGHT,sizeI);
    end;
end

% READOUT check read-out noise
if isempty(READOUT),
  READOUT = READOUT_d;
elseif (numel(READOUT)~=1) && ~isequal(size(READOUT),sizeI),
  error(message('images:deconvblind:readoutMustBeSizeOfInputImage'));
elseif ~isa(READOUT,classI{2}),
  error(message('images:deconvblind:readoutMustBeSameClassAsInputImage'));
elseif ~strcmp(classI{2},'double'),
  READOUT = im2double(READOUT);
end
if ~isfinite(READOUT),
  error(message('images:deconvblind:readoutMustBeFinite'));
end;
