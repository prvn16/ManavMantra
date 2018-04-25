%LINE Create line
%   LINE(X,Y) adds the line defined in vectors X and Y to the current axes.
%   If X and Y are matrices of the same size, line draws one line per
%   column.
%   
%   LINE(X,Y,Z) creates lines in three-dimensional coordinates.
%
%   LINE('XData',x,'YData',y,'ZData',z,...) creates a line in the current
%   axes using the Name,Value pairs as arguments. This is the low-level
%   form of the line function, which does not accept matrix coordinate data
%   as the other informal forms described above.
%
%   LINE(...,Name,Value) specifies line properties using one or more
%   Name,Value pair arguments.
%   
%   LINE(container,...) creates the line in the axes, group, or transform
%   specified by container, instead of in the current axes.
%   
%   H = LINE(...)  returns a column vector of the primitive line objects
%   created.
%
%   Execute GET(H), where H is a line object, to see a list of line object
%   properties and their current values.
%   Execute SET(H) to see a list of line object properties and legal
%   property values.
%
%   See also PATCH, TEXT, PLOT, PLOT3.

%   Copyright 1984-2015 The MathWorks, Inc. 
%   Built-in function.
