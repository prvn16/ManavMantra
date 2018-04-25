function A = subsasgn(A,S,B)
%FIGHANDLE/SUBSASGN Subscripted assignment for fighandle object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 

UD = getscribeobjectdata(A.figStoreHGHandle);

switch S.subs
case 'ObjectStore'
   UD.ObjectStore = B;
   setscribeobjectdata(A.figStoreHGHandle,UD);
otherwise
   UD.(S.subs) = B;
   setscribeobjectdata(A.figStoreHGHandle,UD);   
end
