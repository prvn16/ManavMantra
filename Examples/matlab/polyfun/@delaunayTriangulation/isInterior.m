% isInterior  Test if a triangle is in the interior of a 2-D constrained Delaunay triangulation
%
% IN = isInterior(DT) returns the in/out status of the triangles in a
%      2D constrained Delaunay triangulation of a geometric domain.
%      IN is a logical array of length equal to the number of triangles in
%      the triangulation. The constrained edges in the triangulation define
%      the boundaries of a valid geometric domain.
%
%      Given a Delaunay triangulation that has a set of constrained edges
%      that define a bounded geometric domain. The i'th triangle in the
%      triangulation is classified in the interior of the domain if IN(i)
%      equals 1, otherwise the triangle exterior.
%
%      Note: isInterior is only relevant for 2D constrained Delaunay
%            triangulations where the imposed edge constraints bound a
%            closed geometric domain.
%
%    Example:
%        % Create a geometric domain that consists of a square with a square hole
%        outerprofile = [-5 -5; -3 -5; -1 -5;  1 -5;  3 -5;  5 -5;...
%                                5 -3;  5 -1;  5  1;  5  3;       ...
%                         5  5;  3  5;  1  5; -1  5; -3  5; -5  5;...
%                               -5  3; -5  1; -5 -1; -5 -3; ];
%        innerprofile = outerprofile.*0.5;
%        profile = [outerprofile; innerprofile];
%        outercons = [(1:19)' (2:20)'; 20 1;];
%        innercons = [(21:39)' (22:40)'; 40 21];
%        edgeconstraints = [outercons; innercons];
%        % Create a constrained Delaunay triangulation of the domain
%        dt = delaunayTriangulation(profile, edgeconstraints)
%        subplot(1,2,1);
%        triplot(dt);
%        hold on;
%        plot(dt.Points(outercons',1), dt.Points(outercons',2), '-r', 'LineWidth', 2);
%        plot(dt.Points(innercons',1), dt.Points(innercons',2), '-r', 'LineWidth', 2);
%        axis equal;
%        title(sprintf('Plot showing interior and exterior\n triangles with respect to the domain.'));
%        hold off;
%        subplot(1,2,2);
%        inside = isInterior(dt);
%        triplot(dt(inside, :), dt.Points(:,1), dt.Points(:,2));
%        hold on;
%        plot(dt.Points(outercons',1), dt.Points(outercons',2), '-r', 'LineWidth', 2);
%        plot(dt.Points(innercons',1), dt.Points(innercons',2), '-r', 'LineWidth', 2);
%        axis equal;
%        title(sprintf('Plot showing interior triangles only\n'));
%        hold off;

% Copyright 2012 The MathWorks, Inc.

