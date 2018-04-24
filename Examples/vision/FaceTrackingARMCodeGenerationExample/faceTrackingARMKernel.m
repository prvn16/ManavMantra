% Kernel function for 'Face Tracking on ARM Target using Code Generation' example

function videoFrameOut = faceTrackingARMKernel(videoFrame)

%#codegen
persistent faceDetector
persistent pointTracker
persistent numPts
persistent oldPoints
persistent bboxPoints

%% Initialize persistent variables
% Create the face detector object.
if isempty(faceDetector)
    faceDetector = vision.CascadeObjectDetector();
end

if isempty(numPts)
    numPts = 0;
end

if isempty(oldPoints)
    oldPoints = single([0 0]);
end

if isempty(bboxPoints)
    bboxPoints = [0 0];
end

% Get the next frame.
videoFrameGrayFULL = rgb2gray(videoFrame);

% Resize frame
decimFactor = 3;
videoFrameGray = videoFrameGrayFULL(1:decimFactor:end,1:decimFactor:end);

% Create the point tracker object.
if isempty(pointTracker)
    pointTracker = vision.PointTracker('MaxBidirectionalError', 2);
    % Initialize tracker with dummy points
    initialize(pointTracker, single([10 10]), videoFrameGray);
end

%% Detection and Tracking
if numPts < 10
    % Detection mode.
    bbox = faceDetector.step(videoFrameGray);
    assert(size(bbox, 1) < 10);

    if ~isempty(bbox)
        % Find corner points inside the detected region.
        points = detectMinEigenFeatures(videoFrameGray, 'ROI', bbox(1, :));

        % Re-initialize the point tracker.
        xyPoints = points.Location;
        numPts = size(xyPoints,1);

        if ~pointTracker.isLocked
            initialize(pointTracker, xyPoints, videoFrameGray);
        end
        step(pointTracker, videoFrameGray);
        setPoints(pointTracker, xyPoints);

        % Save a copy of the points.
        oldPoints = xyPoints;

        % Convert the rectangle represented as [x, y, w, h] into an
        % M-by-2 matrix of [x,y] coordinates of the four corners. This
        % is needed to be able to transform the bounding box to display
        % the orientation of the face.
        bboxPoints = bbox2points(bbox(1, :));

        % Convert the box corners into the [x1 y1 x2 y2 x3 y3 x4 y4]
        % format required by insertShape.
        bboxPolygon = reshape(bboxPoints', 1, []);

        % Display a bounding box around the detected face.
        videoFrameOut = insertShape(videoFrame, 'Polygon', bboxPolygon.*decimFactor);

        % Display detected corners.
        videoFrameOut = insertMarker(videoFrameOut, xyPoints.*decimFactor, '+', 'Color', [255 255 255]);
    else
        videoFrameOut = videoFrame;
    end

else
    % Tracking mode.
    [xyPoints, isFound] = step(pointTracker, videoFrameGray);
    assert(size(xyPoints, 1) < 500);
    visiblePoints = xyPoints(isFound, :);
    oldInliers = oldPoints(isFound, :);

    numPts = size(visiblePoints, 1);
    if numPts >= 10
        % Estimate the geometric transformation between the old points
        % and the new points.
        [xform, ~, visiblePoints] = estimateGeometricTransform(...
            oldInliers, visiblePoints, 'similarity', 'MaxDistance', 4);

        % Apply the transformation to the bounding box.
        bboxPoints = double(transformPointsForward(xform, bboxPoints));

        % Convert the box corners into the [x1 y1 x2 y2 x3 y3 x4 y4]
        % format required by insertShape.
        bboxPolygon = reshape(bboxPoints', 1, []);

        % Display a bounding box around the face being tracked.
        videoFrameOut = insertShape(videoFrame, 'Polygon', bboxPolygon.*decimFactor);

        % Display tracked points.
        assert(size(visiblePoints, 1) < 500);
        videoFrameOut = insertMarker(videoFrameOut, visiblePoints.*decimFactor, '+', 'Color', [255 255 255]);

        % Reset the points.
        oldPoints = visiblePoints;
        setPoints(pointTracker, oldPoints);
    else
         videoFrameOut = videoFrame;
    end
end