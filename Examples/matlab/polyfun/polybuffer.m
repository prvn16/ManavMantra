function pshape = polybuffer(XY, type, dist, varargin)
% POLYBUFFER Create buffer zone around points or lines 
%
% PG = POLYBUFFER(XY, 'points', d) returns a polyshape object containing a
% buffer zone for the x- and y-coordinates defined in the 2-column matrix
% XY. The buffer zone is the union of circular regions centered at each 
% point in XY with a radius of d. d must be a positive scalar.
%
% PG = POLYBUFFER(XY, 'lines', d) returns a buffer zone for the lines  
% specified by the x- and y-coordinates in XY. The distance d is applied to 
% both sides of each line segment to create the buffer.
%
% PG = POLYBUFFER(XY, 'lines', d, 'JointType', JT) specifies how the joints
% of line segments are treated. JT can be one of the following:
%   'round' (default) - Round out joints
%   'square' - Square off joints
%   'miter' - Preserve joint angles
%
% PG = POLYBUFFER(XY, 'lines', d, 'JointType', 'miter', 'MiterLimit', LIM)
% specifies a miter limit for line segment joints, which is the maximum
% allowable ratio between the distance a joint vertex is moved and the 
% buffer distance d. LIM must be greater than or equal to 2. 
%
% Example: Create a buffer zone for a line with 2 segments
%   XY = [0 0; 1 1; 2 1];
%   buff = polybuffer(XY, 'Lines', 0.2);
%   plot(buff)
%
% See also polyshape, polyshape/polybuffer, convhull

% Copyright 2017-2018 The MathWorks, Inc.

%minimum 3 positional input arguments
if nargin==0
    error(message('MATLAB:polybuffer:missing1stArgument'));
elseif nargin==1
    error(message('MATLAB:polybuffer:missing2ndArgument'));
elseif nargin==2
    error(message('MATLAB:polybuffer:missing3rdArgument'));
end

%check 3 input arguments in order
points = checkPointArray(XY);
    
cmpLength = max(length(type), 1);
if ~(ischar(type) || isstring(type))
    error(message('MATLAB:polybuffer:secondInputError'));
elseif (strncmpi(type, 'lines', cmpLength))
    is_lines = true;
elseif (strncmpi(type, 'points', cmpLength))
    is_lines = false;
else
    error(message('MATLAB:polybuffer:secondInputError'));
end

[dist, is_clean] = checkScalar(dist);
if ~is_clean || dist <= 0
    error(message('MATLAB:polybuffer:bufferDistanceError'));
end

if is_lines
    %this works [1 1; 2 2; nan nan; 3 3; nan nan; nan nan]

    %jointype: 1 square, 2 round, 3 miter
    %endtype: 2 ClosedLine, 3 OpenButt, 4 OpenSquare, 5 OpenRound
    [JT, miterLimit] = checkNameValue(varargin{:});
    pts = matlab.internal.polygon.builtin.lineBuffer(points, dist, JT, ...
        miterLimit, 5);
    if size(pts, 1) < 3
        pshape = polyshape();
    else
        PG = polyshape(pts, 'SolidBoundaryOrientation', 'cw', 'Simplify', false);
        pshape = setSimplified(PG, true);
    end
else
    if numel(varargin) > 0
        error(message('MATLAB:polybuffer:nameValueNotAllowed'));
    end
    %remove repeating points for better performance
    points = points(~isnan(points(:,1)), :);
    points = uniquetol(points, 'ByRows', dist*1.0e-8);
    n = size(points, 1);
    q = polyshape.empty(n, 0);
    for i=1:n
        q(i) = nsidedpoly(180, 'center', points(i, :), 'radius', dist);
    end
    if numel(q) > 1
        pshape = union(q);
    elseif numel(q) == 1
        pshape = q;
    else
        %polybuffer([nan nan], 'points', 1) returns an empty shape
        pshape = polyshape();
    end
end

end
 
%-----------------------------------------------------------------
function [d, is_clean] = checkScalar(dist)
d = 0;
is_clean = false;
if isnumeric(dist) && isscalar(dist)
    if issparse(dist)
        error(message('MATLAB:polybuffer:sparseError'));
    end
    if ~isfinite(dist) || ~isreal(dist)
        return;
    else
        d = double(dist);
    end
else
    return;
end
is_clean = true;
end

%-----------------------------------------------------------------
%check xy coordinates
function OUT = checkPointArray(XY)
if issparse(XY)
    error(message('MATLAB:polybuffer:sparseError'));
end

if ~isnumeric(XY)
    error(message('MATLAB:polybuffer:coordError'));
end
if numel(XY) == 0
    error(message('MATLAB:polybuffer:coordEmptyError'));
end
if numel(size(XY)) ~= 2 || size(XY, 2) ~= 2
    error(message('MATLAB:polybuffer:coord2ColError'));
end
X = XY(:, 1);
Y = XY(:, 2);
if ~isnumeric(X) || ~isnumeric(Y) || ~isreal(X) || ~isreal(Y) || ...
        any(isinf(X)) || any(isinf(Y))
    error(message('MATLAB:polybuffer:coordError'));
end

if any(isnan(X) ~= isnan(Y))
    error(message('MATLAB:polybuffer:nanInconsistent'));
end

%all passed, return double array
OUT = [double(X) double(Y)];
end

%-----------------------------------------------------------------
function [JT, miterLimit] = checkNameValue(varargin)
JT = 2; %default: round
miterLimit = 3.0;

ninputs = numel(varargin);
if ninputs == 0
    return 
elseif mod(ninputs, 2) ~= 0
    error(message('MATLAB:polybuffer:nameValueError'));
end

%add 'EndType' in the future
jointTypes = {'square', 'round', 'miter'};
foundML = false;
for k=1:2:ninputs
    if ~(isstring(varargin{k}) || ischar(varargin{k}))
        error(message('MATLAB:polybuffer:bufferParameter'));
    else
        cmpLength = max(length(varargin{k}), 1);
        i = k+1;
        if (strncmpi(varargin{k}, 'JointType', cmpLength))
            foundJT = 0;
            if isstring(varargin{i}) || ischar(varargin{i})
                cmpLength = max(length(varargin{i}), 1);
                for j=1:numel(jointTypes)
                    if (strncmpi(varargin{i}, jointTypes{j}, cmpLength))
                        foundJT = j;
                        JT = foundJT;
                        break;
                    end
                end
            end
            if foundJT == 0
                error(message('MATLAB:polybuffer:bufferJointError'));
            end
        elseif (strncmpi(varargin{k}, 'MiterLimit', cmpLength))
            [miterLimit, is_clean] = checkScalar(varargin{i});
            if ~is_clean
                error(message('MATLAB:polybuffer:bufferMiterValue'));
            end
            foundML = true;
            %check MiterLimit
            if miterLimit < 2
                error(message('MATLAB:polybuffer:bufferMiterValue'));
            end            
        else
            error(message('MATLAB:polybuffer:bufferParameter'));
        end
    end
end

%check consistency for MiterLimit
if foundML && JT ~= 3
    error(message('MATLAB:polybuffer:bufferMiterType'));
end
end
