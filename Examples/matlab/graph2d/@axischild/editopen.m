function aObj = editopen(aObj)
%AXISCHILD/EDITOPEN Edit axischild
%   This file is an internal helper function for plot annotation.

%   edit on doubleclick

%   Copyright 1984-2015 The MathWorks, Inc. 

selection = get(getobj(get(aObj,'Figure')),'Selection');

%get a list of all handles currently selected in figure
hList = subsref(selection,substruct('.','HGHandle'));
if iscell(hList) 
    hList=[hList{:}];
end
    
propedit(hList,'-noselect');
