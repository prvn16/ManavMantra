%% Kernel for Feature Matching and Registration

function [matchedOriginal, matchedDistorted,...  
    thetaRecovered, scaleRecovered, recovered] = ...
    visionRecovertformCodeGeneration_kernel(original, distorted)

%#codegen
coder.extrinsic('featureMatchingVisualization_extrinsic')

%% Step 1: Find Matching Features Between Images
ptsOriginal  = detectSURFFeatures(original);
ptsDistorted = detectSURFFeatures(distorted);

% Extract feature descriptors.
[featuresOriginal,  validPtsOriginal]  = extractFeatures(original,  ptsOriginal);
[featuresDistorted, validPtsDistorted] = extractFeatures(distorted, ptsDistorted);

% Match features by using their descriptors.
indexPairs = matchFeatures(featuresOriginal, featuresDistorted);

% Retrieve locations of corresponding points for each image.
% Note that indexing into the object is not supported in code-generation mode.
% Instead, you can directly access the Location property.
matchedOriginal  = validPtsOriginal.Location(indexPairs(:,1),:);
matchedDistorted = validPtsDistorted.Location(indexPairs(:,2),:);

%% Step 2: Estimate Transformation
% Defaults to RANSAC
[tform, inlierDistorted, inlierOriginal] = estimateGeometricTransform(...
    matchedDistorted, matchedOriginal, 'similarity');

%% Step 3: Solve for Scale and Angle
Tinv  = tform.invert.T;

ss = Tinv(2,1);
sc = Tinv(1,1);
scaleRecovered = sqrt(ss*ss + sc*sc);
thetaRecovered = atan2(ss,sc)*180/pi;

%% Step 4: Recover the original image by transforming the distorted image.
outputView = imref2d(size(original));
recovered  = imwarp(distorted,tform,'OutputView',outputView);

%% Step 5: Display results
featureMatchingVisualization_extrinsic(original,distorted, recovered, ...
    inlierOriginal, inlierDistorted, ... 
    matchedOriginal, matchedDistorted, ...
    scaleRecovered, thetaRecovered);

