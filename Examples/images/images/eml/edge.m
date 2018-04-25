function varargout = edge(varargin) %#codegen
%EDGE Find edges in intensity image.

% Copyright 2013-2017 The MathWorks, Inc.

narginchk(1,5);
coder.internal.prefer_const(varargin);

% Shared library
singleThread = images.internal.coder.useSingleThread();
coder.extrinsic('images.internal.coder.useSharedLibrary');
useSharedLibrary = coder.const(images.internal.coder.isCodegenForHost()) && ...
    coder.const(images.internal.coder.useSharedLibrary()) && ...
    coder.const(~singleThread);

coder.internal.errorIf(nargout>2,'images:edge:tooManyOutputs');

in = varargin{1};
validateattributes(in,{'numeric','logical'},{'real','nonsparse','2d'},mfilename,'I',1); %#ok<*EMCA>

if nargin>1
    eml_invariant(ischar(varargin{2}),eml_message('images:edge:invalidSecondArgument'));
    methodStr = validatestring(varargin{2},{'canny','sobel','prewitt','roberts','log','zerocross'},mfilename,'METHOD',2);

    method = enumMethod(methodStr);
    
    if method==SOBEL || method==PREWITT || method==ROBERTS
        %this codepath does not need sigma or H.
        [direction,thinning,thresh,threshFlag] = parseGradientOperatorMethods(varargin{3:end});
        if direction==BOTH
            kx = 1; ky = 1;
        elseif direction==HORIZONTAL
            kx = 0; ky = 1;
        else%if direction==VERTICAL
            kx = 1; ky = 0;
        end
    elseif method==LOG
        %this codepath does not need direction,thinning or H.
        H = [];
        [thresh,threshFlag,sigma] = parseLaplacianOfGaussianMethod(varargin{3:end});
    elseif method==ZEROCROSS
        %this codepath does not need direction,thinning or sigma.
        sigma = 2;
        [thresh,threshFlag,H] = parseZeroCrossingMethod(varargin{3:end});
    else%if method==CANNY
        %this codepath does not need direction,thinning or H.
        [thresh,threshFlag,sigma] = parseCannyMethod(varargin{3:end});
    end    
else
    %these are the defaults.
    method     = SOBEL;
    thinning   = true;
    thresh     = 0;
    threshFlag = 0;
    H          = [];
    sigma      = 2;
    kx         = 1;
    ky         = 1;
end

% Transform to a double precision intensity image if necessary
isPrewittOrSobel = (method==SOBEL || method==PREWITT);

% Row-major codegen uses shared library codepath only for Sobel and Prewitt
useSharedLibrary = useSharedLibrary && ...
    (~(coder.isRowMajor && ~isPrewittOrSobel));

if (~isPrewittOrSobel || ~useSharedLibrary) && ~isfloat(in)
    a = im2single(in);
else
    a = in;
end

if isempty(a)
    varargout{1}  = false(size(a));
    if nargout==2
        if nargin == 2
            if method==CANNY
                varargout{2} = coder.internal.nan(1,2);
            else
                varargout{2} = coder.internal.nan(1);
            end
        else
            if method==CANNY
                varargout{2} = thresh;
            else
                varargout{2} = thresh(1);
            end
        end
    end
    return;
end

[m,n] = size(a);

if method == CANNY
    % Magic numbers
    PercentOfPixelsNotEdges = .7; % Used for selecting thresholds
    ThresholdRatio = .4;          % Low thresh is this fraction of the high.
    
    % Calculate gradients using a derivative of Gaussian filter
    [dx, dy] = smoothGradient(a, sigma);
    
    % Calculate Magnitude of Gradient
    magGrad = hypot(dx, dy);
    
    % Normalize for threshold selection
    magmax = max(magGrad(:),[],1);
    if magmax > 0
        magGrad = magGrad / magmax;
    end
    
    % Determine Hysteresis Thresholds
    [lowThresh, highThresh] = selectThresholds(thresh, threshFlag, magGrad, PercentOfPixelsNotEdges, ThresholdRatio, mfilename);
    
    % Perform Non-Maximum Suppression Thining and Hysteresis Thresholding of Edge
    % Strength
    e = false(m,n);
    if ~isvector(e)
        e = thinAndThreshold(e, dx, dy, magGrad, lowThresh, highThresh, useSharedLibrary);
    end
    
    thresh(1) = lowThresh(1);
    thresh(2) = highThresh(1);
    
