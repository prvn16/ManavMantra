
function FaceTrackingKLTpackNGo_kernel()
% This is a modified version of the example
% <matlab:web(fullfile(docroot,'vision','examples','face-detection-and-tracking-using-the-klt-algorithm.html'));
% Face Detection and Tracking Using the KLT Algorithm>. The original
% example has been modified so that this function can generate standalone
% executable. To learn how to modify the MATLAB code to make it codegen
% compatible, you can look at example
% <matlab:web(fullfile(docroot,'vision','ug','code-generation-for-feature-matching-and-registration.html')); Introduction to Code Generation with Feature Matching and Registration>
% This example shows how to automatically detect and track a face using
% feature points. The approach in this example keeps track of the face even
% when the person tilts his or her head, or moves toward or away from the
% camera.
%
%   Copyright 2012 The MathWorks, Inc.

%#codegen
%% Detect a Face
% First, you must detect the face. Use the |vision.CascadeObjectDetector|
% System Object(TM) to detect the location of a face in a video frame. The
% cascade object detector uses the Viola-Jones detection algorithm and a
% trained classification model for detection. By default, the detector is
% configured to detect faces, but it can be used to detect other types of
% objects. 

% Create a cascade detector object.
faceDetector = vision.CascadeObjectDetector();

coder.extrinsic('ismac'); 
isMacComputer = coder.const(ismac);
% Read a video frame and run the face detector.
if isMacComputer
    % Compressed avi is not supported for codegen on Mac OS X(R)
    videoFileReader = vision.VideoFileReader('tilted_face_uncomp.avi');
else
    % Use compressed avi on Windows(R) and Linux(R)
    videoFileReader = vision.VideoFileReader('tilted_face.avi');
end
videoFrame      = step(videoFileReader);
bbox            = single(step(faceDetector, videoFrame));

% Draw the returned bounding box around the detected face.
assert(size(bbox, 1) < 10);
videoFrame = insertShape(videoFrame, 'Rectangle', bbox);
%%%%%%figure; imshow(videoFrame); title('Detected face');

% Convert the first box into a list of 4 points
% This is needed to be able to visualize the rotation of the object.
bboxPoints = bbox2points(bbox(1, :));

%%
% To track the face over time, this example uses the Kanade-Lucas-Tomasi
% (KLT) algorithm. While it is possible to use the cascade object detector
% on every frame, it is computationally expensive. It may also fail to
% detect the face, when the subject turns or tilts his head. This
% limitation comes from the type of trained classification model used for
% detection. The example detects the face only once, and then the KLT
% algorithm tracks the face across the video frames. 

%% Identify Facial Features To Track
% The KLT algorithm tracks a set of feature points across the video frames.
% Once the detection locates the face, the next step in the example
% identifies feature points that can be reliably tracked.  This example
% uses the standard, "good features to track" proposed by Shi and Tomasi. 

% Detect feature points in the face region.
points = detectMinEigenFeatures(rgb2gray(videoFrame), 'ROI', bbox);

%% Initialize a Tracker to Track the Points
% With the feature points identified, you can now use the
% |vision.PointTracker| System Object(TM) to track them. For each point in
% the previous frame, the point tracker attempts to find the corresponding
% point in the current frame. Then the |estimateGeometricTransform|
% function is used to estimate the translation, rotation, and scale between
% the old points and the new points. This transformation is applied to the
% bounding box around the face.

% Create a point tracker and enable the bidirectional error constraint to
% make it more robust in the presence of noise and clutter.
pointTracker = vision.PointTracker('MaxBidirectionalError', 2);

% Initialize the tracker with the initial point locations and the initial
% video frame.
points = points.Location;
initialize(pointTracker, points, videoFrame);

% Initialize a Video Player to display the results.
videoPlayer  = vision.DeployableVideoPlayer;

%% Track the Face
% Track the points from frame to frame, and use
% |estimateGeometricTransform| function to estimate the motion of the face.

% Make a copy of the points to be used for computing the geometric
% transformation between the points in the previous and the current frames.
oldPoints = points;

while ~isDone(videoFileReader)
    % get the next frame.
    videoFrame = step(videoFileReader);

    % Track the points. Note that some points may be lost.
    [points, isFound] = step(pointTracker, videoFrame);
    visiblePoints = points(isFound, :);
    oldInliers = oldPoints(isFound, :);
    
    if size(visiblePoints, 1) >= 2 % need at least 2 points
        
        % Estimate the geometric transformation between the old points
        % and the new points and eliminate outliers.
        [xform, oldInliers, visiblePoints] = estimateGeometricTransform(...
            oldInliers, visiblePoints, 'similarity', 'MaxDistance', 4); %#ok<ASGLU>
        
        % Apply the transformation to the bounding box points.
        bboxPoints(:) = transformPointsForward(xform, bboxPoints);
                
        % Insert a bounding box around the object being tracked.
        bboxPolygon = reshape(bboxPoints', 1, []);
        videoFrame = insertShape(videoFrame, 'Polygon', bboxPolygon, ...
            'LineWidth', 2);
                
        % Display tracked points.
        assert(size(visiblePoints, 1) < 500);
        videoFrame = insertMarker(videoFrame, visiblePoints, '+', ...
            'Color', [255 255 255]);       
        
        % Reset the points.
        oldPoints = visiblePoints;
        setPoints(pointTracker, oldPoints);        
    end
    
    % Display the annotated video frame using the video player.
    step(videoPlayer, videoFrame);
end

% Clean up.
release(videoFileReader);
release(videoPlayer);
release(pointTracker);

end

