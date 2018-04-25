function aObj = editopen(aObj)
%AXISOBJ/EDITOPEN Edit axisobj object
%   This file is an internal helper function for plot annotation.

%   edit axis properties on double click

%   Copyright 1984-2015 The MathWorks, Inc. 

selection = get(getobj(get(aObj,'Figure')),'Selection');

%get a list of all handles currently selected in figure
if ~isempty(selection)
    hList = subsref(selection,substruct('.','HGHandle'));
    if iscell(hList)
        hList=[hList{:}];
    end
else
    hgobj = aObj.scribehgobj;
    if ~isempty(hgobj)
        hList=hgobj.HGHandle;
    else
        hList=get(gcf,'CurrentAxes');
    end
end
    
propedit(hList,'-noselect');
