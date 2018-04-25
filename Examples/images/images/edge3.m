function eout = edge3(varargin)
% edge3 Find edges in 3-D intensity volume.
%
% BW = EDGE3(V,'approxcanny',THRESH) returns the edges found in the volume
% V using the 'approxcanny' method. The approximate Canny method finds
% edges by looking for local maxima of the gradient of V. The gradient of V
% is computed as a derivative of the gaussian smoothed volume.
% For the approximate Canny method, THRESH is a two-element vector in which
% the first element is the low threshold, and the second element is the
% high threshold, [lowthresh highthresh]. If THRESH is specified as a scalar, 
% EDGE3 uses this value for the high threshold and 0.4*THRESH for the low
% threshold.
% The approximate Canny method uses two thresholds to detect strong and
% weak edges, and includes the weak edges in the output only if they are
% connected to strong edges. 
%
% BW = EDGE3(V,'approxcanny',THRESHOLD,SIGMA) returns the edges found in
% the volume, where SIGMA is a scalar that specifies the standard deviation
% of the smoothing Gaussian filter. SIGMA can also be a 1x3 vector, [SigmaX, 
% SigmaY, SigmaZ] with different standard deviations in each direction. This 
% can be used for anisotropic volumes having different scales in each direction.
% By default, SIGMA is sqrt(2) and is isotropic. 
%
% BW = EDGE3(V,'sobel',THRESH) accepts an intensity or a binary volume V as
% its input, and returns a binary volume BW, the same size as V, with 1's
% where the function finds edges in V and 0's elsewhere.
% The Sobel method finds edges using the Sobel approximation to the
% derivative. It returns edges at those points where the gradient of V is
% maximum.
% THRESH is a scalar that specifies the sensitivity threshold for the
% Sobel method. EDGE3 ignores all edges that are not stronger than THRESH.
% 
% BW = EDGE3(V,'sobel',THRESH,'nothinning') speeds up the operation of
% the algorithm by skipping the additional edge thinning stage. By default,
% or when 'thinning' is specified, the algorithm applies edge thinning. To
% skip this part of the algorithm, specify 'nothinning'.
%  
% Class Support
% -------------
% V is a nonsparse 3-D numeric array. BW is of class logical.
%
% Example
% -------
% Find the edges of the mri volume using the approxcanny method:
%
% load mri;
% V = squeeze(D);
%
% scaleX = 1; 
% scaleY = 1; 
% scaleZ = 2.5; 
%       
% Vsize = size(V);
% % Make volume isotropic
% V_isotropic = imresize3(V,[Vsize(1)*scaleX, Vsize(2)*scaleY,...
%                         Vsize(3)*scaleZ], 'linear');
%
% BW = edge3(V_isotropic,'approxcanny',0.6);
%       
% % Display binary edge volume
% volumeViewer (BW);

% Copyright 2017 The MathWorks, Inc.


[V, method, thresh, sigma, thinning] = parse_inputs(varargin{:});

if(isempty(V))
   eout = logical([]);
   return;
end

if strcmp(method,'approxcanny')
    % Magic numbers
    ThresholdRatio = .4;          % Low thresh is this fraction of the high.
  
    if(isscalar(thresh))
        highThresh = thresh;
        lowThresh = ThresholdRatio*highThresh;
    else
        highThresh = thresh(2);
        lowThresh = thresh(1);
    end
    
    if(isscalar(sigma))
        sigma = [sigma sigma sigma];
    end
    
    if(isa(V, 'double')||isa(V, 'uint32')||isa(V, 'int32'))
        V = double(V);
    else
        V = single(V);
    end
    
    % call into ITK's implementaion of 3-D approxcanny
    eout = cast(canny3mex(V, lowThresh, highThresh, sigma.^2), 'logical');
    
