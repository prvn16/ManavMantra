function h = overobj(Type)
% This function is undocumented and will change in a future release

%OVEROBJ Get handle of object the pointer is over.
%   H = OVEROBJ(TYPE) check searches visible objects of Type TYPE in 
%   the PointerWindow looking for one that is under the pointer.  It
%   returns the handle to the first object it finds under the pointer
%   or else the empty matrix.
%
%   Notes:
%   Assumes root units are pixels
%   Only works with object types that are children of figure
%
%   Example:
%       axes ; 
%       %after executing the following line place the pointer over the axes
%       %object or else the overobj function will return empty
%       pause(2),overobj('axes')
%
%   See also UICONTROL, UIPANEL

%   Copyright 1984-2013 The MathWorks, Inc.

fig = matlab.ui.internal.getPointerWindow();
% Look for quick exit
if fig==0
   h = [];
   return
end

% Assume root and figure units are pixels
p = get(0,'PointerLocation');
% Get figure position in pixels
%figUnit = get(fig,'Units');
%set(fig,'Units','pixels');
figPos = get(fig,'Position');
%set(fig,'Units',figUnit)

x = (p(1)-figPos(1))/figPos(3);
y = (p(2)-figPos(2))/figPos(4);
c = findobj(get(fig,'Children'),'flat','Type',Type,'Visible','on');
for h = c'
   hUnit = get(h,'Units');
   set(h,'Units','norm')
   r = get(h,'Position');
   set(h,'Units',hUnit)
   if ( (x>r(1)) && (x<r(1)+r(3)) && (y>r(2)) && (y<r(2)+r(4)) )
      return
   end
end
h = [];

% end overobj
