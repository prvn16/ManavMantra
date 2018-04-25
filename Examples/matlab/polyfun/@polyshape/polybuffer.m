function PG = polybuffer(pshape, d, varargin)
% POLYBUFFER Place a buffer around a polyshape
%
% PG = POLYBUFFER(pshape, d) expands the boundaries of a polyshape by a 
% distance d. When d is positive, solid boundaries grow a  distance d along
% the perimeter, and hole boundaries shrink by a distance of d. When d is 
% negative, solid boundaries shrink and hole boundaries grow.
% 
% PG = POLYBUFFER(pshape, d, 'JointType', TYPE) specifies how the 
% intersection of boundary segments, or joints, are treated. TYPE can be 
% one of the following:
%   'round' (default) - Round out boundary joints
%   'square' - Square off boundary joints
%   'miter' - Preserve boundary joints
% polybuffer only applies the 'JointType' parameter to solid boundaries
% when d>0 or hole boundaries when d<0.
%
% PG = POLYBUFFER(___, 'MiterLimit',LIM) specifies a Miter limit, which is 
% the maximum allowable ratio between the distance a joint vertex is moved 
% and the buffer distance d. The 'JointType' parameter value must be 
% specified as 'miter' when using this name-value pair. LIM must be greater
% than or equal to 2. 
%
% Example: Create a buffer with squared-off joints
%   quad = polyshape([0 0 1 3], [0 3 3 0]);
%   quadbuff = polybuffer(quad, 1, 'JointType', 'square');
%   plot([quad quadbuff])
%
% See also boundary, centroid, intersect, translate, polyshape

% Copyright 2016-2017 The MathWorks, Inc.

narginchk(2, inf);
n = polyshape.checkArray(pshape);
d = polyshape.checkScalarValue(d, 'MATLAB:polyshape:bufferDistanceError');

ninputs = numel(varargin);
if mod(ninputs, 2) ~= 0
    error(message('MATLAB:polyshape:nameValuePairError'));
end

args = {'JointType', 'round'};
jointTypes = {'square', 'miter', 'round'};
foundML = false;
foundJT = 0;
for k=1:2:ninputs
    if ~(isstring(varargin{k}) || ischar(varargin{k}))
        error(message('MATLAB:polyshape:bufferParameter'));
    else
        cmpLength = max(length(varargin{k}), 1);
        i = k+1;
        if (strncmpi(varargin{k}, 'JointType', cmpLength))
            args{1} = 'JointType';
            foundJT = 0;
            if isstring(varargin{i}) || ischar(varargin{i})
                cmpLength = max(length(varargin{i}), 1);
                for j=1:numel(jointTypes)
                    if (strncmpi(varargin{i}, jointTypes{j}, cmpLength))
                        foundJT = j;
                        args{2} = jointTypes{j};
                        break;
                    end
                end
            end
            if foundJT == 0
                error(message('MATLAB:polyshape:bufferJointError'));
            end
        elseif (strncmpi(varargin{k}, 'MiterLimit', cmpLength))
            v = polyshape.checkScalarValue(varargin{i}, 'MATLAB:polyshape:bufferMiterValue');
            args{3} = 'MiterLimit';
            args{4} = v;
            foundML = true;
            %check MiterLimit
            if v < 2
                error(message('MATLAB:polyshape:bufferMiterValue'));
            end
        else
            error(message('MATLAB:polyshape:bufferParameter'));
        end
    end
end

%check consistency for MiterLimit
if foundML && (foundJT ~= 2)
    error(message('MATLAB:polyshape:bufferMiterType'));
end

PG = pshape;
if abs(d) <= eps*10
    return;
end
for i=1:numel(pshape)
    if pshape(i).isEmptyShape()
        continue;
    end
    PG(i).Underlying = offset(pshape(i).Underlying, d, args{:});
    PG(i).SimplifyState = 1;
end