elseif method == LOG || method == ZEROCROSS
    if isempty(H)
        fsize = ceil(sigma*3) * 2 + 1;  % choose an odd fsize > 6*sigma;
        op = fspecial('log',fsize,sigma);
    else
        op = H;
    end
    
    op = op - sum(op(:))/numel(op); % make the op to sum to zero
    b = imfilter(a,op,'replicate');
    
    if threshFlag==0
        thresh = [0.75 * sum(abs(b(:)),'double') / numel(b) 0];
    end
    
    e = false(m,n);
    parfor cc = 2 : n-1
        for rr = 2 : m-1
            b_up     = b(rr-1,cc  );
            b_down   = b(rr+1,cc  );
            b_left   = b(rr  ,cc-1);
            b_right  = b(rr  ,cc+1);
            b_center = b(rr  ,cc  );
            if b_center ~= 0
                % Look for the zero crossings:  +-, -+ and their transposes
                % We arbitrarily choose the edge to be the negative point
                zc1 = b_center<0 && b_right >0 && abs(b_center-b_right )>thresh(1);
                zc2 = b_left  >0 && b_center<0 && abs(b_left  -b_center)>thresh(1);
                zc3 = b_center<0 && b_down  >0 && abs(b_center-b_down  )>thresh(1);
                zc4 = b_up    >0 && b_center<0 && abs(b_up    -b_center)>thresh(1);
            else
                % Look for the zero crossings: +0-, -0+ and their transposes
                % The edge lies on the Zero point
                zc1 = b_up    <0 && b_down  >0 && abs(b_up    -b_down )>2*thresh(1);
                zc2 = b_up    >0 && b_down  <0 && abs(b_up    -b_down )>2*thresh(1);
                zc3 = b_left  <0 && b_right >0 && abs(b_left  -b_right)>2*thresh(1);
                zc4 = b_left  >0 && b_right <0 && abs(b_left  -b_right)>2*thresh(1);
            end
            e(rr,cc) = zc1 || zc2 || zc3 || zc4;
        end
    end
    
else%if method==SOBEL || method==PREWITT || method==ROBERTS
    if isPrewittOrSobel 
        isSobel = (method == SOBEL);
        scale  = 4;
        offset = int8([0 0 0 0]);
        
        if(useSharedLibrary)
            [bx, by, b] = computeEdgeSobelPrewittLibrary(a,isSobel,kx,ky);
        else
            [bx, by, b] = computeEdgeSobelPrewittPortable(a,isSobel,kx,ky);
        end
        
        
    elseif method==ROBERTS
        x_mask = [1 0; 0 -1]/2; % Roberts approximation to diagonal derivative
        y_mask = [0 1;-1  0]/2;
        
        scale  = 6;
        offset = int8([-1 1 1 -1]);
        
        % compute the gradient in x and y direction
        bx = imfilter(a,x_mask,'replicate');
        by = imfilter(a,y_mask,'replicate');
        
        % compute the magnitude
        b = kx*bx.*bx + ky*by.*by;
        
    else
        eml_invariant(false,...
            eml_message('images:edge:invalidEdgeDetectionMethod', method),...
            'IfNotConst','Fail');
    end
    
    
    % Determine the threshold; see page 514 of 
    % "Digital Imaging Processing" by William K. Pratt
    if threshFlag==0 % Determine cutoff based on RMS estimate of noise
        % Mean of the magnitude squared image is a
        % value that's roughly proportional to SNR
        cutoff =  scale * sum(b(:),'double') / numel(b);
        thresh(1) = sqrt(cutoff);
    else
        % Use relative tolerance specified by the user
        cutoff = (thresh(1)).^2;
    end
    
    e = coder.nullcopy(false(m,n));

    if thinning
        if(useSharedLibrary)
            e = computeEdgesWithThinningLibrary(b,bx,by,kx,ky,offset,cutoff,e);
        else
            e = computeEdgesWithThinningPortable(b,bx,by,kx,ky,offset,cutoff,e);
        end
    else
        e = b > cutoff;
    end
end

varargout{1} = e;

if nargout==2
    if method==CANNY
        varargout{2} = thresh;
    else
        varargout{2} = thresh(1);
    end
end

%Parse input arguments for 'log'.
function [thresh,threshFlag,sigma] = parseLaplacianOfGaussianMethod(varargin)
coder.inline('always');
coder.internal.prefer_const(varargin);
narginchk(0,2);
if nargin==0
    %edge(im,method)
    thresh     = [0 0];
    threshFlag = 0;
    sigma      = 2;
