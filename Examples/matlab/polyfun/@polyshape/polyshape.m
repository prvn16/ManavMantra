classdef (Sealed, InferiorClasses = {?matlab.graphics.axis.Axes, ?matlab.ui.control.UIAxes}) polyshape < matlab.mixin.CustomDisplay
% POLYSHAPE Create polyshape object
%
% A polyshape is a 2-D polygon that can consist of one or more solid regions,
% and can have holes. polyshape objects are created from the x- and 
% y-coordinates that describe the polygon's boundaries.   
%
% Boundaries that make up a polyshape should have no self-intersections or 
% intersections with other boundaries, and all boundaries should be properly 
% nested. Otherwise, the polyshape is ill-defined, and can lead to inaccurate
% or unexpected results.
%
% PG = POLYSHAPE(X, Y) creates a polyshape object from 2-D vertices given
% by two vectors X and Y. X and Y must have the same size.
%
% PG = POLYSHAPE(P) creates a polyshape from 2-D points contained in the
% 2-column array P. 
%
% PG = POLYSHAPE({X1, X2, ..., Xn}, {Y1, Y2, ..., Yn}) creates a polyshape 
% with n boundaries from two cell arrays. Each cell array contains n vectors, 
% where each Xi contains the x-coordinates and Yi contains the y-coordinates
% of the i-th boundary.
%
% PG = POLYSHAPE(..., 'SolidBoundaryOrientation', DIR) specifies the 
% direction convention for determining solid versus hole boundaries. DIR 
% can be one of the following:
%  'auto' (default) - Automatically determine direction convention
%  'cw' - Clockwise vertex direction defines solid boundaries
%  'ccw' - Counterclockwise vertex direction defines solid boundaries
%
% This name-value pair is typically only specified when creating a polyshape 
% from data that was produced by other software that uses a particular 
% convention.  
%
% PG = POLYSHAPE(..., 'Simplify', tf) specifies how ill-defined polyshape 
% boundaries are handled. tf can be one of the following:
%  true (default) - Automatically alter boundary vertices to create a 
%                   well-defined polygon
%  false - Do not alter boundary vertices even though the polyshape is 
%          ill-defined. This may lead to inaccurate or unexpected results.
%
% PG = POLYSHAPE() creates a polyshape object with no vertices.
%
% Polyshape properties:
%   Vertices      - 2-D polyshape vertices
%   NumRegions    - Number of regions in the polyshape
%   NumHoles      - Number of holes in the polyshape
%
% Methods for modifying a polyshape:
%   addboundary     - Add boundaries to a polyshape
%   rmboundary	    - Remove boundaries in a polyshape
%   rmholes         - Remove all the holes in a polyshape
%   rmslivers       - Clean up degeneracies in a polyshape
%   simplify        - Fix degeneracies and intersections in a polyshape 
%
% Methods for querying a polyshape:
%   ishole          - Determine if a boundary is a hole 
%   issimplified    - Determine if a polyshape is simplified
%   numsides        - Find the total number of sides in a polyshape
%   numboundaries   - Find the total number of boundaries in a polyshape 
%
% Methods for geometric information:
%   area            - Find the area of a polyshape 
%   boundary        - Get the x- and y-coordinates of a boundary 
%   boundingbox	    - Find the bounding box of a polyshape 
%   centroid	    - Find the centroid of a polyshape 
%   convhull	    - Find the convex hull of a polyshape 
%   holes           - Convert all holes in a polyshape into an array of polyshapes 
%   isinterior	    - Determine if a point is inside a polyshape 
%   nearestvertex   - Find the vertex of a polyshape nearest to a point
%   overlaps        - Determine if two polyshapes overlap
%   perimeter       - Get the perimeter of a polyshape 
%   regions         - Put all regions in a polyshape into an array of polyshapes
%   triangulation   - Construct a 2-D triangulation from polyshape 
%
% Methods for transformation:
%   rotate          - Rotate a polyshape by angle with respect to a center
%   scale           - Scale a polyshape by a factor 
%   translate       - Translate a polyshape by a vector 
%
%  Methods for Boolean operations:
%   intersect	    - Find the intersection of two polyshapes or between polyshape and line 
%   subtract        - Find the difference of two polyshapes 
%   union           - Find the union of two polyshapes 
%   xor             - Find the exclusive or of two polyshapes 
%
%  Other methods: 
%   polybuffer      - Create buffer zone around polyshape
%   isequal         - Determine if two polyhapes are identical
%   plot            - Plot polyshape and return a Polygon object handle 
%   sortboundaries  - Sort boundaries in polyshape
%   sortregions     - Sort regions in polyshape
%   turningdist     - Find the turning distance of two polyshapes
%
% Example: Find the area and centroid of a polyshape and plot it
%  %create a polyshape with 4 vertices
%  quadShp = polyshape([0 0 1 3], [0 3 3 0]);
%  %compute area and centroid
%  a = area(quadShp);
%  [cx, cy] = centroid(quadShp);
%  figure; plot(quadShp);
%  hold on
%  %plot centroid point as '*'
%  plot(cx, cy, '*');
%
% See also area, centroid, nsidedpoly

