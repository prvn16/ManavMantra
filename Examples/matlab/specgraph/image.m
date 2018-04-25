%IMAGE Display image from array
%   IMAGE(C) displays the data in array C as an image. Each element of C
%   specifies the color for 1 pixel of the image. The resulting image is an
%   m-by-n grid of pixels where m is the number of columns and n is the
%   number of rows in C. The row and column indices of the elements
%   determine the centers of the corresponding pixels.
%
%   When C is a 2-dimensional m-by-n matrix, the elements of C are used as
%   indices into the current COLORMAP to determine the color.  The value of
%   the image object's CDataMapping property determines the method used to
%   select a colormap entry.  For 'direct' CDataMapping (the default),
%   values in C are treated as colormap indices (1-based if double, 0-based
%   if uint8 or uint16).  For 'scaled' CDataMapping, values in C are first
%   scaled according to the axes CLim and then the result is treated as a
%   colormap index.  When C is a 3-dimensional m-by-n-by-3 matrix, the
%   elements in C(:,:,1) are interpreted as red intensities, in C(:,:,2) as
%   green intensities, and in C(:,:,3) as blue intensities, and the
%   CDataMapping property of image is ignored.  For matrices containing
%   doubles, color intensities are on the range [0.0, 1.0].  For uint8 and
%   uint16 matrices, color intensities are on the range [0, 255].
%
%   IMAGE(C) places the center of element C(1,1) at (1,1) in the axes, and
%   the center of element (M,N) at (M,N) in the axes, and draws each
%   rectilinear patch as 1 unit in width and height.  As a result, the
%   outer extent of the image occupies [0.5 N+0.5 0.5 M+0.5] of the axes,
%   and each pixel center of the image lies at integer coordinates ranging
%   between 1 and M or N.
%
%   IMAGE(x,y,C) specifies the image location. Use x and y to specify the
%   locations of the corners corresponding to C(1,1) and C(m,n). To specify
%   both corners, set x and y as two-element vectors. To specify the first
%   corner and let image determine the other, set x and y as scalar values.
%   The image is stretched and oriented as applicable.
%
%   IMAGE('CData',C) adds the image to the current axes without replacing
%   existing plots. This syntax is the low-level version of image(C).
%
%   IMAGE('XData',x,'YData',y,'CData',C) specifies the image location. This
%   syntax is the low-level version of image(x,y,C).
%
%   IMAGE(...,Name,Value) specifies image properties using one or more
%   Name,Value pair arguments. You can specify image properties with any of
%   the input argument combinations in the previous syntaxes.
%
%   IMAGE(container,...) creates the image in the axes, group, or transform
%   specified by container, instead of in the current axes.
%
%   IM = IMAGE(...) returns the image object created.  Use im to set
%   properties of the image after it is created. You can specify this
%   output with any of the input argument combinations in the previous
%   syntaxes.
%
%   When called with C or X,Y,C, IMAGE sets the axes limits to tightly
%   enclose the image, sets the axes YDir property to 'reverse', and sets
%   the axes View property to [0 90].
%
%   Execute GET(IM), where IM is an image object, to see a list of image
%   object properties and their current values.
%   Execute SET(IM) to see a list of image object properties and legal
%   property values.
%
%   See also IMSHOW, IMAGESC, COLORMAP, PCOLOR, SURF, IMREAD, IMWRITE.

%   Copyright 1984-2015 The MathWorks, Inc. 
%   Built-in function.
