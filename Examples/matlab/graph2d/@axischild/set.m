function A = set(A, varargin)
%AXISCHILD/SET Set axischild property
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2015 The MathWorks, Inc. 

hgobjObj = A.scribehgobj;

if nargin == 3
   switch varargin{1}
   case 'Offset'
      A = LSetOffset(A,varargin{2});
   case 'AutoDragConstraint'
      A.AutoDragConstraint = varargin{2};
   case 'DragConstraint'
      A.DragConstraint = varargin{2};
   case 'OldDragConstraint'
      switch varargin{2}
      case 'save'
	 A.OldDragConstraint = A.DragConstraint;
      case 'restore'
	 A.DragConstraint = A.OldDragConstraint;
      end   
   case 'Prefix'
      A.Prefix = varargin{2};
   case 'Suffix'
      A.Suffix = varargin{2};
   case 'EraseMode'
      % Ignore all attempts to set EraseMode since it is no longer
      % supported in the HG object.
   otherwise
      A.scribehgobj = set(hgobjObj, varargin{:});
   end
else
   A.scribehgobj = set(hgobjObj, varargin{:});
end



function A = LSetOffset(A,initialPosition)

savedState = get(A, 'SavedState');
figH = get(A,'Figure');
axH = get(A,'Axis');

set(figH,'CurrentPoint',initialPosition);
pointer = get(axH, 'CurrentPoint');
pointX = pointer(1,1);
pointY = pointer(1,2);

savedState.PointX = pointX;
savedState.PointY = pointY;

% call these with my handle, so that they can be overloaded...
myH = get(A,'MyHandle');
X = get(myH, 'XData');
Y = get(myH, 'YData');
savedState.iPoints = 1:length(X);

savedState.OffsetX = pointX-X(1);
savedState.OffsetY = pointY-Y(1);
A = set(A, 'SavedState', savedState);