% Copyright 2016-2017 The MathWorks, Inc.

    properties (Dependent)
        Vertices
    end

    properties (Dependent = true, SetAccess = private)
        NumHoles
        NumRegions
    end
    
    properties (Access = private)
        %To indicate polyshape's simplfication state
        %-1: unknown   0: not simplified   1: simplified
        SimplifyState
                
        %UNDERLYING - Underlying builtin polyshape object
        %an instance of matlab.internal.polygon.builtin.cpolygon
        Underlying
    end

    properties (Constant, Access = private)
        %Increase version number when there is a change to saved mat file
        %Backward compatibility should be ensured as much as possbile
        %version 1: R2017b
        CurrentVersion = uint32(1);
        %this number tells prior versions of MATLAB whether the mat file
        %can be loaded (forward compatibility)
        CanBeLoadedByVersion = uint32(1);
    end

    methods
       %constructor
       function PG = polyshape(varargin)
           import matlab.internal.polygon.builtin.cpolygon;
           PG.SimplifyState = -1;
           
           if nargin == 0
               PG.Underlying = cpolygon();
               PG.SimplifyState = 1;
           else
               param = struct;
               param.checkWindingNumber = true;
               param.parameterError = 'MATLAB:polyshape:constructorParameter';
               [X, Y, tc, simpl] = polyshape.checkInput(param, varargin{:});
               PG.Underlying = cpolygon(X, Y, tc, uint32(0));
               if simpl ~= "false"
                   PG = checkAndSimplify(PG, true);
               end
           end
       end

       %dependent property
       function nh = get.NumHoles(PG)
           nh = PG.Underlying.numholes();
       end
       %dependent property
       function nr = get.NumRegions(PG)
           nh = PG.Underlying.numholes();
           nr = PG.Underlying.numboundaries()-nh;
       end

       %get/set Vertices[]
       function V = get.Vertices(PG)
           V = PG.Underlying.vertices();
       end
       function PG = set.Vertices(PG, V)
           %validate input
           if numel(V) == 0
               PG = polyshape();
               return;
           end
           if ~isnumeric(V) || ~isreal(V) || any(any(isinf(V)))
               error(message('MATLAB:polyshape:xyValueError'));
           end
           if issparse(V)
               error(message('MATLAB:polyshape:sparseError'));
           end
           sz = size(V);
           if numel(sz) ~= 2 || sz(2) ~= 2 || sz(1) < 3
               error(message('MATLAB:polyshape:oneInputSizeError'));
           end
           X = V(:,1); 
           Y = V(:,2);
           if any(isnan(X) ~= isnan(Y))
                error(message('MATLAB:polyshape:oneInputNanInconsistent'));
           end
           PG.Underlying = resetvertices(PG.Underlying, double(V) );           
           if PG.SimplifyState >= 0  %was a known state
               PG = checkAndSimplify(PG, true);
           end
       end
       
       %overloaded function
       function TF = isequal(varargin)
           %ISEQUAL Determine if polyshapes are equal
           %
           % TF = ISEQUAL(pshape1, pshape2) returns 1 (true) if the two input polyshape objects
           % are the equal.
           %
           % TF = ISEQUAL(pshape1, pshape2, …, pshapeN) returns true if pshape1, pshape2, …, 
           % pshapeN are equal.
           %
           narginchk(2, inf);
           for jj = 1 : nargin
               if ~isa(varargin{jj}, 'polyshape')
                   TF = false;
                   return;
               end
           end
           
           PG = varargin{1};
           for jj = 2 : nargin
               other = varargin{jj};
               if numel(PG) ~= numel(other) || ~all(size(PG) == size(other))
                   TF = false;
                   return;
               end
               for i = 1 : numel(PG)
                   if PG(i).SimplifyState ~= other(i).SimplifyState
                       TF = false;
                       return;
                   else
                       eq = isequalshape(PG(i).Underlying, other(i).Underlying);
                       if ~eq
                           TF = false;
                           return;
                       end
                   end
               end
           end
           
           TF = true;
           return;
       end
      
       %declaration of other functions
       PG = addboundary(PG0, varargin);
    end

    methods (Hidden = true)        
        %overloaded, the same as isequal
        function TF = isequaln(varargin)
            TF = isequal(varargin{:});
        end
        
        %convenient function for utility functions to set SimplifyState
        function PG = setSimplified(PG, value)
            if islogical(value) && numel(value)==1
                PG.SimplifyState = value;
            end
        end
        
        %overloaded saveobj to .mat file
        function s = saveobj(PG)
            s = struct;
            [vtx, binfo, pinfo] = PG.Underlying.exportdata();
            s.Vertices       = vtx;
            s.BoundaryInfo   = binfo;
            s.PolygonInfo    = pinfo;
            s.SimplifyState  = PG.SimplifyState;            
            s.CurrentVersion       = PG.CurrentVersion;
            s.CanBeLoadedByVersion = PG.CanBeLoadedByVersion;
        end
    end
    
    methods (Static, Hidden = true)
        %overloaded loadobj from .mat file
        function PG = loadobj(s)
            PG = polyshape;
            if s.CurrentVersion > PG.CurrentVersion
                %mat file was saved by a newer version
                if s.CanBeLoadedByVersion > PG.CurrentVersion
                    %load vertices only
                    PG = polyshape(s.Vertices, 'SolidBoundaryOrientation', 'cw',...
                        'Simplify', false);
                    warning(message('MATLAB:polyshape:versionMismatch'));
                    return;
                end
            elseif s.CurrentVersion < PG.CurrentVersion
                %mat file was saved by an older version
                %implement in the future
            end
            PG.Underlying.importdata(s.CurrentVersion, ...
                s.Vertices, s.BoundaryInfo, s.PolygonInfo);
            PG.SimplifyState = s.SimplifyState;
        end
    end
    
    methods (Access = private)
        
        %convenience method to check if a shape is empty
        function TF = isEmptyShape(PG)
            TF = numboundaries(PG) == 0;
        end

        %rough comparison of two shapes
        function TF = isEqualShape(PG, other)
            atol = max(1.0e-10, 1e-10*abs(PG.area));
            ptol = max(1.0e-9, 1e-9*abs(PG.perimeter));
            if numsides(PG) ~= numsides(other) || ...
                    PG.NumRegions ~= other.NumRegions || ...
                    PG.NumHoles ~= other.NumHoles || ...
                    abs(area(PG) - area(other)) > atol || ...
                    abs(perimeter(PG) - perimeter(other)) > ptol
                TF = false;
            else
                TF = true;
            end
        end
        
        %find size for return value for pairwise functions when implicit
        %expansion is involved
        %sz: return size
        %sP, repmat(P, sP) will return size of sz
        %sQ, repmat(Q, sQ) will return size of sz        
        function [c, sa, sb]= findSize(P,Q)
            a = size(P);
            b = size(Q);
            if length(a) >= length(b)
                [c, sa, sb] = P.implicitExp(a,b);
            else
                [c, sb, sa] = P.implicitExp(b,a);
            end
        end
        
        function [c, sa, sb] = implicitExp(unusedObj, a, b)
            %assume length(a) >= lenght(b)
            c = a;
            n = length(b);
            
            c(c(1:n)==1) = b(c(1:n)==1);
            
            if ~all(c(1:n) == b | b == 1)
                error(message('MATLAB:dimagree'));
            end
            
            sa = ones(size(c));
            sa(a == 1) = c(a==1);
            
            sb = ones(size(c));
            sb(b == 1) = c(b==1);
            sb(n+1:end) = c(n+1:end);
        end
        
        %common code for boolean functions
        function [PG, shapeId, vertexId] = booleanFun(subject, clip, boolfun)
            [sz, sP, sQ] = findSize(subject, clip);
            scalarForm = (isscalar(subject) && isscalar(clip));
            shapeId = zeros(0, 1);
            vertexId = zeros(0, 1);
            if numel(clip) == 0 || numel(subject) == 0
                out1 = polyshape.empty(sz);
            else
                P2 = repmat(subject, sP);
                Q2 = repmat(clip, sQ);
                for i=1:numel(P2)
                    out1(i) = polyshape();
                    if P2(i).isEmptyShape && Q2(i).isEmptyShape
                        continue;
                    end
                    [out1(i).Underlying, mapIdx] = boolfun(P2(i).Underlying, Q2(i).Underlying);
                    out1(i).SimplifyState = 1;
                end
                out1 = reshape(out1, sz);
            end
            PG = out1;
            if scalarForm
                if ~PG.isEmptyShape()
                    shapeId = mapIdx(:,1);
                    vertexId = mapIdx(:,3);
                end
            end
        end

        %vector form of union and interesect
        function [PG, shapeId, vertexId] = booleanVec(pshapes, boolFun)
            if ~isvector(pshapes)
                error(message('MATLAB:polyshape:vectorPolyshapeError'));
            end
            import matlab.internal.polygon.builtin.cpolygon;
            u2n = cpolygon.empty(numel(pshapes), 0);
            for i=1:numel(pshapes)
                u2n(i) = pshapes(i).Underlying;
            end

            %call internal function, first input must be empty
            PG = polyshape();
            [PG.Underlying, mapIdx] = boolFun(PG.Underlying, u2n);
            PG.SimplifyState = 1;
            if PG.isEmptyShape()
                shapeId = zeros(0, 1);
                vertexId = zeros(0, 1);
            else
                shapeId = mapIdx(:, 1);
                vertexId = mapIdx(:, 3);
            end
        end
        
        %check if this pshape can be simplified
        function [PG2, canBeSimplified] = checkAndSimplify(PG0, warn_can_simpl)
            PG2 = polyshape();
            if ~PG0.isEmptyShape()
                PG2.Underlying = simplify(PG0.Underlying);
            end
            PG2.SimplifyState = 1;

            if PG2.isEqualShape(PG0)
                canBeSimplified = false;
            else
                canBeSimplified = true;  
            end
            if canBeSimplified && warn_can_simpl
                warning(message('MATLAB:polyshape:repairedBySimplify'));
            end
        end
    end
    
    methods (Static, Access = private)
        %camel case for all private methods

        %error if pshape is a vector
        function checkScalar(pshape)
            if ~isa(pshape, 'polyshape')
                error(message('MATLAB:polyshape:polyshapeTypeError'));
            end
            if numel(pshape) ~= 1
                error(message('MATLAB:polyshape:scalarPolyshapeError'));
            end
        end

        %check consistency: if P is a vector, does not allow index array
        function checkConsistency(P, num_args)
            n = numel(P);
            if (num_args == 2 && n ~= 1)
                error(message('MATLAB:polyshape:noIndexArrayError'));
            end
        end

        %check if shape is empty
        function checkEmpty(P)
            if P.isEmptyShape
                error(message('MATLAB:polyshape:emptyPolyshapeError'));
            end
        end
        
        %input array of polyshape
        function n = checkArray(P)
            if ~isa(P, 'polyshape')
                error(message('MATLAB:polyshape:polyshapeTypeError'));
            end
            n = size(P);
        end
        
        %get X Y coordinates from two cell arrays
        function [X, Y, next_arg] = getXYcell(varargin)
            X = [];
            Y = [];
            cell1 = varargin{1};
            if nargin < 2
                error(message('MATLAB:polyshape:twoCellArrays'));
            else
                cell2 = varargin{2};
                if isnumeric(cell2)
                    error(message('MATLAB:polyshape:xyNumericCell'));
                elseif ~iscell(cell2)
                    error(message('MATLAB:polyshape:twoCellArrays'));
                end
            end
            if ~isvector(cell1) || ~isvector(cell2)
                error(message('MATLAB:polyshape:cellArrayMismatch'));
            end
            if ~isequal(size(cell1), size(cell2))
                error(message('MATLAB:polyshape:cellArrayMismatch'));
            end
            for ia = 1:length(cell1)
                xx = cell1{ia};
                yy = cell2{ia};
                if ~isvector(xx) || ~isnumeric(xx) || ~isvector(yy) || ~isnumeric(yy)
                    error(message('MATLAB:polyshape:xyValueError'));
                end
                if issparse(xx) || issparse(yy)
                    error(message('MATLAB:polyshape:sparseError'));
                end
                if ~isequal(size(yy), size(xx))
                    error(message('MATLAB:polyshape:xyVectorCell'));
                end
                %change to row vectors
                if (size(xx, 1) > 1)
                    xx = xx';
                    yy = yy';
                end
                if (~isempty(X))
                    X = [X NaN];
                    Y = [Y NaN];
                end
                X = [X xx];
                Y = [Y yy];
            end            
            next_arg = 3;
        end
        
        %parse and get the x- and y- coordinates
        function [X, Y, xy2input, next_arg] = getXY(varargin)
            X=[];
            Y=[];
            xy2input = false;
            ia = 1;
            while (ia <= nargin)
                pts = varargin{ia};
                if (~isnumeric(pts))
                    break;
                end
                if issparse(pts)
                    error(message('MATLAB:polyshape:sparseError'));
                end
                if numel(size(pts)) > 2
                    if nargin >= ia+1 && isnumeric(varargin{ia+1})
                        error(message('MATLAB:polyshape:twoInputSizeError'));
                    else
                        error(message('MATLAB:polyshape:oneInputSizeError'));
                    end
                end
                
                %check if input contains one or two numeric arrays
                two_input = false;
                if nargin >= ia+1 && isnumeric(varargin{ia+1})
                    two_input = true;
                end
                
                [m, n] = size(pts);
                if n == 2 && ~two_input
                    %g1664687 [0x2], [nan nan] returns empty shape
                    %[1 2; 2 2] triggers warning (boundary dropped)
                    %0x2 ==> empty polyshape
                    %1x2, 2x2 ==> warning of boundary being dropped
                    xx = pts(:, 1);
                    yy = pts(:, 2);
                    ia = ia+1;
                    xy2input = false;
                elseif isvector(pts)
                    %two input arrays
                    if nargin >= ia+1
                        if iscell(varargin{ia+1})
                            error(message('MATLAB:polyshape:xyNumericCell'));
                        elseif ~isnumeric(varargin{ia+1})
                            error(message('MATLAB:polyshape:oneInputSizeError'));
                        end
                    else
                        error(message('MATLAB:polyshape:oneInputSizeError'));
                    end
                    if ~isvector(varargin{ia+1}) 
                        error(message('MATLAB:polyshape:twoInputSizeError'));
                    end
                    xx = varargin{ia};
                    yy = varargin{ia+1};
                    xy2input = true;
                    if issparse(xx) || issparse(yy)
                        error(message('MATLAB:polyshape:sparseError'));
                    end
                    if ~isequal(size(yy), size(xx))
                        error(message('MATLAB:polyshape:twoInputSizeError'));
                    end
                    ia = ia+2;
                else
                    if nargin >= ia+1 && isnumeric(varargin{ia+1})
                        error(message('MATLAB:polyshape:twoInputSizeError'));
                    else
                        error(message('MATLAB:polyshape:oneInputSizeError'));
                    end
                end
                
                %change to row vectors
                if (size(xx, 1) > 1)
                    xx = xx';
                    yy = yy';
                end
                
                if ~isempty(X)
                    error(message('MATLAB:polyshape:multipleDataSetError'));
                end
                X = xx;
                Y = yy;
            end
            next_arg = ia;            
        end

        %parse point coordinates from input arguments and return 2 column vectors
        function [X, Y] = checkPointArray(param, varargin)
            narginchk(2, 5);
            count_extra = 0;
            extra_args = cell(2, 1);
            for i=1:numel(varargin)
                if isnumeric(varargin{i})
                    if issparse(varargin{i})
                        error(message('MATLAB:polyshape:sparseError'));
                    end
                    count_extra = count_extra+1;
                    extra_args{count_extra} = varargin{i};
                else
                    error(message(param.errorValue));
                end
            end
            if count_extra == 1
                XY = extra_args{1};
                sz = size(XY);
                if numel(XY) == 0
                    error(message(param.errorOneInput));
                end
                if param.one_point_only
                    if ~isequal(sz, [1 2])
                        error(message(param.errorOneInput));
                    end
                else
                    if numel(sz) ~= 2 || sz(2) ~= 2
                        error(message(param.errorOneInput));
                    end
                end
                X = XY(:, 1);
                Y = XY(:, 2);
            else
                X = extra_args{1};
                Y = extra_args{2};
                if ~isequal(size(X), size(Y))
                    error(message(param.errorTwoInput));
                end
                if numel(X) == 0
                    error(message(param.errorTwoInput));
                elseif numel(X) > 1 && param.one_point_only
                    error(message(param.errorTwoInput));
                end                
                if isrow(X)
                    X = X';
                    Y = Y';
                elseif ~iscolumn(X)
                    error(message(param.errorTwoInput));
                end
            end
            if ~isnumeric(X) || ~isnumeric(Y) || ~isreal(X) || ~isreal(Y)
                error(message(param.errorValue));
            end
            if ~param.allow_inf
                if any(isinf(X)) || any(isinf(Y))
                    error(message(param.errorValue));
                end
            end
            if ~param.allow_nan
                if any(isnan(X)) || any(isnan(Y))
                    error(message(param.errorValue));
                end
            end
            X = double(X);
            Y = double(Y);
        end
        
        %sort input argments, called from sortregions and sortboundaries
        function out = checkSortInput(varargin)
            ninput = numel(varargin);
            out = {'ascend', 'area'}; %default
            acceptedStr = {'ascend', 'descend', 'numsides', ...
                'area', 'perimeter', 'centroid', 'referencepoint'};
            countStr = zeros(1, numel(acceptedStr));
            found_centroid = false;
            found_ref = int32(0);
            matchLen = [2 1 1 2 1 1 1];
            for i=1:ninput
                if isstring(varargin{i}) || ischar(varargin{i})
                    charStr = char(varargin{i});
                    matched = false;
                    for j = 1:numel(acceptedStr)
                        cmpLength = max(length(charStr), matchLen(j));
                        if strncmpi(charStr, acceptedStr{j}, cmpLength)
                            countStr(j) = countStr(j)+1;
                            if countStr(j) > 1 && j <= 6
                                error(message('MATLAB:polyshape:parameterRepeatingError',...
                                      acceptedStr{j}));
                            end
                            if j == 1 || j == 2
                                out{1} = acceptedStr{j};
                            elseif j >= 3 && j <=6
                                out{2} = acceptedStr{j};
                            else
                                out{3} = acceptedStr{j};
                            end
                            matched = true;
                            if j==6
                                found_centroid = true;
                            elseif j==7
                                if ~found_centroid
                                    error(message('MATLAB:polyshape:sortReference'));
                                end
                                found_ref = int32(i);
                                if i == ninput
                                    error(message('MATLAB:polyshape:nameValuePairError'));
                                end
                            end
                            break;
                        end
                    end
                    if ~matched
                        error(message('MATLAB:polyshape:sortParameter'));
                    end
                elseif isnumeric(varargin{i})
                    if found_ref == 0 || found_ref ~= i-1
                        error(message('MATLAB:polyshape:sortParameter'));
                    end
                    param.allow_inf = false;
                    param.allow_nan = false;
                    param.one_point_only = true;
                    param.errorOneInput = 'MATLAB:polyshape:sortRefPoint';
                    param.errorTwoInput = 'MATLAB:polyshape:sortRefPoint';
                    param.errorValue = 'MATLAB:polyshape:sortRefPointValue';
                    [X, Y] = polyshape.checkPointArray(param, varargin{i});
                    out{4} = [X Y];
                else
                    error(message('MATLAB:polyshape:sortParameter'));
                end
            end
            %check consistency of sort parameters
            if countStr(1) >= 1 && countStr(2) >= 1
                %specified both ascend and descend
                error(message('MATLAB:polyshape:sortDirection'));
            elseif sum(countStr(3:6) >= 1) > 1
                %specified 2 of the keys
                error(message('MATLAB:polyshape:sortParameter'));
            end
        end

        %parse name/value pairs for constructor and addboundary
        function [X, Y, type_con, simplify] = checkInput(param, varargin)
            simplify = "default";
            type_con = "auto";
            %%parse and check coordinates
            if iscell(varargin{1})
                [X, Y, next_arg] = polyshape.getXYcell(varargin{:});
                xy2input = true;
            else
                [X, Y, xy2input, next_arg] = polyshape.getXY(varargin{:});
            end
            if next_arg == 1
                error(message('MATLAB:polyshape:xyNumericCell'));
            end
            if ~isreal(X) || ~isreal(Y)
                error(message('MATLAB:polyshape:xyValueError'));
            end
            if ~all(isnan(X) == isnan(Y))
                if xy2input
                    error(message('MATLAB:polyshape:twoInputNanInconsistent'));
                else
                    error(message('MATLAB:polyshape:oneInputNanInconsistent'));
                end
            end
            
            if ~isa(X, 'double')
                X = double(X);
            end
            if ~isa(Y, 'double')
                Y = double(Y);
            end
            %parse and check Name Values
            n_arg = numel(varargin);
            for ia = next_arg:2:n_arg
                this_arg = varargin{ia};
                if (n_arg < ia + 1)
                    error(message('MATLAB:polyshape:nameValuePairError'));
                end
                next_arg = varargin{ia+1};
                if ~(ischar(this_arg) || isstring(this_arg))
                    error(message(param.parameterError));
                else
                    this_arg = char(this_arg);
                    nn = max(2, length(this_arg));
                    if (strncmpi(this_arg, 'simplify', nn))
                        if isscalar(next_arg) && (islogical(next_arg) || isnumeric(next_arg))
                            %PRISM asks to relax logical input to accept
                            %'simplify', 1/int8(1)/true
                            %'simplify', 0/int8(0)/false
                            if double(next_arg) == 1
                                simplify = "true";
                            elseif double(next_arg) == 0
                                simplify = "false";
                            else
                                error(message('MATLAB:polyshape:simplifyValue'));
                            end
                        else
                            error(message('MATLAB:polyshape:simplifyValue'));
                        end
                    elseif (strncmpi(this_arg, 'SolidBoundaryOrientation', nn))
                        if ischar(next_arg) || isstring(next_arg)
                            nextss = string(next_arg);
                            if length(nextss) > 1
                                error(message('MATLAB:polyshape:orientationValue'));
                            end
                            nextss = nextss{1};
                            if (strncmpi(nextss, 'auto', max(1, length(nextss))))
                                type_con = "auto";
                            elseif (strncmpi(nextss, 'ccw', max(2, length(nextss))))
                                type_con = "ccw";
                            elseif (strncmpi(nextss, 'cw', max(2, length(nextss))))
                                type_con = "cw";
                            else
                                error(message('MATLAB:polyshape:orientationValue'));
                            end
                        else
                            error(message('MATLAB:polyshape:orientationValue'));
                        end
                    else
                        error(message(param.parameterError));
                    end
                end
            end            
        end
        
        %several methods takes a scalar as an input argment
        function out = checkScalarValue(value, error_id)
            if isnumeric(value) && isscalar(value)
                if issparse(value)
                    error(message(error_id));
                end
                if ~isfinite(value) || ~isreal(value) || isnan(value)
                    error(message(error_id));
                else
                    out = double(value);
                end
            else
                error(message(error_id));
            end
        end
        
        %several methods takes an index vector as an input argment
        function II = checkIndex(pshape, I)
            Lo = 1;
            Hi = numboundaries(pshape);
            %error if NaN, Inf, complex, char, sparse, empty
            if ~isnumeric(I) || ~isreal(I) || ~isvector(I) || any(~isfinite(I(:))) || ...
               issparse(I) || length(I) < 1
                error(message('MATLAB:polyshape:indexError', Hi));
            else
                II = double(floor(I));
                if ~isequal(II, I)
                    error(message('MATLAB:polyshape:indexError', Hi));
                end
            end
            if ( any(II < Lo) || any(II > Hi) )
                error(message('MATLAB:polyshape:indexError', Hi));
            end
        end
    end

    methods (Access = protected, Hidden)
        function group = getPropertyGroups(~)
            group = matlab.mixin.util.PropertyGroup({...
                    'Vertices', 'NumRegions', 'NumHoles'});
        end 
    end
    
end
