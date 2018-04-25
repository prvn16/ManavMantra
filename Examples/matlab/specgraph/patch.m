%PATCH Create one or more filled polygons
%   PATCH(X,Y,C) creates one or more filled polygons using the elements of
%   X and Y as the coordinates for each vertex. patch connects the vertices
%   in the order that you specify them. To create one polygon, specify X
%   and Y as vectors. To create multiple polygons, specify X and Y as
%   matrices where each column corresponds to a polygon. C determines the
%   polygon colors.
%
%   For both vector or matrix X and Y, if C is a string, each face is
%   filled with 'color'. 'color' can be 'r','g','b','c','m','y', 'w', or
%   'k'. If C is a scalar it specifies the color of the face(s) by indexing
%   into the colormap. A 1-by-3 vector C is always assumed to be an RGB
%   triplet specifying a color directly.
%
%   For vector X and Y, if C is a vector of the same length, it specifies
%   the color of each vertex as indices into the colormap and bilinear
%   interpolation is used to determine the interior color of the polygon
%   ("interpolated" shading).
%
%   When X and Y are matrices, if C is a 1-by-n, where n is the number of
%   columns in X and Y, then each face j=1:n is flat colored by the
%   colormap index C(j). Note the special case of a 1-by-3 C is always
%   assumed to be an RGB triplet ColorSpec and specifies the same flat
%   color for each face. If C is a matrix the same size as X and Y, then it
%   specifies the colors at the vertices as colormap indices and bilinear
%   interpolation is used to color the faces. If C is 1-by-n-by-3, where n
%   is the number of columns of X and Y, then each face j is flat colored
%   by the RGB triplet C(1,j,:). If C is m-by-n-by-3, where X and Y are
%   m-by-n, then each vertex (X(i,j),Y(i,j)) is colored by the RGB triplet
%   C(i,j,:) and the face is colored using interpolation.
%
%   PATCH(X,Y,Z,C) creates the polygons in 3-D coordinates using X, Y, and
%   Z. To view the polygons in a 3-D view, use the view(3) command. C
%   determines the polygon colors.
%
%   PATCH('XData',X,'YData',Y) is similar to PATCH(X,Y,C), except that you
%   do not have to specify color data for the 2-D coordinates.
%
%   PATCH('XData',X,'YData',Y,'ZData',Z) is similar to PATCH(X,Y,Z,C),
%   except that you do not have to specify color data for the 3-D
%   coordinates.
%
%   PATCH('Faces',F,'Vertices',V) creates one or more polygons where V
%   specifies vertex values and F defines which vertices to connect.
%   Specifying only unique vertices and their connection matrix can reduce
%   the size of the data when there are many polygons. Specify one vertex
%   per row in V. To create one polygon, specify F as a vector. To create
%   multiple polygons, specify F as a matrix with one row per polygon. Each
%   face does not have to have the same number of vertices. To specify
%   different numbers of vertices, pad F with NaN values.
%
%   PATCH(S) creates one or more polygons using structure S. The structure
%   fields correspond to patch property names and the field values
%   corresponding to property values. For example, S can contain the fields
%   Faces and Vertices.
%
%   PATCH(...,Name,Value) creates polygons and specifies one or more patch
%   properties using name-value pair arguments. A patch is the object that
%   contains the data for all of the polygons created. You can specify
%   patch properties with any of the input argument combinations in the
%   previous syntaxes. For example, 'LineWidth',2 sets the outline width
%   for all of the polygons to 2 points.
%
%   PATCH(container,...) creates polygons in the axes, group, or transform
%   specified by container, instead of in the current axes.
%
%   P = PATCH(...) returns the patch object that contains the data for all
%   the polygons.
%
%   Execute GET(P), where P is a patch object, to see a list of patch
%   object properties and their current values.
%   Execute SET(P) to see a list of patch object properties and legal
%   property values.
%
%   See also FILL, FILL3, LINE, TEXT, SHADING.
 
%   Copyright 1984-2015 The MathWorks, Inc. 
%   Built-in function.
