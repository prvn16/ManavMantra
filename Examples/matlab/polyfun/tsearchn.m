function [t, p] = tsearchn(x,tri,xi)
%TSEARCHN N-D closest simplex search.
%   T = TSEARCHN(X,TRI,XI) returns the indices T of the enclosing simplex
%   of the Delaunay triangulation TRI for each point in XI. X is 
%   an m-by-n matrix, representing m points in n-D space. XI is 
%   a p-by-n matrix, representing p points in n-D space.  TSEARCHN returns 
%   NaN for all points outside the convex hull of X. TSEARCHN requires a 
%   triangulation TRI of the points X obtained from DELAUNAYN.
% 
%   [T,P] = TSEARCHN(X,TRI,XI) also returns the barycentric coordinate P
%   of XI in the simplex TRI. P is an p-by-n+1 matrix. Each row of P is the
%   barycentric coordinate of the corresponding point in XI. It is useful
%   for interpolation.
%
%   See also delaunayTriangulation, DSEARCHN, QHULL, GRIDDATAN, DELAUNAYN.
%
%   Copyright 1984-2016 The MathWorks, Inc.

[npt, ndim] = size(xi);                 % Number of points
myeps = builtin('_tsearchntol', ndim);  % Tolerance
myeps = -myeps;
ntri = size(tri,1);                     % Number of simplexes

if size(x,2) ~= ndim
    error(message('MATLAB:tsearchn:InvalidDimensions'))
elseif size(tri,2) ~= ndim+1
    error(message('MATLAB:tsearchn:InvalidTessellation'))
end

% Heuristic for determining the fastest algorithm
if (ndim == 2) || (ndim == 3)
  if (ntri > 1500)
    algorithm_type = 1;
  else
    algorithm_type = 2;
  end
else
  if npt > 200
      mult = 1;
  else
      mult = npt/200;
  end
  if ntri < (mult*10^ndim)
    algorithm_type = 2;
  else
    algorithm_type = 3;
  end
end

if algorithm_type == 1
  T = triangulation(tri, x);
  [t,p] = pointLocation(T,xi);
elseif algorithm_type == 2
  t = nan(npt,1);            % Simplex containing corresponding input point
  p = nan(npt,ndim+1);       % Barycentric coordinates for corresponding input point
  X = [ones(size(x,1),1) x]; % Append 1s to vertex matrix
  b = [ones(npt,1) xi];      % Append 1s to point matrix
  for i = 1:ntri             % Return the largest simplex index
    % For each triangle
    q = b / X(tri(i,:),:);   % Compute barycentric coordinate of each point
    I = all(q > myeps,2);    % Find simplex where all coordinates are positive
    t(I) = i;                % Set simplex
    p(I,:) = q(I,:);         % Set barycentric coordinates
  end
else
  if nargout == 2
    [t,p] = tsrchnmx(x',tri,xi',0);
    p = p';
  else
    t = tsrchnmx(x',tri,xi',2);
  end
end
