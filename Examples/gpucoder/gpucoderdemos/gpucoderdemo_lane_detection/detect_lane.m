function [laneFound, ltPts, rtPts] = detect_lane(frame, laneCoeffMeans, laneCoeffStds) 
% From the networks output, 
% compute left and right lane points in the image coordinates 
% The camera coordinates are described by the caltech mono camera model.

%#codegen

persistent lanenet;
if isempty(lanenet)
    lanenet = coder.loadDeepLearningNetwork('laneNet.mat', 'lanenet');
end

lanecoeffsNetworkOutput = lanenet.predict(permute(frame, [2 1 3]));

% Recover original coeffs by reversing the normalization steps

params = lanecoeffsNetworkOutput .* laneCoeffStds + laneCoeffMeans;

isRightLaneFound = abs(params(6)) > 0.5; %c should be more than 0.5 for it to be a right lane
isLeftLaneFound =  abs(params(3)) > 0.5;

vehicleXPoints = 3:30; %meters, ahead of the sensor
ltPts = coder.nullcopy(zeros(28,2,'single'));
rtPts = coder.nullcopy(zeros(28,2,'single'));

if isRightLaneFound && isLeftLaneFound
    rtBoundary = params(4:6);		
	rt_y = computeBoundaryModel(rtBoundary, vehicleXPoints);
	ltBoundary = params(1:3);
	lt_y = computeBoundaryModel(ltBoundary, vehicleXPoints);
	
	% Visualize lane boundaries of the ego vehicle
    tform = get_tformToImage;
    % map vehicle to image coordinates
    ltPts =  tform.transformPointsInverse([vehicleXPoints', lt_y']);
    rtPts =  tform.transformPointsInverse([vehicleXPoints', rt_y']);
	laneFound = true;
else
	laneFound = false;
end

end

function yWorld = computeBoundaryModel(model, xWorld)
	yWorld = polyval(model, xWorld);	
end

function tform = get_tformToImage 
% Compute extrinsics based on camera setup
yaw = 0;
pitch = 14; % pitch of the camera in degrees
roll = 0;

translation = translationVector(yaw, pitch, roll);
rotation    = rotationMatrix(yaw, pitch, roll);

% Construct a camera matrix
focalLength    = [309.4362, 344.2161];
principalPoint = [318.9034, 257.5352];
Skew = 0;

camMatrix = [rotation; translation] * intrinsicMatrix(focalLength, ...
	Skew, principalPoint);

% Turn camMatrix into 2-D homography
tform2D = [camMatrix(1,:); camMatrix(2,:); camMatrix(4,:)]; % drop Z

tform = projective2d(tform2D);
tform = tform.invert();
end

function translation = translationVector(yaw, pitch, roll)
SensorLocation = [0 0];
Height = 2.1798;    % mounting height in meters from the ground
rotationMatrix = (...
	rotZ(yaw)*... % last rotation
	rotX(90-pitch)*...
	rotZ(roll)... % first rotation
	);


% Adjust for the SensorLocation by adding a translation
sl = SensorLocation;

translationInWorldUnits = [sl(2), sl(1), Height];
translation = translationInWorldUnits*rotationMatrix;
end

%------------------------------------------------------------------
% Rotation around X-axis
function R = rotX(a)
a = deg2rad(a);
R = [...
	1   0        0;
	0   cos(a)  -sin(a);
	0   sin(a)   cos(a)];

end

%------------------------------------------------------------------
% Rotation around Y-axis
function R = rotY(a)
a = deg2rad(a);
R = [...
	cos(a)  0 sin(a);
	0       1 0;
	-sin(a) 0 cos(a)];

end

%------------------------------------------------------------------
% Rotation around Z-axis
function R = rotZ(a)
a = deg2rad(a);
R = [...
	cos(a) -sin(a) 0;
	sin(a)  cos(a) 0;
	0       0      1];
end

%------------------------------------------------------------------
% Given the Yaw, Pitch and Roll, figure out appropriate Euler
% angles and the sequence in which they are applied in order to
% align the camera's coordinate system with the vehicle coordinate
% system. The resulting matrix is a Rotation matrix that together
% with Translation vector define the camera extrinsic parameters.
function rotation = rotationMatrix(yaw, pitch, roll)

rotation = (...
	rotY(180)*...            % last rotation: point Z up
	rotZ(-90)*...            % X-Y swap
	rotZ(yaw)*...       % point the camera forward
	rotX(90-pitch)*...  % "un-pitch"
	rotZ(roll)...       % 1st rotation: "un-roll"
	);
end

function intrinsicMat = intrinsicMatrix(FocalLength, Skew, PrincipalPoint)
intrinsicMat = ...
	[FocalLength(1)  , 0                     , 0; ...
	 Skew             , FocalLength(2)   , 0; ...
	 PrincipalPoint(1), PrincipalPoint(2), 1];
end