elseif nargin==1
    %edge(im,method,thresh)
    validateattributes(varargin{1},...
        {'numeric','logical'},{},...
        mfilename,'THRESH',3);
    eml_invariant(numel(varargin{1})<=1,...
        eml_message('images:edge:invalidInputArguments'),...
        'IfNotConst','Fail');
    if isempty(varargin{1})
        thresh     = [0 0];
        threshFlag = 0;
    else
        thresh     = [varargin{1} 0];
        threshFlag = 1;
    end
    sigma      = 2;
else%if nargin==2
    %edge(im,method,thresh,sigma)
    validateattributes(varargin{1},...
        {'numeric','logical'},{},...
        mfilename,'THRESH',3);
    eml_invariant(numel(varargin{1})<=1,...
        eml_message('images:edge:invalidInputArguments'),...
        'IfNotConst','Fail');
    if isempty(varargin{1})
        thresh     = [0 0];
        threshFlag = 0;
    else
        thresh     = [varargin{1} 0];
        threshFlag = 1;
    end
    validateattributes(varargin{2},...
        {'numeric','logical'},{},...
        mfilename,'SIGMA',4);
    eml_invariant(numel(varargin{2})==1,...
        eml_message('images:edge:invalidInputArguments'),...
        'IfNotConst','Fail');
    sigma  = varargin{2};
end

%Parse input arguments for 'sobel','prewitt' or 'roberts'.
function [direction,thinning,thresh,threshFlag] = parseGradientOperatorMethods(varargin)
coder.inline('always');
coder.internal.prefer_const(varargin);

if nargin==0
    %edge(im,method)
    direction  = BOTH;
    thinning   = true;
    thresh     = 0;
    threshFlag = 0;
elseif nargin==1
    if ischar(varargin{1})
        %edge(im,method,direction)
        %edge(im,method,thinning)
        thresh     = [0 0];
        threshFlag = 0;
        if strcmp(varargin{1},'both')
            direction = BOTH;
            thinning  = true;
        elseif strcmp(varargin{1},'horizontal')
            direction = HORIZONTAL;
            thinning  = true;
        elseif strcmp(varargin{1},'vertical')
            direction = VERTICAL;
            thinning  = true;
        elseif strcmp(varargin{1},'thinning')
            direction = BOTH;
            thinning  = true;
        elseif strcmp(varargin{1},'nothinning')
            direction = BOTH;
            thinning  = false;
        else
            eml_invariant(false,...
                eml_message('images:edge:invalidInputArguments'),...
                'IfNotConst','Fail');
        end
    else
        %edge(im,method,thresh)
        validateattributes(varargin{1},...
            {'numeric','logical'},{},...
            mfilename,'THRESH',3);
        eml_invariant(numel(varargin{1})<=1,...
            eml_message('images:edge:invalidInputArguments'),...
            'IfNotConst','Fail');
        if isempty(varargin{1})
            thresh     = [0 0];
            threshFlag = 0;
        else
            thresh     = [varargin{1} 0];
            threshFlag = 1;
        end
        direction = BOTH;
        thinning  = true;
    end
elseif nargin==2
    if ischar(varargin{1})
        %edge(im,method,direction,__)
        thresh     = [0 0];
        threshFlag = 0;
        thinning   = true;
        if strcmp(varargin{1},'both')
            direction = BOTH;
        elseif strcmp(varargin{1},'horizontal')
            direction = HORIZONTAL;
        elseif strcmp(varargin{1},'vertical')
            direction = VERTICAL;
        else
            eml_invariant(false,...
                eml_message('images:edge:invalidInputArguments'),...
                'IfNotConst','Fail');
        end
    else
        %edge(im,method,thresh,__)
        validateattributes(varargin{1},...
            {'numeric','logical'},{},...
            mfilename,'THRESH',3);
        eml_invariant(numel(varargin{1})<=1,...
            eml_message('images:edge:invalidInputArguments'),...
            'IfNotConst','Fail');
        if isempty(varargin{1})
            thresh     = [0 0];
            threshFlag = 0;
        else
            thresh     = [varargin{1} 0];
            threshFlag = 1;
        end
        direction = BOTH;
    end
    
    eml_invariant(ischar(varargin{2}),...
        eml_message('images:edge:invalidInputArguments'),...
        'IfNotConst','Fail');
    if ischar(varargin{1})
        %edge(im,method,direction,thinning)
        %direction has been specified, this can only be a thinning string.
        if strcmp(varargin{2},'thinning')
            thinning = true;
        elseif strcmp(varargin{2},'nothinning')
            thinning = false;
        else
            eml_invariant(false,...
                eml_message('images:edge:invalidInputArguments'),...
                'IfNotConst','Fail');
        end
    else
        %direction has not been specified, so this can be a
        %direction/thinning string.
        %edge(im,method,thresh,direction)
        %edge(im,method,thresh,thinning)
        if strcmp(varargin{2},'horizontal')
            direction = HORIZONTAL;
            thinning  = true;
        elseif strcmp(varargin{2},'vertical')
            direction = VERTICAL;
            thinning  = true;
        elseif strcmp(varargin{2},'both')
            direction = BOTH;
            thinning  = true;
        elseif strcmp(varargin{2},'thinning')
            direction = BOTH;
            thinning  = true;
        elseif strcmp(varargin{2},'nothinning')
            direction = BOTH;
            thinning  = false;
        else
            eml_invariant(false,...
                eml_message('images:edge:invalidInputArguments'),...
                'IfNotConst','Fail');
        end
    end
    
