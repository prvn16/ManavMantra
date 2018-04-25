function [centers, r_estimated, metric] = imfindcircles(varargin) %#codegen
%IMFINDCIRCLES Find circles using Circular Hough Transform.

%   Copyright 2015 The MathWorks, Inc.

[A, radiusRange, method, objPolarity, edgeThresh, sensitivity] = parseInputs(varargin{:});

centers = [];
r_estimated = [];
metric = [];

coder.extrinsic('sprintf');
%% Warn if the radius range is too large
if (numel(radiusRange) == 2)
    if ((radiusRange(2) > 3*radiusRange(1)) || ((radiusRange(2)-radiusRange(1)) > 100))
        coder.internal.warning('images:imfindcircles:warnForLargeRadiusRange', upper(mfilename), ...
            'Rmax < 3*Rmin','(Rmax - Rmin) < 100','[20 100]',upper(mfilename),...
            sprintf('\t[CENTERS1, RADII1, METRIC1] = IMFINDCIRCLES(A, [20 60]);\n\t[CENTERS2, RADII2, METRIC2] = IMFINDCIRCLES(A, [61 100]);'));
    end
end

%% Warn if the minimum radius is too small
if (radiusRange(1) <= 5)
    coder.internal.warning('images:imfindcircles:warnForSmallRadius', upper(mfilename));
end

%% Compute the accumulator array
[accumMatrix, gradientImg] = chaccum(A, radiusRange, 'Method',method,'ObjectPolarity', ...
    objPolarity,'EdgeThreshold',edgeThresh);

%% Check if the accumulator array is all-zero
if (~any(accumMatrix(:)))
    return;
end

%% Estimate the centers
accumThresh = 1 - sensitivity;
[centers, metric] = chcenters(accumMatrix, accumThresh);

% If no centers are found, no further processing is necessary
if (isempty(centers))
    return;
end

%% Retain circles with metric value greater than threshold corresponding to AccumulatorThreshold
idx2Keep = find(metric >= accumThresh);
centers = centers(idx2Keep,:);
metric = metric(idx2Keep,:);

% If no centers are retained, no further processing is necessary
if (isempty(centers))
    centers = []; % Make it 0x0 empty
    metric = [];
    return;
end

%% Estimate radii
if (nargout > 1)
    if (length(radiusRange) == 1)
        r_estimated = repmat(double(radiusRange),size(centers,1),1);
    else
        switch (method)
            case 'phasecode'
                r_estimated = chradiiphcode(centers, accumMatrix, radiusRange);
            case 'twostage'
                r_estimated = chradii(centers, gradientImg, radiusRange);
            otherwise
                % Should never happen
                assert(false,'images:imfindcircles:unrecognizedMethod');
        end
    end
end
end

function [A, radiusRange, method, objPolarity, edgeThresh, sensitivity] = parseInputs(varargin)

narginchk(2,Inf);

coder.inline('always');
coder.internal.prefer_const(varargin);

A = varargin{1};
allowedImageTypes = {'uint8', 'uint16', 'double', 'logical', 'single', 'int16'};
validateattributes(A,allowedImageTypes,{'nonempty',...
    'nonsparse','real'},mfilename,'A',1);
N = ndims(A);
coder.internal.errorIf(isvector(A) || N > 3,...
    'images:imfindcircles:invalidInputImage');
coder.internal.errorIf(N == 3 && (size(A,3) ~= 3),...
    'images:imfindcircles:invalidImageFormat');

radiusRangeIn = varargin{2};
if (isscalar(radiusRangeIn))
    validateattributes(radiusRangeIn,{'numeric'},{'nonnan', ...
        'nonsparse','nonempty','positive','finite','vector'},mfilename,'RADIUS_RANGE',2);
else
    validateattributes(radiusRangeIn,{'numeric'},{'integer','nonnan', ...
        'nonsparse','nonempty','positive','finite','vector'},mfilename,'RADIUS_RANGE',2);
end

coder.internal.errorIf(length(radiusRangeIn) > 2,...
    'images:imfindcircles:unrecognizedRadiusRange');
coder.internal.errorIf((length(radiusRangeIn) == 2) && (radiusRangeIn(1) > radiusRangeIn(2)),...
    'images:imfindcircles:invalidRadiusRange');

% If Rmin and Rmax are the same then set R = Rmin.
if (length(radiusRangeIn) == 2)
    if (radiusRangeIn(1) == radiusRangeIn(2))
        radiusRange = radiusRangeIn(1);
    else
        radiusRange = radiusRangeIn;
    end
else
    radiusRange = radiusRangeIn(1);
end

[method, objPolarity, edgeThresh, sensitivity] = parseOptionalInputs(varargin{3:end});

end

function [method, objPolarity, edgeThresh, sensitivity] = parseOptionalInputs(varargin)
% Parse optional PV pairs

coder.inline('always');
coder.internal.prefer_const(varargin);

params = struct( ...
    'Method',   uint32(0), ...
    'ObjectPolarity',  uint32(0),...
    'EdgeThreshold', uint32(0),...
    'Sensitivity', uint32(0)...
    );

popt = struct( ...
    'CaseSensitivity', false, ...
    'StructExpand',    true, ...
    'PartialMatching', true);

optarg       = eml_parse_parameter_inputs(params, popt, ...
    varargin{:});
methodIn       = eml_get_parameter_value(...
    optarg.Method, 'phasecode', varargin{:});
objPolarityIn  = eml_get_parameter_value(...
    optarg.ObjectPolarity, 'bright', varargin{:});
edgeThresh   = eml_get_parameter_value(...
    optarg.EdgeThreshold, [], varargin{:});
sensitivity  = eml_get_parameter_value(...
    optarg.Sensitivity, 0.85, varargin{:});

% Validate PV pairs
method = checkMethod(methodIn);
objPolarity = checkObjectPolarity(objPolarityIn);
checkEdgeThreshold(edgeThresh);
checkSensitivity(sensitivity)

end

function method = checkMethod(methodIn)

coder.inline('always');
method = validatestring(methodIn, {'twostage','phasecode'}, ...
    mfilename, 'Method');
end

function objectPolarity = checkObjectPolarity(objectPolarityIn)

coder.inline('always');
objectPolarity = validatestring(objectPolarityIn, {'bright','dark'}, ...
    mfilename, 'ObjectPolarity');
end

function checkEdgeThreshold(ET)

coder.inline('always');
validateattributes(ET,{'numeric'},{'nonnan',...
    'finite'},mfilename,'EdgeThreshold',5);
if (~isempty(ET))
    coder.internal.errorIf( (numel(ET)  == 1) && (ET > 1 || ET < 0),...
        'images:imfindcircles:outOfRangeEdgeThreshold');
    coder.internal.errorIf(numel(ET) ~= 1, ...
        'images:imfindcircles:invalidEdgeThreshold');
end

end

function checkSensitivity(s)

coder.inline('always');
validateattributes(s,{'numeric'},{'nonempty','nonnan', ...
    'finite','scalar'},mfilename,'Sensitivity');
coder.internal.errorIf (s > 1 || s < 0 ,...
    'images:imfindcircles:outOfRangeSensitivity');
end
