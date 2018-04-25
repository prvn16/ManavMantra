function A = subsasgn(A,S,B)
%AXISOBJ/SUBSASGN Subscript assign for axisobj object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 

switch S.type
case '.'
   switch S.subs
   case 'FigObj'
      A.FigObj = B;
   case 'Notes'
      A.Notes = B;
   otherwise
      HGObj = A.scribehgobj;
      A.scribehgobj = subsasgn(HGObj,S,B);
   end
end