elseif nargin==3
    %has to be thresh,direction,thinning
    %edge(im,method,thresh,direction,thinning)
    validateattributes(varargin{1},...
        {'numeric','logical'},{},...
        mfilename,'THRESH',3);
    eml_invariant(numel(varargin{1})<=1,...
        eml_message('images:edge:invalidInputArguments'),...
        'IfNotConst','Fail');
    if isempty(varargin{1})
        thresh     = [0 0];
        threshFlag = 0;
    else
        thresh     = [varargin{1} 0];
        threshFlag = 1;
    end
    
    eml_invariant(ischar(varargin{2}),...
        eml_message('images:edge:invalidInputArguments'),...
        'IfNotConst','Fail');
    if strcmp(varargin{2},'horizontal')
        direction = HORIZONTAL;
    elseif strcmp(varargin{2},'vertical')
        direction = VERTICAL;
    elseif strcmp(varargin{2},'both')
        direction = BOTH;
    else
        eml_invariant(false,...
            eml_message('images:edge:invalidInputArguments'),...
            'IfNotConst','Fail');
    end
    
    eml_invariant(ischar(varargin{3}),...
        eml_message('images:edge:invalidInputArguments'),...
        'IfNotConst','Fail');
    if strcmp(varargin{3},'thinning')
        thinning = true;
    elseif strcmp(varargin{3},'nothinning')
        thinning = false;
    else
        eml_invariant(false,...
            eml_message('images:edge:invalidInputArguments'),...
            'IfNotConst','Fail');
    end
end

%Parse input arguments for 'zerocrossing'.
function [thresh,threshFlag,H] = parseZeroCrossingMethod(varargin)
coder.inline('always');
coder.internal.prefer_const(varargin);
narginchk(0,2);
if nargin==0
    %edge(im,nethod)
    thresh     = [0 0];
    threshFlag = 0;
    H      = [];
elseif nargin==1
    if numel(varargin{1})>1
        %edge(im,method,H)
        validateattributes(varargin{1},...
            {'numeric','logical'},{},...
            mfilename,'H',3);
        
        thresh     = [0 0];
        threshFlag = 0;
        H          = varargin{1};
    else
        %edge(im,method,thresh)
        validateattributes(varargin{1},...
            {'numeric','logical'},{},...
            mfilename,'THRESH',3);
        if isempty(varargin{1})
            thresh     = [0 0];
            threshFlag = 0;
        else
            thresh     = [varargin{1} 0];
            threshFlag = 1;
        end
        H      = [];
    end
elseif nargin==2
    %edge(im,method,thresh,H)
    validateattributes(varargin{1},...
        {'numeric','logical'},{},...
        mfilename,'THRESH',3);
    eml_invariant(numel(varargin{1})<=1,...
        eml_message('images:edge:invalidInputArguments'),...
        'IfNotConst','Fail');
    if isempty(varargin{1})
        thresh     = [0 0];
        threshFlag = 0;
    else
        thresh     = [varargin{1} 0];
        threshFlag = 1;
    end
    
    validateattributes(varargin{2},...
        {'numeric','logical'},{},...
        mfilename,'H',4);
    eml_invariant(numel(varargin{2})>1,...
        eml_message('images:edge:invalidInputArguments'));
    H = varargin{2};
end

%Parse input arguments for 'canny'.
function [thresh,threshFlag,sigma] = parseCannyMethod(varargin)
coder.inline('always');
coder.internal.prefer_const(varargin);
narginchk(0,2);
if nargin==0
    %edge(im,method)
    thresh     = [0 0];
    threshFlag = 0;
    sigma      = sqrt(2);
