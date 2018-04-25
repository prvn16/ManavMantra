function B = subsref(A,S)
%AXISOBJ/SUBSREF Subscript reference for axisobj object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 

switch S.type
case '.'
   switch S.subs
   case 'FigObj'
      B = A.FigObj;
   case 'Notes'
      B = A.Notes;
   otherwise
      HGObj = A.scribehgobj;
      B = subsref(HGObj,S);
   end
end
