function aObj = dragconstrained(aObj, selType, figH)
%SCRIBEHGOBJ/DRAGCONSTRAINED Drag scribehgobj object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 

initialPosition = get(figH,'CurrentPoint');
myHG = get(aObj,'MyHGHandle');
myH = get(aObj,'MyHandle');
ud = getscribeobjectdata(myHG);
% write current changes
ud.ObjectStore = aObj;
setscribeobjectdata(myHG,ud);

dragConstraint = '';
fDoDrag = 1;

   % if ~get(aObj,'AutoDragConstraint')
   %   dragConstraint = get(aObj,'DragConstraint');
   % end

   switch dragConstraint
   case 'fixX'
      dragPointer = 'bottom';
   case 'fixY'
      dragPointer = 'left';
   case ''
      dragPointer = 'fleur';
   case 'nodrag'
      dragPointer = 'arrow';
      fDoDrag = 0;
   end

if fDoDrag
   set(figH,'Pointer',dragPointer);  
   
   % Fully initialize dragging.  The next mouse movement will execute
   % middrag
   prepdrag(0,initialPosition);
   prepdrag('start');
end

% reset and deselect properly on button up.
set(figH,'WindowButtonUpFcn','prepdrag');

aObj = myH.Object;
