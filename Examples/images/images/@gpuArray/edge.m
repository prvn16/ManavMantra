function [eout,thresh,gv_45,gh_135] = edge(varargin)
%EDGE Find edges in intensity image.
%   EDGE takes an intensity or a binary gpuArray image I as its input, and
%   returns a binary gpuArray image BW of the same size as I, with 1's
%   where the function finds edges in I and 0's elsewhere.
%
%   EDGE supports five different edge-finding methods:
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
%
%   Class Support
%   -------------
%   I is a gpuArray. BW is a gpuArray with underlying class logical.
%
%   Remarks
%   -------
%   For the 'log' and 'zerocross' methods, if you specify a
%   threshold of 0, the output image has closed contours because
%   it includes all of the zero crossings in the input image.
%
%   Example
%   -------
%   Find the edges of the circuit.tif image using the Prewitt and Sobel
%   methods:
%
%       I = gpuArray(imread('circuit.tif'));
%       BW1 = edge(I,'prewitt');
%       BW2 = edge(I,'sobel');
%       figure, imshow(BW1)
%       figure, imshow(BW2)
%
%   See also FSPECIAL, GPUARRAY/IMGRADIENT, GPUARRAY/IMGRADIENTXY,
%   GPUARRAY.

%   Copyright 2013-2017 The MathWorks, Inc.

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

narginchk(1,5)

% Dispatch to CPU if needed
if ~isa(varargin{1},'gpuArray')
    % Gather the inputs.
    for i = 2 : nargin
        varargin{i} = gather(varargin{i});
    end
    
    % Call the CPU implementation
    switch nargout
        case 0
            edge(varargin{:});
            
        case 1
            eout = edge(varargin{:});
            
        case 2
            [eout,thresh] = edge(varargin{:});
            
        case 3
            [eout,thresh,gv_45] = edge(varargin{:});
            
        case 4
            [eout,thresh,gv_45,gh_135] = edge(varargin{:});
                
    end
    return;
end

% Parse inputs
args = matlab.images.internal.stringToChar(varargin);
[a,method,thresh,sigma,thinning,H,kx,ky] = parse_inputs(args{:});

% Check that the user specified a valid number of output arguments
if ~any(strcmp(method,{'sobel','roberts','prewitt'})) && (nargout>2)
    error(message('images:edge:tooManyOutputs'));
end

% Transform to a double precision intensity image if necessary
if ~isfloat(a)
    a = im2single(a);
end

[m,n] = size(a);

if any(strcmp(method, {'log','zerocross'}))
       
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
        thresh = .75*mean2(double(abs(b)));
    end
    
    % detect zero-crossings by looking for [+-],[-+],[+-]' and [-+]'
    % transitions in b that are greater than thresh. also look for
    % [+0-],[-0+],[+0-]' and [-0+]' transitions.
    e = images.internal.gpu.zerocrossing(b,gather(thresh));
    
    % to stay consistent with CPU behavior, set boundary pixels to zero.
    if ~isempty(e)
        e = subsasgn(e,substruct('()',{1,':'}),gpuArray.false);%e(1  ,:  ) = false;
        e = subsasgn(e,substruct('()',{m,':'}),gpuArray.false);%e(end,:  ) = false;
        e = subsasgn(e,substruct('()',{':',1}),gpuArray.false);%e(:  ,1  ) = false;
        e = subsasgn(e,substruct('()',{':',n}),gpuArray.false);%e(:  ,end) = false;
    end
    
else  % one of the easy methods (roberts,sobel,prewitt)
    
    if strcmp(method,'sobel')
        op = fspecial('sobel')/8; % Sobel approximation to derivative
        x_mask = op'; % gradient in the X direction
        y_mask = op;
        
        scale = 4; % for calculating the automatic threshold
        isroberts = false;
        
    elseif strcmp(method,'prewitt')
        op = fspecial('prewitt')/6; % Prewitt approximation to derivative
        x_mask = op';
        y_mask = op;
        
        scale = 4;
        isroberts = false;
        
    elseif strcmp(method, 'roberts')
        x_mask = [1 0; 0 -1]/2; % Roberts approximation to diagonal derivative
        y_mask = [0 1;-1  0]/2;
        
        scale = 6;
        isroberts = true;
        
    else
        error(message('images:edge:invalidEdgeDetectionMethod', method))
    end
    
    % compute the gradient in x and y direction
    bx = imfilter(a,x_mask,'replicate');
    by = imfilter(a,y_mask,'replicate');
    
    if (nargout > 2) % if gradients are requested
        gv_45  = bx;
        gh_135 = by;
    end
    
    % compute the magnitude
    b = arrayfun(@computegradientmagnitude,bx,by);
    
    % determine the threshold; see page 514 of "Digital Imaging Processing" by
    % William K. Pratt
    if isempty(thresh) % Determine cutoff based on RMS estimate of noise
        % Mean of the magnitude squared image is a
        % value that's roughly proportional to SNR
        cutoff = scale*mean2(double(b));
        thresh = sqrt(cutoff);
    else                % Use relative tolerance specified by the user
        cutoff = (thresh).^2;
    end
    
    if thinning
        e = images.internal.gpu.computeedge(b,bx,by,kx,ky,isroberts,100*eps,gather(cutoff));
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

% nested function to compute pixel-wise gradient magnitude
function bmag = computegradientmagnitude(b_x,b_y)
    bmag = kx*b_x*b_x + ky*b_y*b_y;
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

I = varargin{1};

hValidateAttributes(I,...
    {'logical','uint8','int8','uint16','int16','uint32','int32','single','double'},...
    {'real','2d','nonsparse'},mfilename,'I',1);

% Defaults
Method    = 'sobel';
Direction = 'both'; 
Thinning  = true;

methods    = {'canny','canny_old','approxcanny','prewitt','sobel','marr-hildreth','log','roberts','zerocross'};
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
            % Canny is not supported on the GPU.
            if strcmp(Method,'canny') || strcmp(Method,'canny_old') || strcmp(Method,'approxcanny')
                error(message('images:edge:cannyUnsupportedOnGpu', Method));
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
        % gather if necessary.
        varargin{i} = gather(varargin{i});
        nonstr = [nonstr i]; %#ok<AGROW>
    end
end

% Now get the rest of the arguments
[Thresh,Sigma,H,kx,ky] = images.internal.parseNonStringInputsEdge(varargin,Method,Direction,nonstr);


end
