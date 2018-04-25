function [gradientThreshold, numberOfIterations] = imdiffuseest(I, varargin)
% IMDIFFUSEEST Estimate parameters for imdiffusefilt.
%   [gradientThreshold, numberOfIterations] = imdiffuseest(A) estimates the
%   parameters required to filter the grayscale image A using anisotropic
%   diffusion
%
%   [gradientThreshold, numberOfIterations] = imdiffuseest(___, PARAM, VAL)
%   changes the behavior of the anisotropic diffusion algorithm using the
%   following name-value pairs:
%
%     'Connectivity'            The number of neighborhood differences
%                               considered for the diffusion process.
%                               The value of connectivity must be 'maximal'
%                               (default) or 'minimal'. The 'maximal' and
%                               'minimal' connectivity considers 8 and 4
%                               nearest neighbor differences respectively.
%
%     'ConductionMethod'        The method used for diffusion, which may be
%                               'exponential' (default) or 'quadratic'.
%                               Exponential diffusion favors high contrast
%                               edges over low contrast ones. Quadratic
%                               diffusion favors wide regions over smaller
%                               ones.
%
%   Class Support
%   -------------
%   The input array A must be one of the following classes: uint8, uint16,
%   int16, single or double. It must be real and non-sparse. The output
%   gradientThreshold is a vector of the same type as A and
%   numberOfIterations is a double scalar.
%
%   Note
%   ----
%   Input image A of class single or double are assumed to take values
%   in [0 1].
%
%   Example
%   ---------
%   % Perform edge-aware noise reduction with estimated parameters
%
%   % Import a grayscale image
%   I = imread('pout.tif');
%
%   % Add Gaussian noise with zero mean and 0.001 variance
%   noisyImage = imnoise(I, 'gaussian', 0, 0.001);
%
%   % Estimate parameters for anisotropic diffusion
%   [gradThresh, numIter] = imdiffuseest(noisyImage);
%
%   % Apply anisotropic diffusion filter
%   diffusedImage = imdiffusefilt(noisyImage, 'GradientThreshold', ...
%    gradThresh, 'NumberOfIterations', numIter);
%
%   % Display the noisy image and filtered image side-by-side
%   figure, montage({noisyImage, diffusedImage});
%
%
%   References
%   ---------
%   [1] P. Perona and J. Malik., Scale-Space and Edge Detection Using
%       Anisotropic Diffusion, IEEE Trans. Pattern Anal. Mach. Intell.
%       12, 7 (July 1990), 629-639
%   [2] Chourmouzios Tsiotsios and Maria Petrou. On the choice of the
%       parameters for anisotropic diffusion in image processing, Pattern
%       Recogn. 46, 5 (May 2013), 1369-1381.
%
%   See also imdiffusefilt.

%   Copyright 2017 The MathWorks, Inc.
[I, connectivity, conductionMethod] = parseInputs(I, varargin{:});
OriginalClass = class(I);
if isfloat(I)
    % The algorithm assumes the input image is in [0,1]
    I = min(1, max(0, I));
else
    % convert to single if image is not float type
    I = im2single(I);
end
N = checkHomogeneity(I);
[gradientThreshold, numberOfIterations] = anisoest2d(I, N, connectivity, conductionMethod);
gradientThreshold = abs(convertToOriginalClass(gradientThreshold, OriginalClass));
end

%%
function [gradientThreshold, loopCount]  = anisoest2d(I, N, connectivity, conductionMethod)
loopCount=1;
Q = zeros(200,100);
while(true)
    % Estimation of gradient threshold parameter
    gradThresh = computegradientThreshold(I);
    gradientThreshold(loopCount) = gradThresh; %#ok<AGROW>
    I1 = I;
    I = anisotropicDiffusion2D(I, gradThresh, connectivity, conductionMethod);
    if isempty(N)
        % Estimation of number of iterations
        numEdgePoints = 200; %from paper
        sigma = estimateNoise(I1);%estimation of noise
        gaussFiltered = imgaussfilt(I1, sigma,'FilterSize',5);
        Edgel = findEdgeIndices(gaussFiltered, numEdgePoints);
        [edgelsNhood, alpha] = findInterPixels(I1, Edgel, sigma, numEdgePoints);
        for k = 1:numEdgePoints
            temp = edgelsNhood{k};
            temp1 = temp(:,1:2);
            temp2 = temp(:,3:4);
            Q(k,loopCount) = abs((mean2(temp1)-mean2(temp2))) - alpha*(std(temp1(:),1)+std(temp2(:),1) );
        end
        
        if (loopCount>1)
            avgQ = sum(Q);
            avgQ = avgQ/numEdgePoints;
            if (avgQ(loopCount) < avgQ(loopCount-1) || loopCount == 100)
                break;
            end
        end
        loopCount = loopCount+1;
    else
        if ~(loopCount<N)
            break;
        end
    end
    
end

end

%%
function edgel = findEdgeIndices(I, numEdgePoints)
[dimX, dimY] = size(I);
edgel = zeros(numEdgePoints,2)+min(size(I))/2;
% Consider a threshold value to get edge indices from different locations of
% an image
thresh = (1/35)*min(dimX, dimY);
gradMag = zeros(dimX, dimY);
gradM = imgradient(I);
gradMag(4:end-3, 4:end-3) = gradM(4:end-3, 4:end-3);
sortVal = sort(gradMag(:), 'descend');
[edgeX1, edgeY1] = find(gradMag == sortVal(1),1,'first');
edgel(:,1) = edgeX1(1);
edgel(:,2) = edgeY1(1);
i=2;
j=2;
while(j<=numEdgePoints && i<(dimX*dimY))
    [edgeX, edgeY] = find(gradMag == sortVal(i),1,'first');
    edgeInd(1,1) = edgeX(1);
    edgeInd(1,2) = edgeY(1);
    if (edgeInd(1,1) ==1 && edgeInd(1,2) == 1) 
        break;
    end
    Edgerep = repmat(edgeInd, size(edgel,1), 1);
    D = sqrt(sum((Edgerep-edgel).^2,2));
    if ~(any(D<thresh))
        edgel(j,:) = edgeInd;
        j = j+1;
    end
    i = i+1;
