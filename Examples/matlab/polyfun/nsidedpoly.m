function PG = nsidedpoly(N, varargin)
%NSIDEDPOLY Create an n-sided regular polygon
%
% PG = NSIDEDPOLY(n) creates a polyshape object that is a regular polygon 
% with n sides of equal length. n is an integer greater than or equal to 3.
% The default center is at the point (0, 0) and the default radius of the 
% circumscribed circle of the polygon is 1.
%
% PG = NSIDEDPOLY(n, 'Center', C) additionally specifies the x- and 
% y-coordinates of the center point of the polygon. C is a 1x2 row vector 
% of the form [x y].
%
% PG = NSIDEDPOLY(__, 'Radius', R) specifies the radius of the circumscribed
% circle of the polygon. R must be a positive, real scalar. This name-value
% pair cannot be specified when the 'SideLength' parameter is specified. 
%
% PG = NSIDEDPOLY(__, 'SideLength', L) specifies the length of each side of 
% the polygon. L must be a positive, real scalar. This name-value pair 
% cannot be specified when the 'Radius' parameter is specified. 

% Copyright 2017 The MathWorks, Inc.

%check number of sides
arg1 = N;
if ~isnumeric(arg1) || ~isreal(arg1) || ~isscalar(arg1) || ~isfinite(arg1)
    error(message('MATLAB:nsidedpoly:numSidesError'));
else
    N = double(floor(arg1));
    if ~isequal(N, arg1) || N < 3
        error(message('MATLAB:nsidedpoly:numSidesError'));
    end
end

%angular increment
incr_a = 2*pi/N;

%other parameters
side = 0;
radius = 1;
center = [0 0];

ninputs = numel(varargin);
if mod(ninputs, 2) ~= 0
    error(message('MATLAB:nsidedpoly:nameValueError'));
end

specified_radius = false;
specified_side = false;
%Name/Value pairs
next_arg = 1;
while (next_arg <= ninputs)
    name = varargin{next_arg};
    if ~isstring(name) && ~ischar(name)
        error(message('MATLAB:nsidedpoly:unknownNameError'));
    else
        name = string(name);
        if length(name) ~= 1
            error(message('MATLAB:nsidedpoly:unknownNameError'));
        end
        name = char(name);
    end
    next_arg = next_arg+1;
    value = varargin{next_arg};
    ns = max([length(name) 1]);
    if (strncmpi(name, 'Radius', ns))
        specified_radius = true;
        if numel(value) ~= 1 || ~isnumeric(value)|| ~isscalar(value) || ...
                ~isreal(value) || ~isfinite(value) || value <= 0
            error(message('MATLAB:nsidedpoly:radiusError'));
        end
        radius = double(value);
    elseif (strncmpi(name, 'SideLength', ns))
        specified_side = true;
        if numel(value) ~= 1 || ~isnumeric(value)|| ~isscalar(value) || ...
                ~isreal(value) || ~isfinite(value) || value <= 0
            error(message('MATLAB:nsidedpoly:sideError'));
        end
        side = double(value);
    elseif (strncmpi(name, 'Center', ns))
        if numel(value) ~= 2 || ~isrow(value) || ~isreal(value) || ...
                ~isnumeric(value) || any(~isfinite(value))
            error(message('MATLAB:nsidedpoly:centerError'));
        end
        center = double(value);
    else
        error(message('MATLAB:nsidedpoly:unknownNameError'));
    end
    next_arg = next_arg+1;
end

if specified_side && specified_radius
    error(message('MATLAB:nsidedpoly:radiusSideError'));
end

if side > 0
    %compute the radius
    radius = side*0.5/sin(incr_a*0.5); 
end
testRadius(radius, specified_side);

%start at lower left corner
start_a = pi*1.5-incr_a*0.5;
X = zeros(N,1);
Y = zeros(N,1);
for i=1:N
    angle = start_a - (i-1)*incr_a;
    X(i) = cos(angle)*radius + center(1);
    Y(i) = sin(angle)*radius + center(2);
end

PG = polyshape(X, Y, 'SolidBoundaryOrientation', 'cw', 'Simplify', false);
if numsides(PG) == N
    PG = setSimplified(PG, true);
else
    %invalid, could be a combination of radius and center location
    error(message('MATLAB:nsidedpoly:invalidParameterError'));
end
end

%----------------------------------------------
function testRadius(radius, specified_side)
    %trying to pinpoint the error
    if specified_side
        theName = 'SideLength';
    else
        theName = 'Radius';
    end
    r2 = radius*radius;
    if  r2 == 0
        error(message('MATLAB:nsidedpoly:rsTooSmall', theName));
    elseif r2 == Inf
        error(message('MATLAB:nsidedpoly:rsTooLarge', theName));
    end
end