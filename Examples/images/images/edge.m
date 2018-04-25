function [eout,thresh,gv_45,gh_135] = edge(varargin)
%EDGE Find edges in intensity image.
%   EDGE takes an intensity or a binary image I as its input, and returns a
%   binary image BW of the same size as I, with 1's where the function
%   finds edges in I and 0's elsewhere.
%
%   EDGE supports six different edge-finding methods:
%
%      The Sobel method finds edges using the Sobel approximation to the
%      derivative. It returns edges at those points where the gradient of
%      I is maximum.
%
%      The Prewitt method finds edges using the Prewitt approximation to
%      the derivative. It returns edges at those points where the gradient
%      of I is maximum.
%
%      The Roberts method finds edges using the Roberts approximation to
%      the derivative. It returns edges at those points where the gradient
%      of I is maximum.
%
%      The Laplacian of Gaussian method finds edges by looking for zero
%      crossings after filtering I with a Laplacian of Gaussian filter.
%
%      The zero-cross method finds edges by looking for zero crossings
%      after filtering I with a filter you specify.
%
%      The Canny method finds edges by looking for local maxima of the
%      gradient of I. The gradient is calculated using the derivative of a
%      Gaussian filter. The method uses two thresholds, to detect strong
%      and weak edges, and includes the weak edges in the output only if
%      they are connected to strong edges. This method is therefore less
%      likely than the others to be "fooled" by noise, and more likely to
%      detect true weak edges.
%      
%      The 'approxcanny' method is an approximate version of the canny edge
%      detection algorithm that provides faster execution time at the
%      expense of less precise detection.
%
%   The parameters you can supply differ depending on the method you
%   specify. If you do not specify a method, EDGE uses the Sobel method.
%
%   Sobel Method
%   ------------
%   BW = EDGE(I,'sobel') specifies the Sobel method.
%
%   BW = EDGE(I,'sobel',THRESH) specifies the sensitivity threshold for
%   the Sobel method. EDGE ignores all edges that are not stronger than
%   THRESH.  If you do not specify THRESH, or if THRESH is empty ([]),
%   EDGE chooses the value automatically.
%
%   BW = EDGE(I,'sobel',THRESH,DIRECTION) specifies directionality for the
%   Sobel method. DIRECTION is a string or char vector specifying whether
%   to look for 'horizontal' or 'vertical' edges, or 'both' (the default).
%
%   BW = EDGE(I,'sobel',...,OPTIONS) provides an optional string or char
%   vector input. String or char vector 'nothinning' speeds up the
%   operation of the algorithm by skipping the additional edge thinning
%   stage. By default, or when 'thinning' string or char vector is
%   specified, the algorithm applies edge thinning.
%
%   [BW,thresh] = EDGE(I,'sobel',...) returns the threshold value.
%
%   Prewitt Method
%   --------------
%   BW = EDGE(I,'prewitt') specifies the Prewitt method.
%
%   BW = EDGE(I,'prewitt',THRESH) specifies the sensitivity threshold for
%   the Prewitt method. EDGE ignores all edges that are not stronger than
%   THRESH. If you do not specify THRESH, or if THRESH is empty ([]),
%   EDGE chooses the value automatically.
%
%   BW = EDGE(I,'prewitt',THRESH,DIRECTION) specifies directionality for
%   the Prewitt method. DIRECTION is a string or char vector specifying
%   whether to look for 'horizontal' or 'vertical' edges, or 'both' (the
%   default).
%
%   BW = EDGE(I,'prewitt',...,OPTIONS) provides an optional string or char
%   vector input. String or char vector 'nothinning' speeds up the
%   operation of the algorithm by skipping the additional edge thinning
%   stage. By default, or when 'thinning' string or char vector is
%   specified, the algorithm applies edge thinning.
%
%   [BW,thresh] = EDGE(I,'prewitt',...) returns the threshold value.
%
%   Roberts Method
%   --------------
%   BW = EDGE(I,'roberts') specifies the Roberts method.
%
%   BW = EDGE(I,'roberts',THRESH) specifies the sensitivity threshold for
%   the Roberts method. EDGE ignores all edges that are not stronger than
%   THRESH. If you do not specify THRESH, or if THRESH is empty ([]),
%   EDGE chooses the value automatically.
%
%   BW = EDGE(I,'roberts',...,OPTIONS) provides an optional string or char
%   vector input. String or char vector 'nothinning' speeds up the
%   operation of the algorithm by skipping the additional edge thinning
%   stage. By default, or when 'thinning' string or char vector is
%   specified, the algorithm applies edge thinning.
%
%   [BW,thresh] = EDGE(I,'roberts',...) returns the threshold value.
%
%   Laplacian of Gaussian Method
%   ----------------------------
%   BW = EDGE(I,'log') specifies the Laplacian of Gaussian method.
%
%   BW = EDGE(I,'log',THRESH) specifies the sensitivity threshold for the
%   Laplacian of Gaussian method. EDGE ignores all edges that are not
%   stronger than THRESH. If you do not specify THRESH, or if THRESH is
%   empty ([]), EDGE chooses the value automatically.
%
%   BW = EDGE(I,'log',THRESH,SIGMA) specifies the Laplacian of Gaussian
%   method, using SIGMA as the standard deviation of the LoG filter. The
%   default SIGMA is 2; the size of the filter is N-by-N, where
%   N=CEIL(SIGMA*3)*2+1.
%
%   [BW,thresh] = EDGE(I,'log',...) returns the threshold value.
%
%   Zero-cross Method
%   -----------------
%   BW = EDGE(I,'zerocross',THRESH,H) specifies the zero-cross method,
%   using the specified filter H. If THRESH is empty ([]), EDGE chooses
%   the sensitivity threshold automatically.
%
%   [BW,THRESH] = EDGE(I,'zerocross',...) returns the threshold value.
%
%   Canny Method
%   ----------------------------
%   BW = EDGE(I,'canny') specifies the Canny method.
%
%   BW = EDGE(I,'canny',THRESH) specifies sensitivity thresholds for the
%   Canny method. THRESH is a two-element vector in which the first element
%   is the low threshold, and the second element is the high threshold. If
%   you specify a scalar for THRESH, this value is used for the high
%   threshold and 0.4*THRESH is used for the low threshold. If you do not
%   specify THRESH, or if THRESH is empty ([]), EDGE chooses low and high
%   values automatically.
%
%   BW = EDGE(I,'canny',THRESH,SIGMA) specifies the Canny method, using
%   SIGMA as the standard deviation of the Gaussian filter. The default
%   SIGMA is sqrt(2); the size of the filter is chosen automatically, based
%   on SIGMA.
%
%   [BW,thresh] = EDGE(I,'canny',...) returns the threshold values as a
%   two-element vector.
%
%   BW = EDGE(I,'approxcanny') specifies the approximate canny method.
%
%   BW = EDGE(I,'approxcanny',THRESH) specifies sensitivity thresholds for
%   the 'approxcanny' method. THRESH is a two element vector, the first
%   element of which specifies the lower threshold for edge strength, below
%   which all edges are disregarded. The second element specifies the
%   higher threshold, above which all edge pixels are preserved. The range
%   of values allowed is between 0 and 1. If a scalar is specified, it is
%   used as the high threshold, and the low threshold is computed as
%   0.4*high threshold. If you do not specify THRESH, or if THRESH is empty
%   ([]), EDGE chooses low and high values automatically.
%
%   Class Support
%   -------------
%   I is a nonsparse numeric array. BW is of class logical.
%
%   Remarks
%   -------
%   For the 'log' and 'zerocross' methods, if you specify a
%   threshold of 0, the output image has closed contours because
%   it includes all of the zero crossings in the input image.
%
%   For the 'approxcanny' method, floating point images are expected to be
%   normalized in the range [0, 1].
%
%   The function EDGE changed in version 7.2 (R2011a). Previous versions
%   of the Image Processing Toolbox used a different algorithm for
%   computing the Canny method. If you need the same results produced
%   by the previous implementation, use BW = EDGE(I,'canny_old',...).
%
%   Example
%   -------
%   Find the edges of the circuit.tif image using the Prewitt and Canny
%   methods:
%
%       I = imread('circuit.tif');
%       BW1 = edge(I,'prewitt');
%       BW2 = edge(I,'canny');
%       figure, imshow(BW1)
%       figure, imshow(BW2)
%
%   See also FSPECIAL, IMGRADIENT, IMGRADIENTXY.

