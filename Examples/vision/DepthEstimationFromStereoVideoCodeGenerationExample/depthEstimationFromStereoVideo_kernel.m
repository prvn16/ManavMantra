%% Kernel for Depth Estimation From Stereo Video

%   Copyright 2013-2014 The MathWorks, Inc.

function depthEstimationFromStereoVideo_kernel(stereoParamStruct)

%#codegen

%% Re-create the Stereo Parameters
stereoParams = stereoParameters(stereoParamStruct);

%% Create Video File Readers and the Video Player
% Create System Objects for reading and displaying the video
videoFileLeft = 'handshake_left.avi';
videoFileRight = 'handshake_right.avi';

readerLeft = vision.VideoFileReader(videoFileLeft, 'VideoOutputDataType', 'uint8');
readerRight = vision.VideoFileReader(videoFileRight, 'VideoOutputDataType', 'uint8');
player = vision.DeployableVideoPlayer('Location', [20, 400]);

%% Create the People Detector
peopleDetector = vision.PeopleDetector('MinSize', [166 83]);

%% Process the Video

while ~isDone(readerLeft) && ~isDone(readerRight)
    % Read the frames.
    frameLeft = step(readerLeft);
    frameRight = step(readerRight);
    
    % Rectify the frames.
    [frameLeftRect, frameRightRect] = ...
        rectifyStereoImages(frameLeft, frameRight, stereoParams, 'OutputView', 'Valid');
    
    % Convert to grayscale.
    frameLeftGray  = rgb2gray(frameLeftRect);
    frameRightGray = rgb2gray(frameRightRect);
    
    % Compute disparity. 
    disparityMap = disparity(frameLeftGray, frameRightGray);
    
    % Reconstruct 3-D scene.
    point3D = reconstructScene(disparityMap, stereoParams);
    
    % Detect people.
    bboxes = step(peopleDetector, frameLeftGray);
    
    dispFrame = frameLeftRect(1:514, 1:719, 1:3);
    
    if ~isempty(bboxes)
        % Find the centroids of detected people.
        centroids = [round(bboxes(:, 1) + bboxes(:, 3) / 2), ...
            round(bboxes(:, 2) + bboxes(:, 4) / 2)];
        
        % Find the 3-D world coordinates of the centroids.
        centroidsIdx = sub2ind(size(disparityMap), centroids(:, 2), centroids(:, 1));
        X = point3D(:, :, 1);
        Y = point3D(:, :, 2);
        Z = point3D(:, :, 3);
        centroids3D = [X(centroidsIdx)'; Y(centroidsIdx)'; Z(centroidsIdx)'];
        
        % Find the distances from the camera in meters.
        dists = sqrt(sum(centroids3D .^ 2)) / 1000;
        
        % Display the detected people and their distances.
        % Bound the number of the bounding boxes and distances using
        % asserts, because insertObjectAnnotation requires inputs to have 
        % bounded sizes.
        assert(size(bboxes, 1) < 100);
        assert(size(dists, 2) < 100);
        
        dists(isnan(dists)) = 0;
        dispFrame = insertObjectAnnotation(dispFrame, 'rectangle', ...
            bboxes, dists);
    end
    
    % Display the frame.
    step(player, dispFrame);
end

% Clean up.
reset(readerLeft);
reset(readerRight);
release(player);

%% References
% [1] G. Bradski and A. Kaehler, "Learning OpenCV : Computer Vision with
% the OpenCV Library," O'Reilly, Sebastopol, CA, 2008.
%
% [2] Dalal, N. and Triggs, B., Histograms of Oriented Gradients for
% Human Detection. CVPR 2005.

