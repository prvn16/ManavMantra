% inOutStatus  Returns the in/out status of the triangles in a 2D constrained Delaunay
%
%    DelaunayTri/isInterior will be removed in a future release.
%    Use delaunayTriangulation/isInterior instead.
%
%    IN = inOutStatus(DT) returns the in/out status of the triangles in a 
%    2D constrained Delaunay triangulation of a geometric domain. 
%    IN is a logical array of length equal to the number of triangles in
%    the triangulation. The constrained edges in the triangulation define 
%    the boundaries of a valid geometric domain. 
%
%    Given a Delaunay triangulation that has a set of constrained edges that define 
%    a bounded geometric domain. The i'th triangle in the triangulation is classified 
%    as inside the domain if IN(i) equals 1, otherwise the triangle outside.
%    
%    Note: inOutStatus  is only relevant for 2D constrained Delaunay triangulations
%          where the imposed edge constraints bound a closed geometric domain.
%
%    Example: 	
%            % Create a geometric domain that consists of a square with a square hole
%            outerprofile = [-5 -5; -3 -5; -1 -5; 1 -5; 3 -5; 5 -5;...
%	                                5 -3; 5 -1; 5  1; 5  3;...
%                             5  5;  3  5;  1  5; -1  5; -3  5; -5  5;...
%                                   -5  3; -5  1; -5 -1; -5 -3; ];
%            innerprofile = outerprofile.*0.5;
%            profile = [outerprofile; innerprofile];
%            outercons = [(1:19)' (2:20)'; 20 1;];
%            innercons = [(21:39)' (22:40)'; 40 21];
%            edgeconstraints = [outercons; innercons];
%            % Create a constrained Delaunay triangulation of the domain
%            dt = DelaunayTri(profile, edgeconstraints)
%            subplot(1,2,1);
%            triplot(dt);
%            hold on; 
%            plot(dt.X(outercons',1), dt.X(outercons',2), '-r', 'LineWidth', 2); 
%            plot(dt.X(innercons',1), dt.X(innercons',2), '-r', 'LineWidth', 2);
%            axis equal;
%            title(sprintf('Plot showing interior and exterior\n triangles with respect to the domain.'));
%            hold off;
%            subplot(1,2,2);
%            inside = inOutStatus(dt);
%            triplot(dt(inside, :), dt.X(:,1), dt.X(:,2));
%            hold on;
%            plot(dt.X(outercons',1), dt.X(outercons',2), '-r', 'LineWidth', 2); 
%            plot(dt.X(innercons',1), dt.X(innercons',2), '-r', 'LineWidth', 2);
%            axis equal;
%            title(sprintf('Plot showing interior triangles only\n'));
%            hold off;

%   Copyright 2008-2012 The MathWorks, Inc.
%   Built-in function.


