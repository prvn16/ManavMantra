function B = subsref(uitxt,property)
%AXISTEXT/SUBSREF Subscripted reference for axistext object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 

switch property.type
case '.'
   switch property.subs
   case 'Notes'
      B = uitxt.Notes;
   otherwise
      hgObj = uitxt.axischild;
      B = subsref(hgObj,property);
   end
end
