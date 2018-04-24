% Kernel function for 'Face Detection on ARM Target using Code Generation' example

function outRGB = faceDetectionARMKernel(inRGB)

%#codegen
persistent faceDetector

decimFactor = 3;
inRows = size(inRGB, 1);
inCols = size(inRGB, 2);
numRows_MaxFaceSize = floor(inRows/(decimFactor*2));
numCols_MaxFaceSize = floor(inCols/(decimFactor*2));

% Instantiate system object
if isempty(faceDetector)
    faceDetector = vision.CascadeObjectDetector('MinSize', [20 20], ...
        'MaxSize', [numRows_MaxFaceSize numCols_MaxFaceSize]);
end

inGray = rgb2gray(inRGB);

% Create uninitialized memory in generated code
outRGB = coder.nullcopy(inRGB);

% Resize input image 
inGray_decim = inGray(1:decimFactor:end,1:decimFactor:end);

% Detect faces and create boundiong boxes around detected faces
bbox = single(step(faceDetector, inGray_decim));

% Limit the number of faces to be detected in an image.  insertShape
% requires that bbox signal must be bounded
assert(size(bbox, 1) < 10);

% Insert rectangle shape for bounding box
outRGB(:) = insertShape(inRGB, 'Rectangle', bbox.*decimFactor);
