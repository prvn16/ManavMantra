function s = integralParseArgs(varargin)
%INTEGRALPARSEARGS  Parse optional arguments to INTEGRAL.

%   Copyright 2007-2013 The MathWorks, Inc.

p = inputParser;
p.addParamValue('AbsTol',1e-10,@validateAbsTol);
p.addParamValue('RelTol',1e-6,@validateRelTol);
p.addParamValue('Waypoints',[],@validateWaypoints);
p.addParamValue('ArrayValued',false,@validateArrayValued);
p.parse(varargin{:});
s = p.Results;
s.ArrayValued = logical(s.ArrayValued);
s.Rule = Gauss7Kronrod15;
s.InitialIntervalCount = 10;
s.Persistence = 1;
s.ThrowOnFail = false;

%--------------------------------------------------------------------------

function p = validateAbsTol(x)
if ~(isfloat(x) && isscalar(x) && isreal(x) && x >= 0)
    error(message('MATLAB:integral:invalidAbsTol'));
end
p = true;

%--------------------------------------------------------------------------

function p = validateRelTol(x)
if ~(isfloat(x) && isscalar(x) && isreal(x) && x >= 0)
    error(message('MATLAB:integral:invalidRelTol'));
end
p = true;

%--------------------------------------------------------------------------

function p = validateWaypoints(x)
if ~(isvector(x) || isequal(x,[])) || any(~isfinite(x))
    error(message('MATLAB:integral:invalidWaypoints'));
end
p = true;

%--------------------------------------------------------------------------

function p = validateArrayValued(x)
if ~(isscalar(x) && ...
        (islogical(x) || ...
        (isnumeric(x) && (x == 0 || x == 1))))
    error(message('MATLAB:integral:invalidArrayValued'));
end
p = true;

%--------------------------------------------------------------------------