end
end

%%
function [edgelsNhood,alpha] = findInterPixels(I1, edgel, sigma, numEdgePoints)
% interpixel intensity calculation
% Consider 12 interpixel intensities for each edgel.
numInterPixels = 12;
[Bx, By] =imgradientxy(I1);
edgelsNhood = cell(1,numEdgePoints);
meanContrast = zeros(1,numEdgePoints);
for k = 1:numEdgePoints
    
    % Calculate the direction of the edge
    By1 = By(edgel(k,1), edgel(k,2));
    Bx1 = Bx(edgel(k,1), edgel(k,2));
    theta = atan(-By1/Bx1);
    interpixelX = zeros(1,numInterPixels);
    interpixelY = zeros(1,numInterPixels);
    p = 1;
    for i = -1:1
        for j = -2:2
            if(j~=0)
                interpixelX(1,p) = edgel(k,1)-j*sin(theta)-i*cos(theta);
                interpixelY(1,p) = edgel(k,2)+j*cos(theta)-i*sin(theta);
                p = p+1;
            end
        end
    end
    interPixels = zeros(1,numInterPixels);
    for j = 1:12
        tempi = fix(interpixelX(1,j));
        tempj = fix(interpixelY(1,j));
        i0 = interpixelX(1,j)-tempi;
        j0 = interpixelY(1,j)-tempj;
        din = I1(tempi,tempj);
        ain = I1(tempi,tempj+1)-I1(tempi,tempj);
        bin = I1(tempi+1,tempj)-I1(tempi,tempj);
        cin = I1(tempi,tempj)-I1(tempi,tempj+1)-I1(tempi+1,tempj)+I1(tempi+1,tempj+1);
        interPixels(j) = ain*j0 + bin*i0 + cin*i0*j0 + din;
        
    end
    edgelsNhood{k} = [interPixels(5:8); interPixels(1:4); interPixels(9:12)];
    tempEdgel = edgelsNhood{k};
    tempEdgel1 = tempEdgel(:,1:2);
    tempEdgel2 = tempEdgel(:,3:4);
    meanContrast(k) = abs(mean(tempEdgel1(:))-mean(tempEdgel2(:)));
    
end
overallMean = mean(meanContrast);
alpha = (10*sigma)/overallMean;
end

function sigma = estimateNoise(im)
% Estimate noise of an image
dimX = size(im,1);
if mod(round(dimX/5), 2) == 1
    dimN = round(dimX/5);
else
    dimN = round(dimX/5)-1;
end
nhood = ones(dimN);
J = stdfilt(im, nhood);
sigma = min(J(:));
sigma = max(sigma, 0.0001);
end

%%
function gradientThreshold = computegradientThreshold(I)
% Estimate gradient threshold
[row,col] = size(I);
gx = imgradientxy(I);
gx = abs(gx);
gx = gx./max(max(gx(:)),0.0001);
[counts, ~] = imhist(gx(:));
prob = counts/(row*col);
cdf = cumsum(prob(:));
gradientThreshold = (find(cdf > 0.9,1,'first')/(size(counts,1)-1));
end
%%
function N = checkHomogeneity(I)
im = I(4:end-3, 4:end-3);
meanIm = mean(im(:));
meansubtractIm = abs(im-meanIm);
meanIm1 = mean(meansubtractIm(:));
if (meanIm1 < sqrt(eps))
    N = 1;
else
    N = [];
end
end

%%
function [im, connectivity, conductionMethod] = parseInputs(im, varargin)
% parsing inputs other than default
narginchk(1, 5);
% persistent parser;
parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.PartialMatching = true;
parser = inputParser();
validateattributes(im,...
    {'single', 'double', 'uint8', 'uint16', 'int16'},...
    { '2d', 'real', 'nonsparse', 'nonempty'}, ...
    mfilename, 'im', 1);
parser.addParameter('Connectivity', 'maximal', @checkconnectivity);
parser.addParameter('ConductionMethod', 'exponential', @checkconductionMethodString);
parser.parse(varargin{:});
connectivity = validatestring(parser.Results.Connectivity, {'maximal', 'minimal'}, ...
    mfilename, 'Connectivity');
conductionMethod = validatestring(parser.Results.ConductionMethod, {'exponential', 'quadratic'}, ...
    mfilename, 'ConductionMethod');
if (size(im,1) < 64 || size(im,2) < 64)
    error(message('images:imdiffuseest:incorrectImageSize'));
end
end

function tf = checkconnectivity(methodString)
validateattributes(methodString, ...
    {'char', 'string'},...
    {'scalartext'},...
    mfilename, 'Connectivity');
tf = true;
end

function tf = checkconductionMethodString(methodString)
validateattributes(methodString, ...
    {'char', 'string'},...
    {'scalartext'},...
    mfilename, 'ConductionMethod');
tf = true;
end

function B = convertToOriginalClass(B, OriginalClass)
switch OriginalClass
    case 'uint8'
        B = im2uint8(B);
    case 'uint16'
        B = im2uint16(B);
    case 'int16'
        B = im2int16(B);
    case 'single'
        B = im2single(B);
        B = min(1, max(0, B));
    case 'double'
        B = min(1, max(0, B));
end
end
