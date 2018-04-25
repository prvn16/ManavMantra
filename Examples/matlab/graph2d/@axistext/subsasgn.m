function uitxt = subsasgn(uitxt,property,newval)
%AXISTEXT/SUBSASGN Subscripted assignment for axistext object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 

switch property.type
case '.'
   switch property.subs
   case 'Notes'
      uitxt.Notes = newval;
   otherwise
      hgObj = uitxt.axischild;
      uitxt.axischild = subsasgn(hgObj,property,newval);
   end
end
