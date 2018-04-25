function aObj = doclick(aObj)
%SCRIBEHGOBJ/DOCLICK Click method for scribehgobj object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2009 The MathWorks, Inc. 

figH = get(aObj,'Figure');
figObjH = getobj(figH);

selType = get(figH,'SelectionType');

switch selType
case 'open'
   aObj = editopen(aObj);
otherwise
   aObj = doselect(aObj, selType, figObjH,'down');
   myH = get(aObj,'MyHandle');
   myHG = get(myH,'MyHGHandle');
   setappdata(figH,'ScribeCurrentObject', myH);
   
   if get(aObj,'IsSelected')
      selection = get(figObjH,'Selection');
      hList = subsref(selection,substruct('.','HGHandle'));
      if iscell(hList)
         hList=[hList{:}];
      end
   end
   
   if get(aObj,'IsSelected') && ...
      get(aObj,'Draggable') && ...
      ~strcmp(selType,'alt') %don't drag on right-clicks
      aObj = dragconstrained(aObj, selType, figH);
   else
      ud = getscribeobjectdata(myHG);
      % write current changes
      ud.ObjectStore = aObj;
      setscribeobjectdata(myHG,ud);
      set(figH,'WindowButtonUpFcn','prepdrag');
   end

   if ~isempty(hList)
       warnStr=propedit(hList,'-noopen','-noselect');
       %calling propedit with an output argument causes it
       %to error silently.
   end
end

