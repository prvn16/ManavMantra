function remapfig(oldpos,newpos,fig,h)
% This function is undocumented and will change in a future release

%REMAPFIG  Transform figure objects' positions.
%   REMAPFIG(POS) takes a normalized position vector POS and places the 
%   contents of the current figure into the desired figure subsection.
%
%   REMAPFIG(OLDPOS,NEWPOS) repositions all the children of the figure 
%   into a new rectangle NEWPOS such that whatever was in OLDPOS before 
%   is now in NEWPOS.
%
%   REMAPFIG(OLDPOS,NEWPOS,FIG) does this in FIG, not the gcf (necessarily).
%
%   REMAPFIG(OLDPOS,NEWPOS,FIG,H) will change the positions of only the
%   objects in handle vector H.
%
%   Example:
%       f=figure;
%       u1 = uicontrol('Style','push', 'parent', f,'pos',...
%           [20 100 100 100],'string','button1');
%       u2 = uicontrol('Style','push', 'parent', f,'pos',...
%           [150 250 100 100],'string','button2');
%       u3 = uicontrol('Style','push', 'parent', f,'pos',...
%           [250 100 100 100],'string','button3');
%       %the following lines will reposition and resize the uicontrols
%       pos = [.25 .25 .5 .5];
%       remapfig(pos); 
%
%   See also FIGURE, MOVEGUI

%  Author(s): T. Krauss, 9/29/94
%  Copyright 1984-2010 The MathWorks, Inc.

if nargin == 1
    pos = oldpos;
elseif nargin >= 2 
    pos = newpos(3:4)./oldpos(3:4);
    pos = [newpos(1:2)-oldpos(1:2).*pos pos];
else
    narginchk(1,3)
end
if nargin < 3
    fig = gcf;
end
if nargin < 4
    h = get(fig,'Children');
end

for i = 1:length(h)
    if any(strcmp(get(h(i),'Type'),{'uimenu', 'uicontextmenu'}))
       % do nothing
   else
       saveunits = get(h(i),'Units');
       set(h(i),'Units','normalized');
       isAxes = strcmp(get(h(i),'Type'),'axes');
       if isAxes
         p = get(h(i),get(h(i),'ActivePositionProperty'));
       else
         p = get(h(i),'Position');
       end
       p(1:2) = p(1:2).*pos(3:4)+pos(1:2);
       p(3:4) = p(3:4).*pos(3:4);
       if isAxes
         set(h(i),get(h(i),'ActivePositionProperty'),p);
       else
         set(h(i),'Position',p);
       end
       set(h(i),'Units',saveunits);
    end
end