elseif nargin==1
    %edge(im,method,thresh)
    validateattributes(varargin{1},...
        {'numeric','logical'},{},...
        mfilename,'THRESH',3);
    eml_invariant(numel(varargin{1})<=2,...
        eml_message('images:edge:invalidInputArguments'),...
        'IfNotConst','Fail');
    if isempty(varargin{1})
        thresh     = [0 0];
        threshFlag = 0;
    elseif numel(varargin{1})==1
        thresh     = [varargin{1} 0];
        threshFlag = 1;
    elseif numel(varargin{1})==2
        if ~isrow(varargin{1})
            threshCol = varargin{1};
            thresh    = [threshCol(1) threshCol(2)];
        else
            thresh     = varargin{1};
        end
        threshFlag = 2;
    end
    sigma = sqrt(2);
elseif nargin==2
    %edge(im,method,thresh,sigma)
    validateattributes(varargin{1},...
        {'numeric','logical'},{},...
        mfilename,'THRESH',3);
    eml_invariant(numel(varargin{1})<=2,...
        eml_message('images:edge:invalidInputArguments'),...
        'IfNotConst','Fail');
    if isempty(varargin{1})
        thresh     = [0 0];
        threshFlag = 0;
    elseif numel(varargin{1})==1
        thresh     = [varargin{1} 0];
        threshFlag = 1;
    elseif numel(varargin{1})==2
        if ~isrow(varargin{1})
            threshCol = varargin{1};
            thresh    = [threshCol(1) threshCol(2)];
        else
            thresh     = varargin{1};
        end
        threshFlag = 2;
    end
    validateattributes(varargin{2},...
        {'numeric','logical'},{},...
        mfilename,'SIGMA',4);
    eml_invariant(numel(varargin{2})==1,...
        eml_message('images:edge:invalidInputArguments'),...
        'IfNotConst','Fail');
    sigma  = varargin{2};
end

%Enumerate method strings.
function methodFlag = enumMethod(methodStr)
coder.inline('always');

if strcmp(methodStr,'canny')
    methodFlag = CANNY;
elseif strcmp(methodStr,'prewitt')
    methodFlag = PREWITT;
elseif strcmp(methodStr,'sobel')
    methodFlag = SOBEL;
elseif strcmp(methodStr,'log')
    methodFlag = LOG;
elseif strcmp(methodStr,'roberts')
    methodFlag = ROBERTS;
else %if strcmp(methodStr,'zerocross')
    methodFlag = ZEROCROSS;
end

%Enumeration functions for method strings and direction strings.
function methodFlag = CANNY()
coder.inline('always');
methodFlag = int8(1);

function methodFlag = PREWITT()
coder.inline('always');
methodFlag = int8(2);

function methodFlag = SOBEL()
coder.inline('always');
methodFlag = int8(3);

function methodFlag = LOG()
coder.inline('always');
methodFlag = int8(4);

function methodFlag = ROBERTS()
coder.inline('always');
methodFlag = int8(5);

function methodFlag = ZEROCROSS()
coder.inline('always');
methodFlag = int8(6);

function directionFlag = BOTH()
coder.inline('always');
directionFlag = int8(1);

function directionFlag = HORIZONTAL()
coder.inline('always');
directionFlag = int8(2);

function directionFlag = VERTICAL()
coder.inline('always');
directionFlag = int8(3);

%Method-specific sub-functions.
function [GX, GY] = smoothGradient(I, sigma)
coder.inline('always');
coder.internal.prefer_const(I,sigma);
% Create an even-length 1-D separable Derivative of Gaussian filter

% Determine filter length
filterExtent = ceil(4*sigma);
x = -filterExtent:filterExtent;

% Create 1-D Gaussian Kernel
c = 1/(sqrt(2*pi)*sigma);
gaussKernel = c * exp(-(x.^2)/(2*sigma^2));

% Normalize to ensure kernel sums to one
gaussKernel = gaussKernel/sum(gaussKernel);

% Create 1-D Derivative of Gaussian Kernel
derivGaussKernel = gradient(gaussKernel);

% Normalize to ensure kernel sums to zero
negVals = derivGaussKernel < 0;
posVals = derivGaussKernel > 0;
derivGaussKernel(posVals) = derivGaussKernel(posVals)/sum(derivGaussKernel(posVals));
derivGaussKernel(negVals) = derivGaussKernel(negVals)/abs(sum(derivGaussKernel(negVals)));

