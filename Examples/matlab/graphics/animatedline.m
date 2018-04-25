%ANIMATEDLINE Create animated line
%   ANIMATEDLINE creates an animated line that has no data and adds it to
%   the current axes. Add points to the line in a loop to create a line
%   animation.
%   
%   ANIMATEDLINE(x,y) creates an animated line with initial data points
%   defined by x and y. Specify x and y as scalars or vectors.
% 
%   ANIMATEDLINE(x,y,z) creates an animated line with initial data points
%   defined by x , y, and z. Specify x, y, and z as scalars or vectors.
% 
%   ANIMATEDLINE(...,Name,Value) specifies animated line properties using
%   one or more Name,Value pair arguments. For example, 'Color','r' sets
%   the line color to red. Use this option with any of the input argument
%   combinations in the previous syntaxes.
%
%   ANIMATEDLINE(container,...) creates the animated line in the axes,
%   group, or transform specified by container, instead of in the current
%   axes.
%
%   H = ANIMATEDLINE(...) returns the animated line object created.
%
%   Execute GET(H), where H is an animated line object, to see a list of
%   animatedline object properties and their current values.
%   Execute SET(H) to see a list of animated line object properties and
%   legal property values.
%
%   Example: 
%   numpoints = 100000; 
%   x = linspace(0,4*pi,numpoints); 
%   y = sin(x); 
% 
%   figure 
%   h = animatedline; 
%   axis([0,4*pi,-1,1]) 
% 
%   for k = 1:numpoints 
%     addpoints(h,x(k),y(k)) 
%     drawnow update 
%   end 
% 
%   See also ADDPOINTS, CLEARPOINTS, GETPOINTS.

%   Copyright 2014-2017 The MathWorks, Inc.
%   Built-in function. 
