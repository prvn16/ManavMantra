function [centers, metric] = chcenters(varargin)
%CHCENTERS Find circle center locations from the Circular Hough Transform accumulator array 
%   CENTERS = CHCENTERS(H, SUPRESSIONTHRESH, SIGMA) finds all the potential
%   circle center locations from the accumulator array H. CENTERS is a
%   P-by-2 matrix, where P is the number of circles found from the
%   accumulator array. CENTERS holds the x- and y-coordinates of the
%   centers. If H is complex the magnitude is H is used for locating the
%   circle centers. 
% 
%   SUPRESSIONTHRESH  Non-negative scalar Q in the range [0 1], 
%                     specifies the threshold for supressing local peaks in
%                     the Circular Hough Transform accumulator array. Any
%                     local maxima in the accumulator array with h-maxima
%                     value values lower than SUPRESSIONTHRESH is rejected.
%                     Fewer circles are detected as the value of Q
%                     increases. Default: Q = 0.2.
%             
%   SIGMA             Positive real scalar value which specifies the standard
%                     deviation of the Gaussian filter used for smoothing
%                     the accumulator array prior to the estimation of the
%                     circle centers. By default no smoothing filter is
%                     applied on the accumulator array. If SIGMA is
%                     specified, the size of the filter is chosen
%                     automatically, based on SIGMA.
% 
%  [CENTERS, METRIC] = CHCENTERS(H, SUPRESSIONTHRESH, SIGMA) also returns
%  the magnitude of the accumulator array peak associated with each circle
%  in the column vector METRIC. CENTERS is sorted based on METRIC values.
% 
% See also CHACCUM, CHRADII, CHRADIIPHCODE, IMFINDCIRCLES, VISCIRCLES.

%   Copyright 2011 The MathWorks, Inc.

parsedInputs = parse_inputs(varargin{:});

accumMatrix   = parsedInputs.AccumArray;
suppThreshold = parsedInputs.SuppressionThresh;  
sigma         = parsedInputs.Sigma;
medFiltSize = 5; % Size of the median filter
 
centers = [];
metric = [];
%% Use the magnitude - Accumulator array can be complex. 
accumMatrix = abs(accumMatrix);

%% Check if the accumulator array is flat
flat = all(accumMatrix(:) == accumMatrix(1));
if (flat)
    return;
end
%% Filter the accumulator array
if (~isempty(sigma))
    accumMatrix = gaussianFilter(accumMatrix, sigma);
end

%% Pre-process the accumulator array
if (min(size(accumMatrix)) > medFiltSize)
    Hd = medfilt2(accumMatrix, [medFiltSize medFiltSize]); % Apply median filtering only if the image is big enough.
else
    Hd = accumMatrix;
end
suppThreshold = max(suppThreshold - eps(suppThreshold), 0);
Hd = imhmax(Hd, suppThreshold);
bw = imregionalmax(Hd);
s = regionprops(bw,accumMatrix,'weightedcentroid'); % Weighted centroids of detected peaks.

%% Sort the centers based on their accumulator array value
if (~isempty(s))
    centers = reshape(cell2mat(struct2cell(s)),2,length(s))';
    % Remove centers which are NaN.
    [rNaN, ~] = find(isnan(centers));
    centers(rNaN,:) = [];
    
    if(~isempty(centers))
        metric = Hd(sub2ind(size(Hd),round(centers(:,2)),round(centers(:,1))));
        % Sort the centers in descending order of metric
        [metric,sortIdx] = sort(metric,1,'descend');
        centers = centers(sortIdx,:);
    end
end

end

function accumMatrix = gaussianFilter(accumMatrix, sigma)
    filtSize = ceil(sigma*3);
    filtSize = min(filtSize + ceil(rem(filtSize,2)), min(size(accumMatrix))); % filtSize = Smallest odd integer greater than sigma*3
    gaussFilt = fspecial('gaussian',[filtSize filtSize],sigma);
    accumMatrix = imfilter(accumMatrix, gaussFilt, 'same');
end

function parsedInputs = parse_inputs(varargin)

narginchk(1,3);

persistent parser;

if(isempty(parser))
    parser = inputParser();

    parser.addRequired('AccumArray',@checkAccumArray);
    parser.addOptional('SuppressionThresh',0.2,@checkSuppressionThresh);
    parser.addOptional('Sigma',[],@checkSigma);
end

% Parse input
parser.parse(varargin{:});
parsedInputs = parser.Results;

    function tf = checkAccumArray(accumMatrix)
        validateattributes(accumMatrix,{'numeric'},{'nonempty',...
            'nonsparse','2d'},mfilename,'H',1);
        tf = true;
    end

    function tf = checkSuppressionThresh(ST)
        validateattributes(ST,{'numeric'},{'nonempty','nonnan',...
            'finite','scalar'},mfilename,'SuppressionThresh',2);
        if(ST > 1 || ST < 0)
            error(message('images:imfindcircles:outOfRangeSuppressionThresh')); % Change error ID and add new entry to message catalog
        end
        tf = true;
    end

    function tf = checkSigma(sigma)
        validateattributes(sigma,{'numeric'},{'nonempty','nonnan',...
            'nonsparse','positive','finite','scalar'},mfilename,'Sigma',3);
        
        tf = true;
    end            

end





