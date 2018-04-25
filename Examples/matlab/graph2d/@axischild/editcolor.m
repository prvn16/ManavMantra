function aObj = editcolor(aObj)
%AXISCHILD/EDITCOLOR Edit axischild color
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 

HG = get(aObj,'MyHGHandle');
c = uisetcolor(HG);

if length(c)>1
   aObj = set(aObj,'Color',c);
   refresh;
end

