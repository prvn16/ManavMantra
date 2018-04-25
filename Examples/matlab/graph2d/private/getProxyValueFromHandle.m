function val = getProxyValueFromHandle(hObj)
%GETPROXYVALUEFROMHANDLE Returns a proxy value corresponding to its plot
%   edit mode proxy.

% VAL = getProxyValueFromHandle(OBJ) returns the proxy value associated
% with OBJ. If the object is not currently registered, it is registered
% with plot edit mode.
%
% See also GETHANDLEFROMPROXYVALUE

%   Copyright 2006-2013 The MathWorks, Inc.

if isempty(hObj) || ~all(ishghandle(hObj))
    error(message('MATLAB:graph2d:getProxyValueFromHandle:InvalidHandle'));
end
val = zeros(size(hObj));
newVals = now+(1:length(hObj));
for i = 1:length(hObj)
    currObj = hObj(i);
    hFig = ancestor(currObj,{'figure','uipanel','uitab'});
    if isempty(hFig)
        error(message('MATLAB:graph2d:getProxyValueFromHandle:InvalidObject'));
    end
    currVal = getappdata(double(currObj),'ScribeProxyValue');
    hMode = plotSelectMode(hFig);
    if isempty(currVal) || ...
            isempty(hMode.ModeStateData.ChangedObjectHandles(hMode.ModeStateData.ChangedObjectProxy == currVal))
        hMode.ModeStateData.ChangedObjectHandles(end+1) = handle(currObj);
        currVal = newVals(i);
        hMode.ModeStateData.ChangedObjectProxy(end+1) = currVal;
        setappdata(double(currObj),'ScribeProxyValue',hMode.ModeStateData.ChangedObjectProxy(end));
    end
    val(i) = currVal;
end
