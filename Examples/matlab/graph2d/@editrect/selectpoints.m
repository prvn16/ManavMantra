function [iPoints, aObj] = selectpoints(aObj, X, Y, pointX, pointY)
%EDITRECT/SELECTPOINTS Select points for editrect object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2009 The MathWorks, Inc. 

fig = get(aObj,'Figure');

% get nearest edge
dx = abs(X-pointX);
dy = abs(Y-pointY);

iNearestX = find(min(dx)==dx);
iNearestY = find(min(dy)==dy);

aObj = set(aObj,'OldDragConstraint','save');
if min([dx dy]) > .01
   iPoints = 1:length(X);
elseif min(dx) < min(dy)
   aObj = set(aObj,'DragConstraint','fixY');
   iPoints = iNearestX;
   if X(iNearestX) == min(X)
      set(fig,'Pointer','left');
   else
      set(fig,'Pointer','right'); 
   end
else
   aObj = set(aObj,'DragConstraint','fixX');
   iPoints = iNearestY;
   if Y(iNearestY) == min(Y)
      set(fig,'Pointer','bottom');
   else
      set(fig,'Pointer','top'); 
   end
end


