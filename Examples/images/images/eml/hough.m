function [h, theta, rho] = hough(varargin) %#codegen

% Copyright 2015 The MathWorks, Inc.

%#ok<*EMCA>

% Supported syntax in code generation
% -----------------------------------
%     [H,theta,rho] = hough(BW)
%     [H,theta,rho] = hough(BW,ParameterName,ParameterValue)
%
% Input/output specs in code generation
% -------------------------------------
% BW:    2-D, real, nonsparse, nonempty
%        logical or numeric: uint8, uint16, uint32, uint64, 
%                            int8, int16, int32, int64, single, double
%        anything that's not logical is converted first using
%           bw = BW ~= 0
%        Inf's ok, treated as 1
%        NaN's ok, treated as 1
%
% ParameterName can be 'RhoResolution' and 'Theta'
%
% ParameterValue for 'RhoResolution' must be a real, finite and 
%        positive scalar of class double. The default is 1.
%
% ParameterValue for 'Theta' must be a real, finite, nonempty vector of
%        class double. Its default value is -90:89.
%
% H:     double matrix
%        size NRHO-by-NTHETA with
%        NRHO = (2*ceil(D/RhoResolution)) + 1, where
%        D = sqrt((numRowsInBW - 1)^2 + (numColsInBW - 1)^2).
%
% THETA: row vector
%        double
%        THETA values are within the range [-90, 90) degrees
%
% RHO:   row vector
%        double
%        RHO values range from -DIAGONAL to DIAGONAL where
%        DIAGONAL = RhoResolution*ceil(D/RhoResolution).

[bw, theta, rho] = parseInputs(varargin{:});

h = standardHoughTransform(bw, theta, rho);

%--------------------------------------------------------------------------
% Parse Input Parameters
function [BW, theta, rho] = parseInputs(varargin)

narginchk(1,5);

im = varargin{1};
validateattributes(im, {'numeric','logical'}, ...
    {'real','2d','nonsparse','nonempty'}, ...
    mfilename,'BW',1);

if ~islogical(im)
    BW = im~=0;
else
    BW = im;
end

% Useful below
[M,N] = size(BW);

% Process parameter-value pairs
[theta,rhoResolution] = parseOptionalInputs(varargin{2:end});

% Validate Theta
validateTheta(theta, mfilename);

% Validate RhoResolution
validateRhoResolution(M, N, rhoResolution, mfilename);

% Compute rho from rhoResolution
D = sqrt((M - 1)^2 + (N - 1)^2);
q = ceil(D/rhoResolution(1));
nrho = 2*q + 1;
rho = linspace(-q*rhoResolution(1), q*rhoResolution(1), nrho);

%--------------------------------------------------------------------------
function [theta,rhoResolution] = parseOptionalInputs(varargin)
% Parse optional PV pairs - 'Theta' and 'RhoResolution'
coder.inline('always');
coder.internal.prefer_const(varargin);

params = struct( ...
    'Theta',        uint32(0), ...
    'RhoResolution',uint32(0));

options = struct( ...
    'CaseSensitivity',false, ...
    'StructExpand',   true, ...
    'PartialMatching',true);

optarg = eml_parse_parameter_inputs(params,options,varargin{:});

theta = eml_get_parameter_value( ...
    optarg.Theta, ...
    -90:89, ...
    varargin{:});

rhoResolution = eml_get_parameter_value( ...
    optarg.RhoResolution, ...
    1, ...
    varargin{:});

%--------------------------------------------------------------------------
% Validate 'RhoResolution' parameter
function validateRhoResolution(M, N, rhoResolution, fileName)

coder.inline('always');
coder.internal.prefer_const(M, N, rhoResolution, fileName);

inputStr = 'RhoResolution';

validateattributes(rhoResolution,{'double'}, ...
    {'real','scalar','finite','positive'}, fileName, inputStr);

normSquared = N*N + M*M;

coder.internal.errorIf(rhoResolution(1)^2 >= normSquared, ...
    'images:hough:invalidRhoRes',inputStr);

%--------------------------------------------------------------------------
% Validate 'Theta' parameter
function validateTheta(theta, fileName)

coder.inline('always');
coder.internal.prefer_const(theta, fileName);

inputStr = 'Theta';

validateattributes(theta, {'double'}, ...
    {'nonempty','real','vector','finite'}, fileName, inputStr);

minTheta = min(theta(:));
maxTheta = max(theta(:));

coder.internal.errorIf(minTheta < -90, ...
    'images:hough:invalidThetaMin', inputStr);

coder.internal.errorIf(maxTheta >= 90, ...
    'images:hough:invalidThetaMax', inputStr);

%--------------------------------------------------------------------------
% Implementation of the Standard Hough Transform (SHT) algorithm
function H = standardHoughTransform(BW,theta,rho)

coder.inline('always');
coder.internal.prefer_const(BW,theta,rho);

rhoLength   = coder.internal.indexInt(length(rho));
thetaLength = coder.internal.indexInt(length(theta));

firstRho = rho(1);
[numRow,numCol] = size(BW);

% Allocate space for H and initialize to 0
H = zeros(rhoLength,thetaLength);

% Allocate space for cos/sin lookup tables
cost = coder.nullcopy(zeros(thetaLength,1));
sint = coder.nullcopy(zeros(thetaLength,1));

% Pre-compute the sin and cos tables
for i = 1:thetaLength
    % Theta is in radians
    cost(i) = cos(theta(i) * pi/180);
    sint(i) = sin(theta(i) * pi/180);
end

% Compute the factor for converting back to the rho matrix index
slope = double(rhoLength-1) / double(rho(rhoLength) - firstRho);

% Compute the Hough transform
for n = 1:numCol
    for m = 1:numRow
        if BW(m,n) % if pixel is on
            for thetaIdx = 1:thetaLength
                % rho = x*cos(theta) + y*sin(theta)
                myRho = (n-1) * cost(thetaIdx) + (m-1) * sint(thetaIdx);
                % convert to bin index
                rhoIdx = roundAndCastInt(slope*(myRho - firstRho)) + 1;
                % accumulate
                H(rhoIdx,thetaIdx) = H(rhoIdx,thetaIdx)+1;
            end
        end
    end
end

%--------------------------------------------------------------------------
function y = roundAndCastInt(x)

coder.inline('always');
coder.internal.prefer_const(x);

% Only works if x >= 0
y = coder.internal.indexInt(x+0.5);
