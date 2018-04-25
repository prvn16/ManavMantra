function outbounds = findbounds(varargin)
%FINDBOUNDS Find output bounds for spatial transformation.
%   OUTBOUNDS = FINDBOUNDS(TFORM,INBOUNDS) estimates the output bounds
%   corresponding to a given spatial transformation and a set of input
%   bounds.  TFORM is a spatial transformation structure as returned by
%   MAKETFORM or CP2TFORM.  INBOUNDS is 2-by-NUM_DIMS matrix.  The first row
%   of INBOUNDS specifies the lower bounds for each dimension, and the
%   second row specifies the upper bounds. NUM_DIMS has to be consistent
%   with the ndims_in field of TFORM.
%
%   OUTBOUNDS has the same form as INBOUNDS.  It is an estimate of the
%   smallest rectangular region completely containing the transformed
%   rectangle represented by the input bounds.  Since OUTBOUNDS is only an
%   estimate, it may not completely contain the transformed input rectangle.
%
%   Notes
%   -----
%   IMTRANSFORM uses FINDBOUNDS to compute the 'OutputBounds' parameter
%   if the user does not provide it.
%
%   If TFORM contains a forward transformation (a nonempty forward_fcn
%   field), then FINDBOUNDS works by transforming the vertices of the input
%   bounds rectangle and then taking minimum and maximum values of the
%   result.
%
%   If TFORM does not contain a forward transformation, then FINDBOUNDS
%   estimates the output bounds using the Nelder-Mead optimization
%   function FMINSEARCH.  If the optimization procedure fails, FINDBOUNDS
%   issues a warning and returns OUTBOUNDS=INBOUNDS.
%
%   Example
%   -------
%       inbounds = [0 0; 1 1]
%       tform = maketform('affine',[2 0 0; .5 3 0; 0 0 1])
%       outbounds = findbounds(tform, inbounds)
%
%   See also CP2TFORM, IMTRANSFORM, MAKETFORM, TFORMARRAY, TFORMFWD, TFORMINV.

%   Copyright 1993-2010 The MathWorks, Inc.

% I/O details
% -----------
% tform     - valid TFORM structure; checked using private/istform.
%
% inbounds  - 2-by-NUM_DIMS real double matrix.  NUM_DIMS must be equal to
%             tform.ndims_in.  It may not contain NaN's or Inf's.
%
% outbounds - 2-by-NUM_DIMS_OUT real double matrix.  NUM_DIMS_OUT is
%             equal to tform.ndims_out.

[tform,inbounds] = parse_inputs(varargin{:});

if isempty(tform.forward_fcn)
    outbounds = find_bounds_using_search(tform, inbounds);
else
    outbounds = find_bounds_using_forward_fcn(tform, inbounds);
end

%--------------------------------------------------
function out_bounds = find_bounds_using_forward_fcn(tform, in_bounds)

in_vertices = bounds_to_vertices(in_bounds);
in_points = add_in_between_points(in_vertices);
out_points = tformfwd(in_points, tform);
out_bounds = points_to_bounds(out_points);

%--------------------------------------------------
function out_bounds = find_bounds_using_search(tform, in_bounds)

% Strategy
% --------
% For each point u_k in a set of points on the boundary or inside of the
% input bounds, find the corresponding output location by minimizing this
% objective function:
%
%    norm(u_k - tforminv(x, tform))
%
% It seems reasonable to use the u_k values as starting points for the
% optimization routine, FMINSEARCH.

if isempty(tform.inverse_fcn)
    error(message('images:findbounds:fwdAndInvFieldsCantBothBeEmpty'))
end

in_vertices = bounds_to_vertices(in_bounds);
in_points = add_in_between_points(in_vertices);
out_points = zeros(size(in_points));
success = 1;
options = optimset('Display','off');
for k = 1:size(in_points,1)
    [x,fval,exitflag] = fminsearch(@objective_function, in_points(k,:), ...
                                   options, tform, in_points(k,:)); %#ok
    if exitflag <= 0
        success = 0;
        break;
    else
        out_points(k,:) = x;
    end
end

if success
    out_bounds = points_to_bounds(out_points);
else
    % Optimization failed; the fallback strategy is to make the output
    % bounds the same as the input bounds.  However, if the input
    % transform dimensionality is not the same as the output transform
    % dimensionality, there doesn't seem to be anything reasonable to
    % do.
    if tform.ndims_in == tform.ndims_out
        warning(message('images:findbounds:searchFailed'))
        out_bounds = in_bounds;
    else
         error(message('images:findbounds:mixedDimensionalityTFORM'))
    end
end

%--------------------------------------------------
function s = objective_function(x, tform, u0)
% This is the function to be minimized by FMINSEARCH.

s = norm(u0 - tforminv(x, tform));

%--------------------------------------------------
function vertices = bounds_to_vertices(bounds)
% Convert a 2-by-num_dims bounds matrix to a 2^num_dims-by-num_dims
% matrix containing each of the vertices of the region corresponding to
% BOUNDS.
%
% Strategy: the k-th coordinate of each vertex bound can be either
% bounds(k,1) or bounds(k,2).  One way to enumerate all the possibilities
% is to count in binary from 0 to (2^num_dims - 1).

num_dims = size(bounds,2);
num_vertices = 2^num_dims;

binary = repmat('0',[num_vertices,num_dims]);
for k = 1:num_vertices
    binary(k,:) = dec2bin(k-1,num_dims);
end

mask = binary ~= '0';

low = repmat(bounds(1,:),[num_vertices 1]);
high = repmat(bounds(2,:),[num_vertices 1]);
vertices = low;
vertices(mask) = high(mask);

%--------------------------------------------------
function points = add_in_between_points(vertices)
% POINTS contains all of the input vertices, plus all the unique points
% that are in between each pair of vertices.

num_vertices = size(vertices,1);
ndx = nchoosek(1:num_vertices,2);
new_points = (vertices(ndx(:,1),:) + vertices(ndx(:,2),:))/2;
new_points = unique(new_points, 'rows');

points = [vertices; new_points];

%--------------------------------------------------
function bounds = points_to_bounds(points)
% Find a 2-by-num_dims matrix bounding the set of points in POINTS.

bounds = [min(points,[],1) ; max(points,[],1)];

%--------------------------------------------------
function [tform,inbounds] = parse_inputs(varargin)

narginchk(2,2)

tform = varargin{1};
inbounds = varargin{2};

if ~istform(tform)
    error(message('images:findbounds:firstInputMustBeTformStruct'))
end

if numel(tform) ~= 1
    error(message('images:findbounds:firstInputMustBeOneByOneTformStruct'))
end

if tform.ndims_in ~= tform.ndims_out
    error(message('images:findbounds:inOutDimsOfTformMustBeSame'))
end

if ~isnumeric(inbounds) || (ndims(inbounds) > 2) || (size(inbounds,1) ~= 2)
    error(message('images:findbounds:inboundsMustBe2byN'))
end

num_dims = size(inbounds,2);

if num_dims ~= tform.ndims_in
    error(message('images:findbounds:secondDimOfInbundsMustEqualTformNdimsIn'))
end

if any(~isfinite(inbounds(:)))
    error(message('images:findbounds:inboundsMustBeFinite'))
end
