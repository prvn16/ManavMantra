function r_estimated = chradiiphcode(varargin) %#codegen
%CHRADIIPHCODE Estimate circle radius for Circular Hough Transform using the Phase-Coding method

%   Copyright 2015 The MathWorks, Inc.

[centers, accumMatrix, radiusRange] = parseInputs(varargin{:});

%% Check if accumulator array is complex
if (isreal(accumMatrix))
    coder.internal.warning('images:imfindcircles:realAccumArrayForPhaseCode');
end

%% Decode the phase to get the radius estimate
cenPhase = angle(accumMatrix(sub2ind(size(accumMatrix),round(centers(:,2)),round(centers(:,1)))));
lnR = log(radiusRange);
r_estimated = exp(((cenPhase + pi)/(2*pi)*(lnR(end) - lnR(1))) + lnR(1)); % Inverse of modified form of Log-coding from Eqn. 8 in [1]

end

function [centers, accumMatrix, radiusRange] = parseInputs(varargin)

narginchk(3,3);

coder.inline('always');
coder.internal.prefer_const(varargin);

centers = varargin{1};
accumMatrix = varargin{2};
radiusRangeIn = varargin{3};

% Validate PV pairs
checkCenters(centers);
checkAccumArray(accumMatrix);
checkRadiusRange(radiusRangeIn);
validateCenters(centers,accumMatrix)

radiusRange = double(radiusRangeIn);

end

function checkCenters(centers)

coder.inline('always');
validateattributes(centers,{'numeric'},{'nonsparse','real','positive', ...
    'nonempty','ncols',2}, mfilename,'centers',1);
end

function checkAccumArray(accumMatrix)

coder.inline('always');
validateattributes(accumMatrix,{'numeric'},{'nonempty',...
    'nonsparse','2d'},mfilename,'H',2);
end

function checkRadiusRange(radiusRange) % Radius range has to be a 2-element vector with r(2) > r(1)

coder.inline('always');
validateattributes(radiusRange,{'numeric'},{'nonnan','nonsparse',...
    'integer','positive','finite','vector','numel',2},...
    mfilename,'R',3);
coder.internal.errorIf(length(radiusRange) > 2,...
    'images:imfindcircles:unrecognizedRadiusRange');

coder.internal.errorIf(radiusRange(1) >= radiusRange(2),...
    'images:imfindcircles:invalidRadiusRange');

end

function validateCenters(centers,accumMatrix)

coder.inline('always');
coder.internal.errorIf(~(all(centers(:,1) <= size(accumMatrix,2)) && ...
    all(centers(:,2) <= size(accumMatrix,1))),...
    'images:imfindcircles:outOfBoundCenters');

end
