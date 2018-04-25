function varargout = intersect(subject, varargin)
% INTERSECT Find the intersection of two polyshapes or a polyshape and a
% line
%
% PG = INTERSECT(pshape1, pshape2) returns the intersection of two 
% polyshapes. pshape1 and pshape2 must have compatible array sizes.
%
% PG = INTERSECT(P) returns the intersection of all polyshape objects in
% the vector of polyshapes P. The intersection contains the regions 
% overlapped by all elements of P.
%
% [PG, shapeId, vertexId] = INTERSECT(pshape1, pshape2) returns the vertex
% mapping between the vertices in PG and the vertices in the polyshapes
% pshape1 and pshape2. shapeId and vertexId are both column vectors with 
% the same number of rows as in the Vertices property of PG. If an element 
% of shapeId is 1, the corresponding vertex in PG is from pshape1. If an
% element of shapeId is 2, the corresponding vertex in PG is from pshape2.
% If an element of shapeId is 0, the corresponding vertex in PG is created 
% by the intersection of pshape1 and pshape2. vertexId contains the row 
% numbers in the Vertices properties for pshape1 or pshape2. An element 
% of vertexId is 0 when the corresponding vertex in PG is created by the 
% intersection. The vertex mapping output arguments are only supported when 
% pshape1 and pshape2 are scalars.
%
% [PG, shapeId, vertexId] = INTERSECT(P) returns the vertex mapping between
% the vertices in PG and the vertices in the polyshapes vector P.
%
% [inside, outside] = INTERSECT(pshape, lineseg) returns the line segments
% that are inside and outside of a polyshape. lineseg is a 2-column matrix
% whose first column defines the x-coordinates of the input line segments
% and the second column defines the y-coordinates. lineseg must have a
% least two rows.
%
% Example: Find the intersection of two squares
%   p = nsidedpoly(4, 'sideLength', 1, 'center', [0 1]);
%   q = nsidedpoly(4, 'sideLength', 2);
%   [PG, sId, vId] = intersect(p, q);
%   hp = plot(p);
%   hp.FaceColor = 'none';
%   axis equal; hold on
%   hq = plot(q);
%   hq.FaceColor = 'none';
%   hPG = plot(PG);
%
% See also subtract, union, xor, polyshape

% Copyright 2016-2018 The MathWorks, Inc.

narginchk(1, 2);
ns = polyshape.checkArray(subject);
if nargin==1
    nargoutchk(0, 3);
    if isscalar(subject)
        %special treatment here. booleanVec returns an empty shape if
        %subject is a scalar shape
        [PG, shapeId, vertexId] = booleanFun(subject, subject, @intersect);
        shapeId(shapeId==2) = 1;
    else
        [PG, shapeId, vertexId] = booleanVec(subject, @intersectvec);
    end
    varargout{1} = PG;
    if nargout >= 2
        varargout{2} = shapeId;
    end
    if nargout == 3
        varargout{3} = vertexId;
    end
else
    clip = varargin{1};
    pip = isa(clip, 'polyshape');
    if (pip)
        nargoutchk(0, 3);
        nc = polyshape.checkArray(clip);

        if ~(isscalar(subject) && isscalar(clip)) && nargout > 1
            error(message('MATLAB:polyshape:noVertexMapping'));
        end
        [PG, shapeId, vertexId] = booleanFun(subject, clip, @intersect);
        varargout{1} = PG;
        if nargout >= 2
            varargout{2} = shapeId;
        end
        if nargout == 3
            varargout{3} = vertexId;
        end
    elseif isnumeric(clip)
        if numel(subject) ~= 1
            error(message('MATLAB:polyshape:scalarPolyshapeError'));
        end
        nargoutchk(0, 2);
        
        param = struct;
        param.allow_inf = false;
        param.allow_nan = false; %allow 1 polyline as input
        param.one_point_only = false;
        param.errorOneInput = 'MATLAB:polyshape:lineInputError';
        param.errorTwoInput = 'MATLAB:polyshape:lineInputError';
        param.errorValue = 'MATLAB:polyshape:linePointValue';
        [X, Y] = polyshape.checkPointArray(param, clip);
        if numel(X) < 2
            error(message('MATLAB:polyshape:lineMin2Points'));
        end
        if subject.isEmptyShape()
            out1 = zeros(0, 2);
            out2 = [X Y];
        else
            [out1, out2] = lineintersect(subject.Underlying, [X Y]);
        end

        varargout{1} = out1;
        if nargout == 2
            varargout{2} = out2;
        end
    else
        error(message('MATLAB:polyshape:intersectInputError'));
    end
end
