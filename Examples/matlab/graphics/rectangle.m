%RECTANGLE Create rectangle, rounded-rectangle, or ellipse
%   RECTANGLE adds a default rectangle to the current axes.
%   
%   RECTANGLE('Position',pos) creates a rectangle in 2-D coordinates.
%   Specify pos as a four-element vector of the form [x y w h] in data
%   units. The x and y elements determine the location and the w and h
%   elements determine the size. The function plots into the current axes
%   without clearing existing content from the axes.
%   
%   RECTANGLE('Position',pos,'Curvature',cur) adds curvature to the sides
%   of the rectangle. For different curvatures along the horizontal and
%   vertical sides, specify cur as a two-element vector of the form
%   [horizontal vertical]. For the same length of curvature along all
%   sides, specify cur as a scalar value. Specify values between 0 (no
%   curvature) and 1 (maximum curvature). Use [1 1] to create an ellipse or
%   circle.
%
%   RECTANGLE(...,Name,Value) specifies rectangle properties using one or
%   more Name,Value pair arguments.
%   
%   RECTANGLE(container,...) creates the rectangle in the axes, group, or
%   transform specified by container, instead of in the current axes.
%   
%   R = RECTANGLE(...) returns the rectangle object created.
%
%   Execute GET(R), where R is a rectangle object, to see a list of
%   rectangle object properties and their current values.
%   Execute SET(R) to see a list of rectangle object properties and legal
%   property values.
%
%   See also LINE, PATCH, TEXT, PLOT, PLOT3.

%   Copyright 1984-2015 The MathWorks, Inc. 
%   Built-in function.
