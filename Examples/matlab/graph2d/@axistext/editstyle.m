function aObj = editstyle(aObj, style)
%AXISTEXT/EDITSTYLE Edit font style for axistext object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 

notNormal = strcmp(get(gcbo,'Checked'),'on');

switch style
case 'normal'
   aObj = set(aObj,'FontAngle','normal');   
   aObj = set(aObj,'FontWeight','normal');
case 'italic'
   if notNormal
      angle = 'normal';
   else
      angle = 'italic';
   end
   aObj = set(aObj,'FontAngle',angle);
case 'bold'
   if notNormal
      weight = 'normal';
   else
      weight = 'bold';
   end
   aObj = set(aObj,'FontWeight',weight);
end