%   Copyright 1992-2017 The MathWorks, Inc.

%   [BW,thresh,gv,gh] = EDGE(I,'sobel',...) returns vertical and
%   horizontal edge responses to Sobel gradient operators. You can
%   also use these expressions to obtain gradient responses:
%   if ~(isa(I,'double') || isa(I,'single')); I = im2single(I); end
%   gh = imfilter(I,fspecial('sobel') /8,'replicate'); and
%   gv = imfilter(I,fspecial('sobel')'/8,'replicate');
% 
%   [BW,thresh,gv,gh] = EDGE(I,'prewitt',...) returns vertical and
%   horizontal edge responses to Prewitt gradient operators. You can
%   also use these expressions to obtain gradient responses:
%   if ~(isa(I,'double') || isa(I,'single')); I = im2single(I); end
%   gh = imfilter(I,fspecial('prewitt') /6,'replicate'); and
%   gv = imfilter(I,fspecial('prewitt')'/6,'replicate');
%
%   [BW,thresh,g45,g135] = EDGE(I,'roberts',...) returns 45 degree and
%   135 degree edge responses to Roberts gradient operators. You can
%   also use these expressions to obtain gradient responses:
%   if ~(isa(I,'double') || isa(I,'single')); I = im2single(I); end
%   g45  = imfilter(I,[1 0; 0 -1]/2,'replicate'); and
%   g135 = imfilter(I,[0 1;-1  0]/2,'replicate');

args = matlab.images.internal.stringToChar(varargin);
[a,method,thresh,sigma,thinning,H,kx,ky] = parse_inputs(args{:});

% Check that the user specified a valid number of output arguments
if ~any(strcmp(method,{'sobel','roberts','prewitt'})) && (nargout>2)
    error(message('images:edge:tooManyOutputs'))
end

% Transform to a double precision intensity image if necessary
isPrewittOrSobel = strcmp(method,'sobel') || strcmp(method,'prewitt');
if ~isPrewittOrSobel && ~isfloat(a) && ~strcmp(method,'approxcanny')
    a = im2single(a);
end


[m,n] = size(a);

if strcmp(method,'canny')
    % Magic numbers
    PercentOfPixelsNotEdges = .7; % Used for selecting thresholds
    ThresholdRatio = .4;          % Low thresh is this fraction of the high.
    
    % Calculate gradients using a derivative of Gaussian filter
    [dx, dy] = smoothGradient(a, sigma);
    
    % Calculate Magnitude of Gradient
    magGrad = hypot(dx, dy);
    
    % Normalize for threshold selection
    magmax = max(magGrad(:));
    if magmax > 0
        magGrad = magGrad / magmax;
    end
    
    % Determine Hysteresis Thresholds
    [lowThresh, highThresh] = selectThresholds(thresh, magGrad, PercentOfPixelsNotEdges, ThresholdRatio, mfilename);
    
    % Perform Non-Maximum Suppression Thining and Hysteresis Thresholding of Edge
    % Strength
    e = thinAndThreshold(dx, dy, magGrad, lowThresh, highThresh);
    thresh = [lowThresh highThresh];

elseif strcmp(method,'approxcanny')
    e = computeapproxcanny(a, thresh);

elseif strcmp(method,'canny_old')
    % Magic numbers
    GaussianDieOff = .0001;
    PercentOfPixelsNotEdges = .7; % Used for selecting thresholds
    ThresholdRatio = .4;          % Low thresh is this fraction of the high.
    
    % Design the filters - a gaussian and its derivative
    
    pw = 1:30; % possible widths
    ssq = sigma^2;
    width = find(exp(-(pw.*pw)/(2*ssq))>GaussianDieOff,1,'last');
    if isempty(width)
        width = 1;  % the user entered a really small sigma
    end
    
    t = (-width:width);
    gau = exp(-(t.*t)/(2*ssq))/(2*pi*ssq);     % the gaussian 1D filter
    
    % Find the directional derivative of 2D Gaussian (along X-axis)
    % Since the result is symmetric along X, we can get the derivative along
    % Y-axis simply by transposing the result for X direction.
    [x,y]=meshgrid(-width:width,-width:width);
    dgau2D=-x.*exp(-(x.*x+y.*y)/(2*ssq))/(pi*ssq);
    
    % Convolve the filters with the image in each direction
    % The canny edge detector first requires convolution with
    % 2D Gaussian, and then with the derivative of a Gaussian.
    % Since Gaussian filter is separable, for smoothing, we can use
    % two 1D convolutions in order to achieve the effect of convolving
    % with 2D Gaussian.  We convolve along rows and then columns.
    
    %smooth the image out
    aSmooth=imfilter(a,gau,'conv','replicate');   % run the filter across rows
    aSmooth=imfilter(aSmooth,gau','conv','replicate'); % and then across columns
    
    %apply directional derivatives
    ax = imfilter(aSmooth, dgau2D, 'conv','replicate');
    ay = imfilter(aSmooth, dgau2D', 'conv','replicate');
    
    mag = sqrt((ax.*ax) + (ay.*ay));
    magmax = max(mag(:));
    if magmax>0
        mag = mag / magmax;   % normalize
    end
    
    % Select the thresholds
    if isempty(thresh)
        counts=imhist(mag, 64);
        highThresh = find(cumsum(counts) > PercentOfPixelsNotEdges*m*n,...
            1,'first') / 64;
        lowThresh = ThresholdRatio*highThresh;
        thresh = [lowThresh highThresh];
    elseif length(thresh)==1
        highThresh = thresh;
        if thresh>=1
            error(message('images:edge:singleThresholdOutOfRange'))
        end
        lowThresh = ThresholdRatio*thresh;
        thresh = [lowThresh highThresh];
    elseif length(thresh)==2
        lowThresh = thresh(1);
        highThresh = thresh(2);
        if (lowThresh >= highThresh) || (highThresh >= 1)
            error(message('images:edge:thresholdOutOfRange'))
        end
    end
    
    % The next step is to do the non-maximum suppression. We will accrue
    % indices which specify ON pixels in strong edgemap The array e will become
    % the weak edge map.
    e = cannyFindLocalMaxima(ax,ay,mag,lowThresh);
    
    if ~isempty(e)
        [rstrong,cstrong] = find(mag>highThresh & e);
        
        if ~isempty(rstrong) % result is all zeros if idxStrong is empty
            e = bwselect(e, cstrong, rstrong, 8);
            e = bwmorph(e, 'thin', 1); % Thin double (or triple) pixel wide contours
        end
    end
    
elseif any(strcmp(method, {'log','zerocross'}))
    % The output edge map:
    e = false(m,n);
    
    rr = 2:m-1; cc=2:n-1;
    
    % We don't use image blocks here
    if isempty(H)
        fsize = ceil(sigma*3) * 2 + 1;  % choose an odd fsize > 6*sigma;
        op = fspecial('log',fsize,sigma);
    else
        op = H;
    end
    
    op = op - sum(op(:))/numel(op); % make the op to sum to zero
    b = imfilter(a,op,'replicate');
    
    if isempty(thresh)
        thresh = 0.75 * sum(abs(b(:)),'double') / numel(b);
    end
    
    % Look for the zero crossings:  +-, -+ and their transposes
    % We arbitrarily choose the edge to be the negative point
    [rx,cx] = find( b(rr,cc) < 0 & b(rr,cc+1) > 0 ...
        & abs( b(rr,cc)-b(rr,cc+1) ) > thresh );   % [- +]
    e((rx+1) + cx*m) = 1;
    [rx,cx] = find( b(rr,cc-1) > 0 & b(rr,cc) < 0 ...
        & abs( b(rr,cc-1)-b(rr,cc) ) > thresh );   % [+ -]
    e((rx+1) + cx*m) = 1;
    [rx,cx] = find( b(rr,cc) < 0 & b(rr+1,cc) > 0 ...
        & abs( b(rr,cc)-b(rr+1,cc) ) > thresh);   % [- +]'
    e((rx+1) + cx*m) = 1;
    [rx,cx] = find( b(rr-1,cc) > 0 & b(rr,cc) < 0 ...
        & abs( b(rr-1,cc)-b(rr,cc) ) > thresh);   % [+ -]'
    e((rx+1) + cx*m) = 1;
    
    % Most likely this covers all of the cases.   Just check to see if there
    % are any points where the LoG was precisely zero:
    [rz,cz] = find( b(rr,cc)==0 );
    if ~isempty(rz)
        % Look for the zero crossings: +0-, -0+ and their transposes
        % The edge lies on the Zero point
        zero = (rz+1) + cz*m;   % Linear index for zero points
        zz = (b(zero-1) < 0 & b(zero+1) > 0 ...
            & abs( b(zero-1)-b(zero+1) ) > 2*thresh);     % [- 0 +]'
        e(zero(zz)) = 1;
        zz = (b(zero-1) > 0 & b(zero+1) < 0 ...
            & abs( b(zero-1)-b(zero+1) ) > 2*thresh);     % [+ 0 -]'
        e(zero(zz)) = 1;
        zz = (b(zero-m) < 0 & b(zero+m) > 0 ...
            & abs( b(zero-m)-b(zero+m) ) > 2*thresh);     % [- 0 +]
        e(zero(zz)) = 1;
        zz = (b(zero-m) > 0 & b(zero+m) < 0 ...
            & abs( b(zero-m)-b(zero+m) ) > 2*thresh);     % [+ 0 -]
        e(zero(zz)) = 1;
    end
    
else  % one of the easy methods (roberts,sobel,prewitt)
    
    if isPrewittOrSobel
        isSobel = strcmp(method, 'sobel');
        scale = 4; % for calculating the automatic threshold
        offset = [0 0 0 0]; % offsets used in the computation of the threshold
        
        [bx, by, b] = edgesobelprewittmex(a, isSobel, kx, ky); 
      
    elseif strcmp(method, 'roberts')
        x_mask = [1 0; 0 -1]/2; % Roberts approximation to diagonal derivative
        y_mask = [0 1;-1  0]/2;
        
        scale = 6;
        offset = [-1 1 1 -1];
        
        % compute the gradient in x and y direction
        bx = imfilter(a,x_mask,'replicate');
        by = imfilter(a,y_mask,'replicate');
        
        % compute the magnitude
        b = kx*bx.*bx + ky*by.*by;
        
    else
        error(message('images:edge:invalidEdgeDetectionMethod', method))
    end
    
    if (nargout > 2) % if gradients are requested
        gv_45  = bx;
        gh_135 = by;
    end
    
    % Determine the threshold; see page 514 of
    % "Digital Imaging Processing" by William K. Pratt
    if isempty(thresh) % Determine cutoff based on RMS estimate of noise
        % Mean of the magnitude squared image is a
        % value that's roughly proportional to SNR
        cutoff = scale * sum(b(:),'double') / numel(b);
        thresh = sqrt(cutoff);
    else
        % Use relative tolerance specified by the user
        cutoff = (thresh).^2;
    end
    
    if thinning
        e = computeedge(b,bx,by,kx,ky,int8(offset),100*eps,cutoff);
    else
        e = b > cutoff;
    end
    
end

if nargout==0
    imshow(e);
else
    eout = e;
end

if isempty(a)
    if nargout==2
        if nargin == 2
            if strcmp(method,'canny')
                thresh = nan(1,2);
            else
                thresh = nan(1);
            end
        end
    end    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Local Function : parse_inputs
%
function [I,Method,Thresh,Sigma,Thinning,H,kx,ky] = parse_inputs(varargin)
% OUTPUTS:
%   I      Image Data
%   Method Edge detection method
%   Thresh Threshold value
%   Sigma  standard deviation of Gaussian
%   H      Filter for Zero-crossing detection
%   kx,ky  From Directionality vector

narginchk(1,5)

I = varargin{1};

validateattributes(I,{'numeric','logical'},{'real','nonsparse','2d'},mfilename,'I',1);

% Defaults
Method    = 'sobel';
Direction = 'both';
Thinning  = true;

methods    = {'canny','approxcanny','canny_old','prewitt','sobel','marr-hildreth','log','roberts','zerocross'};
directions = {'both','horizontal','vertical'};
options    = {'thinning','nothinning'};

% Now parse the nargin-1 remaining input arguments

% First get the strings - we do this because the interpretation of the
% rest of the arguments will depend on the method.
nonstr = [];   % ordered indices of non-string arguments
for i = 2:nargin
    if ischar(varargin{i})
        str = lower(varargin{i});
        j = find(strcmp(str,methods));
        k = find(strcmp(str,directions));
        l = find(strcmp(str,options));
        if ~isempty(j)
            Method = methods{j(1)};
            if strcmp(Method,'marr-hildreth')
                error(message('images:removed:syntax','EDGE(I,''marr-hildreth'',...)','EDGE(I,''log'',...)')) 
            end
        elseif ~isempty(k)
            Direction = directions{k(1)};
        elseif ~isempty(l)
            if strcmp(options{l(1)},'thinning')
                Thinning = true;
            else
                Thinning = false;
            end
        else
            error(message('images:edge:invalidInputString', varargin{ i }))
        end
    else
        nonstr = [nonstr i]; %#ok<AGROW>
    end
end

% Now get the rest of the arguments
[Thresh,Sigma,H,kx,ky] = images.internal.parseNonStringInputsEdge(varargin,Method,Direction,nonstr);
validateattributes(Thresh,{'numeric'},{'real'},mfilename,'thresh',3);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Local Function : smoothGradient
%
function [GX, GY] = smoothGradient(I, sigma)

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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Local Function : selectThresholds
%
function [lowThresh, highThresh] = selectThresholds(thresh, magGrad, PercentOfPixelsNotEdges, ThresholdRatio, ~)

[m,n] = size(magGrad);

% Select the thresholds
if isempty(thresh)
    counts=imhist(magGrad, 64);
    highThresh = find(cumsum(counts) > PercentOfPixelsNotEdges*m*n,...
        1,'first') / 64;
    lowThresh = ThresholdRatio*highThresh;
elseif length(thresh)==1
    highThresh = thresh;
    if thresh>=1
        error(message('images:edge:singleThresholdOutOfRange'))
    end
    lowThresh = ThresholdRatio*thresh;
elseif length(thresh)==2
    lowThresh = thresh(1);
    highThresh = thresh(2);
    if (lowThresh >= highThresh) || (highThresh >= 1)
        error(message('images:edge:thresholdOutOfRange'))
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Local Function : thinAndThreshold
%
function H = thinAndThreshold(dx, dy, magGrad, lowThresh, highThresh)
% Perform Non-Maximum Suppression Thining and Hysteresis Thresholding of
% Edge Strength
    
% We will accrue indices which specify ON pixels in strong edgemap
% The array e will become the weak edge map.

E = cannyFindLocalMaxima(dx,dy,magGrad,lowThresh);

if ~isempty(E)
    [rstrong,cstrong] = find(magGrad>highThresh & E);
    
    if ~isempty(rstrong) % result is all zeros if idxStrong is empty
        H = bwselect(E, cstrong, rstrong, 8);
    else
        H = false(size(E));
    end
else
    H = false(size(E));
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Local Function : computeapproxcanny
%
function e = computeapproxcanny(a, thresh)
    a = im2uint8(a);
    if isempty(a)
        e = logical([]);
    else
        if isempty(thresh)
            e = images.internal.ocvcanny(a);
        else
            if numel(thresh) == 1
                e = images.internal.ocvcanny(a, 0.4*thresh, thresh);
            else
                e = images.internal.ocvcanny(a, thresh(2), thresh(1));
            end
        end
        e = logical(e);
    end
