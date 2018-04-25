function aObj = dodrag(aObj, varargin)
%EDITLINE/DODRAG Drag editline object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2009 The MathWorks, Inc. 

savedState.me = aObj;
figH = get(aObj,'Figure');

if nargin==2
   initialPosition = varargin{1};
   set(figH,'CurrentPoint',initialPosition);
end

myHG = get(aObj,'MyHGHandle');
myH = get(aObj,'MyHandle');

axH = get(aObj,'Axis');

savedState.EraseMode = get(myHG,'EraseMode');

prefix = get(aObj,'Prefix');
if ~isempty(prefix)
   feval(prefix{1},myH,prefix{2:end});
end

pointer = get(axH, 'CurrentPoint');
pointX = pointer(1,1);
pointY = pointer(1,2);

savedState.PointX = pointX;
savedState.PointY = pointY;

savedState.SelType = get(figH,'SelectionType');

savedState.Fig = figH;
savedState.Ax = axH;

XY = get(myHG,{'XData', 'YData'});
X = XY{1};
Y = XY{2};

[savedState.iPoints, aObj] = selectpoints(aObj, X, Y, pointX, pointY);

savedState.OffsetX = pointX-X(savedState.iPoints(1));
savedState.OffsetY = pointY-Y(savedState.iPoints(1));

aObj = set(aObj,'SavedState',savedState);







