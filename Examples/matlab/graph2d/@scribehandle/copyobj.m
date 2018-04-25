function newHandle = copyobj(A, newParentH)
%SCRIBEHANDLE/COPYOBJ Copy scribehandle object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2008 The MathWorks, Inc. 

newHandle = [];

if isa(A,'scribehandle')
   aHG = A.HGHandle;
   ud = getscribeobjectdata(aHG);
   aObj = ud.ObjectStore;
elseif isa(A,'scribehgobj')
   aObj = A;
   aHG = A.HGHandle;
else
   error(message('MATLAB:copyobj:NeedHandle'))
end

selected = get(A,'IsSelected');

if nargin==1
   HGParent = get(aHG,'parent');
else
   HGParent = newParentH;
end
   
newObj = copyobj(aObj,HGParent);
if isempty(newObj), return, end

newHandle = scribehandle(newObj);

if selected
   set(newHandle,'IsSelected',selected);
end
