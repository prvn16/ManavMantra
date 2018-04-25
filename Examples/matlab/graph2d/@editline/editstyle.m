function aObj = editstyle(aObj, style)
%EDITLINE/EDITSTYLE Edit editline linestyle
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 


switch style
case 'solid'
   val = '-';
case 'dash'
   val = '--';
case 'dot'
   val = ':';
case 'dashdot'
   val = '-.';
otherwise
   return
end

aObj = set(aObj, 'LineStyle', val);
