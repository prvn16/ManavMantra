function hObj = getHandleFromProxyValue(hFig,val)
%GETHANDLEFROMRPOXYVALUE Returns a handle corresponding to the given plot
%   edit mode proxy.

% OBJ = getHandleFromProxyValue(FIG, VAL) returns the object associated
% with VAL in the given figure.
%
% See also GETPROXYVALUEFROMHANDLE

%   Copyright 2006-2009 The MathWorks, Inc.

if isempty(hFig) || ~ishghandle(hFig)
    error(message('MATLAB:graph2d:getHandleFromProxyValue:InvalidHandle'));
end

hMode = plotSelectMode(hFig);

for i = length(val):-1:1
    currObj = hMode.ModeStateData.ChangedObjectHandles(hMode.ModeStateData.ChangedObjectProxy == val(i));
    if isempty(currObj)
        error(message('MATLAB:graph2d:getHandleFromProxyValue:InvalidProxy'));
    end
    hObj(i) = currObj;
end