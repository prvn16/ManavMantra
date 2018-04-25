function [v, c] = voronoin(x,options)
%VORONOIN  N-D Voronoi diagram. 
%   [V,C] = VORONOIN(X) returns Voronoi vertices V and the Voronoi cells C 
%   of the Voronoi diagram of X. V is a numv-by-n array of the numv Voronoi  
%   vertices in n-D space, each row corresponds to a Voronoi vertex. C is 
%   a vector cell array where each element is the indices into V of the
%   vertices of the corresponding Voronoi cell. X is an m-by-n array,
%   representing m n-D points. 
%
%   VORONOIN uses Qhull. 
% 
%   [V,C] = VORONOIN(X,OPTIONS) specifies a cell array of strings OPTIONS 
%   to be used as options in Qhull. The default options are:
%                                 {'Qbb'} for 2D and 3D input,
%                                 {'Qbb','Qx'} for 4D and higher.
%   If OPTIONS is [], the default options will be used.
%   If OPTIONS is {''}, no options will be used, not even the default.
%   For more information on Qhull options, see http://www.qhull.org.
%   
%   Example 1:  
%   If  
%      X = [0.5 0; 0 0.5; -0.5 -0.5; -0.2 -0.1; -0.1 0.1; 0.1 -0.1; 0.1 0.1]
%     [V,C] = voronoin(X) 
%   To see the contents of C, use the following commands     
%      for i = 1:length(C), disp(C{i}), end
%   In particular, the fifth Voronoi cell consists of 4 points: 
%   V(10,:), V(3,:), V(5,:), V(7,:). 
% 
%   For 2-D, vertices in C are listed in adjacent order, i.e. connecting 
%   them will generate a closed polygon (Voronoi diagram). For 3-D 
%   and above, vertices are listed in ascending order. To generate 
%   a particular cell of the Voronoi diagram, use CONVHULLN to compute 
%   the facets of that cell, e.g. to generate the fifth Voronoi cell, 
% 
%      X = V(C{5},:); 
%      K = convhulln(X); 
%
%   Example 2:
%      X = [-1 -1; 1 -1; 1 1; -1 1];
%      [V,C] = voronoin(X)
%   errors, but hints that adding 'Qz' to the default options might help.
%      [V,C] = voronoin(X,{'Qbb','Qz'})
%
%   See also delaunayTriangulation, VORONOI, QHULL, DELAUNAYN, CONVHULLN,
%            DELAUNAY, CONVHULL. 

%   Copyright 1984-2013 The MathWorks, Inc. 


if nargin < 1
  error(message('MATLAB:voronoin:NotEnoughInputs'));
end
if( nargin > 1)
  cg_opt = options;
else
    cg_opt = {};
end
cgprechecks(x, nargin, cg_opt);

[m,n] = size(x);
if n <= 1
  error(message('MATLAB:voronoin:XLowColNum'));
end
pre_merge_size = m;

% We want to remove duplicates, but we do not want to change the ordering
% of the points.
[~, I, ~] = unique(x,'first','rows');
post_merge_size = length(I);
if (pre_merge_size > post_merge_size)
    sorted_I = sort(I)';
    x = x(sorted_I,:);
    %
    warning(message('MATLAB:voronoin:DuplicateDataPoints'));
    %
    [m,n] = size(x);
end

clear B I J;

if m < n+1, 
  error(message('MATLAB:voronoin:NotEnoughPtsForTessel')); 
end 


if m == n+1
    v = zeros(2,n);
    v(1,:) = Inf;
    v(2,:) = circumcenter(x);
    c = num2cell(repmat([1 2],m,1),2);
    return
end

%default options
if n >= 4
    opt = 'Qbb Qx';
else 
    opt = 'Qbb';
end

if ( nargin > 1 && ~isempty(options) )
    sp = {' '};
    c = strcat(options,sp);
    opt = cat(2,c{:});
end

[v, c] = qhullmx(x', 'v ', opt); 

function C = circumcenter(A)
%CIRCUMCENTER computes circumcenter of N+1 points in N-D
%   C = CIRCUMCENTER(A) returns 1xN vector of circumcenter's coordinates, 
%   where A is (N+1)x(N) matrix containing points' coordinates. 

% Reference: Yumnam Kirani Singh 
%            News Bull. Cal. Math. Soc. 24(5&6) 21-24(2001)
% http://www.geocities.com/kiranisingh/center.html

n = size(A,2);

Dn = A(2:end,:);
for j = 1:n
    Dn(:,j) = Dn(:,j) - A(1,j);
end
D = det(Dn);

if abs(D) < eps
    error(message('MATLAB:voronoin:circumcenter:ColinearCoplanarPoints'))
end

Asq = A.^2;
P = sum(Asq(2:end,:),2);
P = P - sum(Asq(1,:),2);

N = zeros(1,n);
for j = 1:n
    NN = Dn;
    NN(:,j) = P;
    N(j) = det(NN);
end

C = N/(2*D);



