function changeRoot(h, mdlname)
%CHANGEROOT Changes the root in the editor.
%   OUT = CHANGEROOT(ARGS) <long description>

%   Copyright 2011-2012 The MathWorks, Inc.


% Change the root
oldroot = h.getRoot;
% Delete listeners attached to the old root
idx = [];
for i = 1:numel(h.MEListeners)
    if isequal(h.MEListeners(i).SourceObject,oldroot.daobject) 
        delete(h.MEListeners(i));  
        idx = [idx i];        %#ok<AGROW>
    end
end
h.MEListeners(idx) = [];
% Clear out previously selected shortcut name
h.BAEName = '';
rootObj = get_param(mdlname,'Object');
newroot = fxptui.BAERoot(rootObj);
h.setRoot(newroot);
% Unpopulate after setting the newroot - G469179
oldroot.unpopulate;
delete(oldroot);
newroot.firehierarchychanged;
%add listeners to new root
h.MEListeners(end+1) = handle.listener(rootObj, 'CloseEvent', @(s,e)cleanup(h));
if h.isVisible
    selectNode(h);
end



% [EOF]
