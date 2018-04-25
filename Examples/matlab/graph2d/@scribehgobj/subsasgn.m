function A = subsasgn(A,S,B)
%SCRIBEHGOBJ/SUBSASGN Subscripted assignment for scribehgobj object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 

switch S.type
case '.'
   switch S.subs
   case 'HGHandle'
      A.HGHandle = B;
   case 'IsSelected'
      A.ObjSelected = B;
   otherwise
      A = set(A,S.subs,B);
   end
case '()'
   A = class(A,'scribehgobj');
end

