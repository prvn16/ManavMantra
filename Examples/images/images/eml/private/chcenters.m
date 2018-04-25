function [centers, metric] = chcenters(varargin) %#codegen
%CHCENTERS Find circle center locations from the Circular Hough Transform accumulator array 

%   Copyright 2015 The MathWorks, Inc.

[accumMatrixIn, suppThreshold, sigma] = parseInputs(varargin{:});

medFiltSize = 5; % Size of the median filter
 
centers = [];
metric = [];
%% Use the magnitude - Accumulator array can be complex. 
accumMatrixRe = abs(accumMatrixIn);

%% Check if the accumulator array is flat
flat = all(accumMatrixRe(:) == accumMatrixRe(1));
if (flat)
    return;
end
%% Filter the accumulator array
if (~isempty(sigma))
    accumMatrix = gaussianFilter(accumMatrixRe, sigma);
else
    accumMatrix = accumMatrixRe;
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
    centers = coder.nullcopy(zeros(numel(s),2));
    for idx = 1:numel(s)
        centers(idx,:) = s(idx).WeightedCentroid;
    end
    
    % Remove centers which are NaN
    for idx = size(centers,1):-1:1
        if isnan(centers(idx,1)) || isnan(centers(idx,2))
            centers(idx,:) = [];
        end
    end
    
    if(~isempty(centers))
        metric = Hd(sub2ind(size(Hd),round(centers(:,2)),round(centers(:,1))));
        % Sort the centers in descending order of metric
        [metric,sortIdx] = sort(metric,1,'descend');
        centers = centers(sortIdx,:);
    end
end

end

function accumMatrix = gaussianFilter(accumMatrixIn, sigma)

    coder.inline('always');

    filtSize = ceil(sigma*3);
    % filtSize = Smallest odd integer greater than sigma*3
    filtSize = min(filtSize + ceil(rem(filtSize,2)), min(size(accumMatrixIn)));
    gaussFilt = fspecial('gaussian',[filtSize filtSize],sigma);
    accumMatrix = imfilter(accumMatrixIn, gaussFilt, 'same');
end

function [accumMatrix, suppThreshold, sigma] = parseInputs(varargin)
% Parse optional PV pairs

coder.inline('always');
coder.internal.prefer_const(varargin);

narginchk(1,3);

accumMatrix = varargin{1};
if nargin > 1
    suppThreshold = varargin{2}; 
else
    suppThreshold = 0.2;
end

if nargin > 2
    sigma = varargin{3};
    checkSigma(sigma);
else
    sigma = [];
end

% Validate PV pairs
checkAccumArray(accumMatrix);
checkSuppressionThresh(suppThreshold);

end

function checkAccumArray(accumMatrix)
validateattributes(accumMatrix,{'numeric'},{'nonempty',...
    'nonsparse','2d'},mfilename,'H',1);
end

function checkSuppressionThresh(ST)
validateattributes(ST,{'numeric'},{'nonempty','nonnan',...
    'finite','scalar'},mfilename,'SuppressionThresh',2);
coder.internal.errorIf(ST > 1 || ST < 0,...
    'images:imfindcircles:outOfRangeSuppressionThresh');
end

function checkSigma(sigma)
validateattributes(sigma,{'numeric'},{'nonempty','nonnan',...
    'nonsparse','positive','finite','scalar'},mfilename,'Sigma',3);
end
