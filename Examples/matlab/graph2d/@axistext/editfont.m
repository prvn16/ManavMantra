function aObj = editfont(aObj)
%AXISTEXT/EDITFONT Edit text font for axistext object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2015 The MathWorks, Inc. 

%fig = get(A,'Figure');
% scribetextdlg(get(getobj(fig),'Selection'));
%hg = get(A,'MyHGHandle');
%jpropeditutils('jedit',hg);


selection = get(getobj(get(aObj,'Figure')),'Selection');

%get a list of all handles currently selected in figure
hList = subsref(selection,substruct('.','HGHandle'));
if iscell(hList)
    hList=[hList{:}];
end
    
propedit(hList);
