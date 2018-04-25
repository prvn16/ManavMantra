function ChildList=allchild(HandleList)
%ALLCHILD Get all object children
%   ChildList=ALLCHILD(HandleList) returns the list of all children 
%   (including ones with hidden handles) for each handle.  If 
%   HandleList is a single element, the output is returned in a 
%   vector.  Otherwise, the output is a cell array.
%
%   Example:
%       h_gca = gca;
%       h_gca.Children
%           %or
%       allchild(gca)
%
%   See also GET, FINDALL.

%   Loren Dean
%   Copyright 1984-2015 The MathWorks, Inc.
%    

narginchk(1,1);

% figure out which, if any, items in list don't refer to hg objects
hgIdx = ishghandle(HandleList); % index of hghandles in list
nonHGHandleList = HandleList(~hgIdx); 

% if any of the items in the nonHGHandlList aren't handles, error out
if ~isempty(nonHGHandleList) && ~all(ishandle(nonHGHandleList))
  error(message('MATLAB:allchild:InvalidHandles'))
end  

% establish the root object
rootobj = allchildRootHelper(HandleList);

Temp=get(rootobj,'ShowHiddenHandles');
set(rootobj,'ShowHiddenHandles','on');
% Create protected cleanup
c = onCleanup(@()set(rootobj,'ShowHiddenHandles',Temp));

if(isscalar(HandleList))
    ChildList = getchildren(HandleList);
else
    l = arrayfun(@getchildren,HandleList,'UniformOutput',false);
    if isempty(l)
        ChildList = []; % return [] if no objects found
    else
        ChildList = l(:);
    end
end

end 

function children = getchildren(h)
if(isa(h,'matlab.graphics.axis.Axes') || isa(h,'matlab.ui.control.UIAxes'))
    children = getAllchildChildren(h);
else
    children = get(h,'Children');
end
end