elseif strcmp(method,'sobel')
    
    offset = [0 0 0 0]; % offsets used in the computation of the threshold
    
    if(isa(V, 'double')||isa(V, 'uint32')||isa(V, 'int32'))
        V = double(V);
    else
        V = single(V);
    end
    
    % Compute sobel gradients
    [bx, by, bz] = imgradientxyz(V, 'sobel');
    
    % Normalize the sobel gradient (divide by sum(abs(3DSobelKernel(:))) )
    bx = bx/22;
    by = by/22;
    bz = bz/22;
    
    % Compute gradient magnitude
    b = hypot(hypot(bx, by), bz);
    
    bMax = max(b(:));
    bMin = min(b(:));

    % Scale thresh to the range of gradient magnitude
    cutoff = double((bMax - bMin) * thresh);

    kx = 1; ky = 1; kz = 1;
    
    if thinning
        eout = computeedge3(b,bx,by,bz,kx,ky,kz,int8(offset),100*eps,cutoff);
    else
        eout = b > cutoff;
    end
    
else
    error(message('images:edge:invalidEdgeDetectionMethod', method))
end
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Local Function : parse_inputs
function [V, method, thresh, sigma, thinning] = parse_inputs(varargin)
% OUTPUTS:
%   V      Image Data
%   Method Edge detection method
%   Thresh Threshold value
%   Sigma  standard deviation of Gaussian


narginchk(1,4)

V = varargin{1};
validateattributes(V,{'numeric','logical'},{'real','nonsparse','3d'},mfilename,'V',1);

methods    = {'approxcanny','sobel'};

if(nargin >= 2)
    MethodStr = varargin{2};
    MethodStr = validatestring(MethodStr, methods, mfilename, 'Method',2);   
else
    % Default Method
    MethodStr = 'approxcanny';
end   
 % Defaults

parser = inputParser;
parser.PartialMatching = true;
parser.CaseSensitive = false;

switch lower(MethodStr)
    
    case 'approxcanny'
        parser.addRequired('V');
        parser.addRequired('Method');
        parser.addRequired('Threshhold', @validateThreshholdCanny);
        parser.addOptional('Sigma', sqrt(2), @validateSigma);
        
    case 'sobel'   
        parser.addRequired('V');
        parser.addRequired('Method');
        parser.addRequired('Threshhold', @validateThreshholdSobel);
        parser.addOptional('ThinningOptionStr', 'thinning', @validateThinningOption); 
end 

 

parser.parse(varargin{:});
res = parser.Results;

method = MethodStr;
thresh = res.Threshhold;

if(strcmpi(MethodStr, 'approxcanny'))
    sigma = res.Sigma;
    thinning = false;
else
    sigma = [];
    
    [~, thinningStr] = validateThinningOption(res.ThinningOptionStr);
    if(strcmp(thinningStr, 'thinning'))
        thinning = true;
    else
        thinning = false;
    end
end

end

function TF = validateThreshholdCanny(thresh)

    validateattributes(thresh,{'numeric'},{'real', 'nonnan', 'nonempty'},mfilename,'thresh',3);
    if(numel(thresh)>2)
        error(message('images:validate:badVectorLength','Threshold',2)); 
    end
    if any(thresh > 1) || any(thresh <= 0)
       error(message('images:edge:thresholdOutOfRange'));
    end
    
    if((numel(thresh)==2)&&(thresh(1)>thresh(2)))
        error(message('images:edge:thresholdOutOfRange'));
    end
    TF = true;
end

function TF = validateThreshholdSobel(thresh)

    validateattributes(thresh,{'numeric'},{'real', 'scalar', 'nonnan', 'nonempty'},mfilename,'thresh',3);
    
    if any(thresh > 1) || any(thresh <= 0)
       error(message('images:edge:thresholdOutOfRange'));
    end
    
    TF = true;
end

function TF = validateSigma(sigma)
    validateattributes(sigma,{'numeric'},{'real', 'finite', 'nonzero','positive'},mfilename,'thresh',4);
    if((numel(sigma)== 3)||(numel(sigma)== 1))
        %Donothing
    else
       error(message('images:validate:badVectorLength','Sigma',3)); 
    end
        
        
    TF = true;
end
function [TF, thinningStr]  = validateThinningOption(thinningStr)
    options    = {'thinning','nothinning'};
    thinningStr = validatestring(thinningStr, options, mfilename, 'ThinningOption',4);
    TF=true;
end