% Compute smoothed numerical gradient of image I along x (horizontal)
% direction. GX corresponds to dG/dx, where G is the Gaussian Smoothed
% version of image I.
GX = imfilter(I, gaussKernel', 'conv', 'replicate');
GX = imfilter(GX, derivGaussKernel, 'conv', 'replicate');

% Compute smoothed numerical gradient of image I along y (vertical)
% direction. GY corresponds to dG/dy, where G is the Gaussian Smoothed
% version of image I.
GY = imfilter(I, gaussKernel, 'conv', 'replicate');
GY  = imfilter(GY, derivGaussKernel', 'conv', 'replicate');

function [lowThresh, highThresh] = selectThresholds(thresh, threshFlag, magGrad, PercentOfPixelsNotEdges, ThresholdRatio, ~)
coder.inline('always');
coder.internal.prefer_const(thresh, threshFlag, magGrad, PercentOfPixelsNotEdges, ThresholdRatio);
[m,n] = size(magGrad);

% Select the thresholds
if threshFlag==0
    counts=imhist(magGrad, 64);
    highThreshTemp = find(cumsum(counts) > PercentOfPixelsNotEdges*m*n,...
        1,'first') / 64;
    if isempty(highThreshTemp)
        highThresh = zeros(0,1,'like',highThreshTemp);
        lowThresh = zeros(0,1,'like',highThreshTemp);
    else
        highThresh = highThreshTemp(1);
        lowThresh  = ThresholdRatio*highThresh;
    end
elseif threshFlag==1
    highThresh = thresh(1);
    eml_invariant(thresh(1)<1,eml_message('images:edge:thresholdMustBeLessThanOne'));
    lowThresh  = ThresholdRatio*thresh(1);
else%if threshFlag==2
    lowThresh  = thresh(1);
    highThresh = thresh(2);
    eml_invariant(lowThresh(1)<highThresh(1) && highThresh(1)<1,eml_message('images:edge:thresholdOutOfRange'));
end

function H = thinAndThreshold(E, dx, dy, magGrad, lowThresh, highThresh, useSharedLibrary)

% Perform Non-Maximum Suppression Thining and Hysteresis Thresholding of Edge
% Strength

% We will accrue indices which specify ON pixels in strong edgemap
% The array e will become the weak edge map.
[m, n] = size(E);
if(useSharedLibrary)
    E = cannyFindLocalMaximaLibrary(E,dx,dy,magGrad,[m, n],lowThresh(1)); % lowThresh(1) to ensure scalar double.
else
    E = cannyFindLocalMaximaPortable(E,dx,dy,magGrad,lowThresh);
end

[idxStrongR,idxStrongC] = find(magGrad>highThresh(1) & E);

if ~isempty(idxStrongC)
    H = bwselect(E, idxStrongC, idxStrongR, 8);
else
    H = false(m, n);
end

function E = cannyFindLocalMaximaPortable(E,ix,iy,mag,lowThresh)
%
% This sub-function helps with the non-maximum suppression in the Canny
% edge detector.
%

[m,n] = size(mag);

if coder.isColumnMajor
    parfor c = 2 : n-1
        for r = 2 : m-1
            ixval       = ix(r,c);
            iyval       = iy(r,c);
            gradmagval  = mag(r,c);
            
            if (iyval<=0 && ixval>-iyval) || (iyval>=0 && ixval<-iyval)
                dval        = abs(iyval/ixval);
                gradmagval1 = mag(r,c+1)*(1-dval) + mag(r-1,c+1)*dval;
                gradmagval2 = mag(r,c-1)*(1-dval) + mag(r+1,c-1)*dval;
                if gradmagval>=gradmagval1 && gradmagval>=gradmagval2 && ~isempty(lowThresh) && gradmagval>lowThresh(1)
                    E(r,c) = true;
                end
            end
            if (ixval>0 && -iyval>=ixval)  || (ixval<0 && -iyval<=ixval)
                dval        = abs(ixval/iyval);
                gradmagval1 = mag(r-1,c)*(1-dval) + mag(r-1,c+1)*dval;
                gradmagval2 = mag(r+1,c)*(1-dval) + mag(r+1,c-1)*dval;
                if gradmagval>=gradmagval1 && gradmagval>=gradmagval2 && ~isempty(lowThresh) && gradmagval>lowThresh(1)
                    E(r,c) = true;
                end
            end
            if (ixval<=0 && ixval>iyval) || (ixval>=0 && ixval<iyval)
                dval        = abs(ixval/iyval);
                gradmagval1 = mag(r-1,c)*(1-dval) + mag(r-1,c-1)*dval;
                gradmagval2 = mag(r+1,c)*(1-dval) + mag(r+1,c+1)*dval;
                if gradmagval>=gradmagval1 && gradmagval>=gradmagval2 && ~isempty(lowThresh) && gradmagval>lowThresh(1)
                    E(r,c) = true;
                end
            end
            if (iyval<0 && ixval<=iyval)  || (iyval>0 && ixval>=iyval)
                dval        = abs(iyval/ixval);
                gradmagval1 = mag(r,c-1)*(1-dval) + mag(r-1,c-1)*dval;
                gradmagval2 = mag(r,c+1)*(1-dval) + mag(r+1,c+1)*dval;
                if gradmagval>=gradmagval1 && gradmagval>=gradmagval2 && ~isempty(lowThresh) && gradmagval>lowThresh(1)
                    E(r,c) = true;
                end
            end
        end
    end
else
    parfor  r = 2 : m-1
        for c = 2 : n-1
            ixval       = ix(r,c);
            iyval       = iy(r,c);
            gradmagval  = mag(r,c);
            
            if (iyval<=0 && ixval>-iyval) || (iyval>=0 && ixval<-iyval)
                dval        = abs(iyval/ixval);
                gradmagval1 = mag(r,c+1)*(1-dval) + mag(r-1,c+1)*dval;
                gradmagval2 = mag(r,c-1)*(1-dval) + mag(r+1,c-1)*dval;
                if gradmagval>=gradmagval1 && gradmagval>=gradmagval2 && ~isempty(lowThresh) && gradmagval>lowThresh(1)
                    E(r,c) = true;
                end
            end
            if (ixval>0 && -iyval>=ixval)  || (ixval<0 && -iyval<=ixval)
                dval        = abs(ixval/iyval);
                gradmagval1 = mag(r-1,c)*(1-dval) + mag(r-1,c+1)*dval;
                gradmagval2 = mag(r+1,c)*(1-dval) + mag(r+1,c-1)*dval;
                if gradmagval>=gradmagval1 && gradmagval>=gradmagval2 && ~isempty(lowThresh) && gradmagval>lowThresh(1)
                    E(r,c) = true;
                end
            end
            if (ixval<=0 && ixval>iyval) || (ixval>=0 && ixval<iyval)
                dval        = abs(ixval/iyval);
                gradmagval1 = mag(r-1,c)*(1-dval) + mag(r-1,c-1)*dval;
                gradmagval2 = mag(r+1,c)*(1-dval) + mag(r+1,c+1)*dval;
                if gradmagval>=gradmagval1 && gradmagval>=gradmagval2 && ~isempty(lowThresh) && gradmagval>lowThresh(1)
                    E(r,c) = true;
                end
            end
            if (iyval<0 && ixval<=iyval)  || (iyval>0 && ixval>=iyval)
                dval        = abs(iyval/ixval);
                gradmagval1 = mag(r,c-1)*(1-dval) + mag(r-1,c-1)*dval;
                gradmagval2 = mag(r,c+1)*(1-dval) + mag(r+1,c+1)*dval;
                if gradmagval>=gradmagval1 && gradmagval>=gradmagval2 && ~isempty(lowThresh) && gradmagval>lowThresh(1)
                    E(r,c) = true;
                end
            end
        end
    end
end

function E = cannyFindLocalMaximaLibrary(E,ix,iy,mag,sz,lowThresh)
% This subfunction calculates local maxima using a shared
% library

coder.inline('always');
coder.internal.prefer_const(ix,iy,mag,lowThresh);

fcnName = ['cannythresholding_',images.internal.coder.getCtype(ix),'_tbb'];
E = images.internal.coder.buildable.CannyThresholdingTbbBuildable.cannythresholding_tbb(...
    fcnName,...
    ix,...
    iy,...
    mag,...
    sz,...
    lowThresh,...
    E);

function e = computeEdgesWithThinningPortable(b,bx,by,kx,ky,offset,cutoff,e)
% This subfunction computes edges using edge thinning for portable code

coder.inline('always');
coder.internal.prefer_const(b,bx,by,kx,ky,offset,cutoff,e);

bx = abs(bx);
by = abs(by);

m = size(e,1);
n = size(e,2);

offset = coder.internal.indexInt(offset);

% compute the output image
if coder.isColumnMajor
    parfor c=1:coder.internal.indexInt(n)
        for r=1:coder.internal.indexInt(m)
           % make sure that we don't go beyond the border
            
            if (r+offset(1) < 1) || (r+offset(1) > m) || ((c-1) < 1)
                b1 = true;
            else
                b1 = (b(r+offset(1),c-1) <= b(r,c));
            end
            
            if (r+offset(2) < 1) || (r+offset(2) > m) || ((c+1) > n)
                b2 = true;
            else
                b2 = (b(r,c) > b(r+offset(2),c+1));
            end
            
            if (c+offset(3) < 1) || (c+offset(3) > n) || ((r-1) < 1)
                b3 = true;
            else
                b3 = (b(r-1,c+offset(3)) <= b(r,c));
            end
            
            if (c+offset(4) < 1) || (c+offset(4) > n) || ((r+1) > m)
                b4 = true;
            else
                b4 = (b(r,c) > b(r+1,c+offset(4)));
            end
            
            e(r,c) = (b(r,c)>cutoff) & ...
                (((bx(r,c) >= (kx*by(r,c)-eps*100)) & b1 & b2) | ...
                ((by(r,c) >= (ky*bx(r,c)-eps*100)) & b3 & b4 ));
        end
    end
else
    parfor r=1:coder.internal.indexInt(m)
        for c=1:coder.internal.indexInt(n)
            % make sure that we don't go beyond the border
            
            if (r+offset(1) < 1) || (r+offset(1) > m) || ((c-1) < 1)
                b1 = true;
            else
                b1 = (b(r+offset(1),c-1) <= b(r,c));
            end
            
            if (r+offset(2) < 1) || (r+offset(2) > m) || ((c+1) > n)
                b2 = true;
            else
                b2 = (b(r,c) > b(r+offset(2),c+1));
            end
            
            if (c+offset(3) < 1) || (c+offset(3) > n) || ((r-1) < 1)
                b3 = true;
            else
                b3 = (b(r-1,c+offset(3)) <= b(r,c));
            end
            
            if (c+offset(4) < 1) || (c+offset(4) > n) || ((r+1) > m)
                b4 = true;
            else
                b4 = (b(r,c) > b(r+1,c+offset(4)));
            end
            
            e(r,c) = (b(r,c)>cutoff) & ...
                (((bx(r,c) >= (kx*by(r,c)-eps*100)) & b1 & b2) | ...
                ((by(r,c) >= (ky*bx(r,c)-eps*100)) & b3 & b4 ));
        end
    end
end

function e = computeEdgesWithThinningLibrary(b,bx,by,kx,ky,offset,cutoff,e)
% This subfunction computes edges using edge thinning using a shared
% library

coder.inline('always');
coder.internal.prefer_const(b,bx,by,kx,ky,offset,cutoff,e);

sz     = size(b);
epsval = 100*eps;

fcnName = ['edgethinning_',images.internal.coder.getCtype(b),'_tbb'];
e = images.internal.coder.buildable.EdgeThinningTbbBuildable.edgethinning_tbb(...
    fcnName,...
    b,...
    bx,...
    by,...
    kx,...
    ky,...
    offset,...
    epsval,...
    cutoff,...
    e,...
    sz);


function [bx, by, b] = computeEdgeSobelPrewittLibrary(a,isSobel,kx,ky)
% This subfunction computes sobel and prewitt edges using a shared
% library

coder.inline('always');

sz     = size(a);
        
if isfloat(a)
    bx = coder.nullcopy(zeros(sz,'like', a));
    by = coder.nullcopy(zeros(sz,'like', a));
    b  = coder.nullcopy(zeros(sz,'like', a));
else
    bx = coder.nullcopy(zeros(sz,'single'));
    by = coder.nullcopy(zeros(sz,'single'));
    b  = coder.nullcopy(zeros(sz,'single'));
end

fcnName = ['edgesobelprewitt_',images.internal.coder.getCtype(a),'_tbb'];
[bx, by, b] = images.internal.coder.buildable.EdgeSobelPrewittTbbBuildable.edgesobelprewitt_tbb(...
    fcnName,...
    a,...
    sz,...
    isSobel,...
    kx,...
    ky,...
    bx,...
    by,...
    b);


function [bx, by, b] = computeEdgeSobelPrewittPortable(a,isSobel,kx,ky)
% This subfunction computes sobel and prewitt edges which is used for
% portable code generation

coder.inline('always');

if isSobel
    op = fspecial('sobel')/8; % Sobel approximation to derivative
    x_mask = op'; % gradient in the X direction
    y_mask = op;
    
else
    op = fspecial('prewitt')/6; % Prewitt approximation to derivative
    x_mask = op';
    y_mask = op;
end

% compute the gradient in x and y direction
bx = imfilter(a,x_mask,'replicate');
by = imfilter(a,y_mask,'replicate');

% compute the magnitude
b = kx*bx.*bx + ky*by.*by;
