function btnresize(ax)
%BTNRESIZE  Resize Button Group.
%  BTNRESIZE(AX) resizes the uicontrols of the button groups
%  associated with btngroup axes in vector AX.  To use
%  this function, first set the position of the button
%  group axes, and then call this function.
%
%  See also BTNGROUP, BTNSTATE, BTNPRESS, BTNDOWN, BTNUP.

%  Author: T. Krauss, 6/27/99
%  Copyright 1984-2010 The MathWorks, Inc. 

for i=1:length(ax)
   ud = get(ax(i),'UserData');
   numButtons = length(ud.uicontrolButtons);
   if numButtons == 0
      % do nothing if uicontrols not present
   else
      axUnits=get(ax(i),'Units');
      aPos = get(ax(i),'Position');
      xOffsetPix = ud.xOffset*aPos(3);
      yOffsetPix = ud.yOffset*aPos(4);
      groupSize = ud.groupSize;

      for k = 1:numButtons
         buttonPix = [xOffsetPix(k) yOffsetPix(k) ...
                       aPos(3)/groupSize(2) aPos(4)/groupSize(1)];

         saveUnits = get(ud.uicontrolButtons(k),'Units');
         set(ud.uicontrolButtons(k),'Units',axUnits,...
               'Position',[aPos(1:2) 0 0]+buttonPix)
         set(ud.uicontrolButtons(k),'Units',saveUnits)
      end
   end

end % for loop over btngroup objects

% [EOF] btnresize.m
