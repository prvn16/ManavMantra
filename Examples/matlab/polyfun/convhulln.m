function [k,v] = convhulln(x,options)
%CONVHULLN N-D Convex hull.
%   K = CONVHULLN(X) returns the indices K of the points in X that 
%   comprise the facets of the convex hull of X. 
%   X is an m-by-n array representing m points in n-D space. 
%   If the convex hull has p facets then K is p-by-n. 
%
%   CONVHULLN uses Qhull.
%
%   K = CONVHULLN(X,OPTIONS) specifies a cell array of strings OPTIONS to be
%   used as options in Qhull. The default options are:
%                                 {'Qt'} for 2D, 3D and 4D input,
%                                 {'Qt','Qx'} for 5D and higher. 
%   If OPTIONS is [], the default options will be used.
%   If OPTIONS is {''}, no options will be used, not even the default.
%   For more information on Qhull and its options, see http://www.qhull.org.
%
%   [K,V] = CONVHULLN(...) also returns the volume of the convex hull
%   in V. 
%
%   Example:
%      X = [0 0; 0 1e-10; 0 0; 1 1];
%      K = convhulln(X)
%   gives a warning that is suppresed by the additional option 'Pp':
%      K = convhulln(X,{'Qt','Pp'})
%
%   See also delaunayTriangulation, triangulation, CONVHULL, QHULL, DELAUNAYN,
%            VORONOIN, TSEARCHN, DSEARCHN.

%   Copyright 1984-2013 The MathWorks, Inc. 

if nargin < 1
    error(message('MATLAB:convhulln:NotEnoughInputs'));
end

if( nargin > 1)
  cg_opt = options;
else
    cg_opt = {};
end
cgprechecks(x, nargin, cg_opt);

n = size(x,2);
if n <= 1
  error(message('MATLAB:convhulln:XLowColNum'));
end

[x, dupesfound, idxmap] = mergeDuplicatePoints(x);
n = size(x,2);

%default options
if n >= 5
    opt = 'Qt Qx';
else 
    opt = 'Qt';
end

if ( nargin > 1 && ~isempty(options) )    
    sp = {' '};
    c = strcat(options,sp);
    opt = cat(2,c{:});
end

[k,vv] = qhullmx(x', opt);

if nargout > 1
    v = vv;
end

if n == 2
    % Sort the vertices in counterclockwise order
    k = unique(k(:));
    k = k(:);
    xc = x(k,1); yc = x(k,2);
    xm = mean(xc); ym = mean(yc);
    phi = angle((xc-xm) + (yc-ym)*sqrt(-1));
    [~,ind] = unique(phi);
    k = k(ind);
    num_v = length(k);
    k = [k(1:(num_v-1)) k(2:num_v); k(num_v) k(1)];    
end
    
% Rewire the vertex indices if points were merged
if (dupesfound)
    k = idxmap(k);
end
