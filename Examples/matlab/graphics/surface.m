%SURFACE Create surface
%   SURFACE(Z) plots the surface specified by the matrix Z. Here, Z is a
%   single-valued function, defined over a geometrically rectangular grid.
%   
%   SURFACE(Z,C) plots the surface specified by Z and colors it according
%   to the data in C.
%   
%   SURFACE(X,Y,Z) uses C = Z, so color is proportional to surface height
%   above the x-y plane.
%   
%   SURFACE(X,Y,Z,C) plots the parametric surface specified by X, Y, and Z,
%   with color specified by C.
%   
%   SURFACE(x,y,Z), SURFACE(x,y,Z,C) replaces the first two matrix
%   arguments with vectors and must have length(x) = n and length(y) = m
%   where [m,n] = size(Z). In this case, the vertices of the surface facets
%   are the triples (x(j),y(i),Z(i,j)). Note that x corresponds to the
%   columns of Z and y corresponds to the rows of Z. For a complete
%   discussion of parametric surfaces, see the SURF function.
%   
%   SURFACE(...,Name,Value) specifies surface properties using one or more
%   Name,Value pair arguments.
%   
%   SURFACE(container,...) creates the surface in the axes, group, or
%   transform specified by container, instead of in the current axes.
%   
%   S = SURFACE(...) returns the surface object created.
%   
%   AXIS, CAXIS, COLORMAP, HOLD, SHADING and VIEW set figure, axes, and
%   surface properties which affect the display of the SURFACE.
%
%   Execute GET(S), where S is a surface object, to see a list of surface
%   object properties and their current values.
%   Execute SET(S) to see a list of surface object properties and legal
%   property values.
%
%   See also SURF, LINE, PATCH, TEXT, SHADING.

%   Copyright 1984-2015 The MathWorks, Inc. 
%   Built-in function.
