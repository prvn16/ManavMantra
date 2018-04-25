function hAxOut = legendcolorbarlayout(hAx,action,varargin)
%LEGENDCOLORBARLAYOUT Layout legend and/or colorbar around axes
%   This is a helper function for legend and colorbar. Do not call
%   directly.

%   LEGENDCOLORBARLAYOUT(AX,'addToTree',h) adds h as a child of the layout 
%   manager, but does not add h to the inner or outer list.  The position
%   of h will not be managed by the layout manager.
%   LEGENDCOLORBARLAYOUT(AX,'addToLayout',h) adds h to the end of the
%   layout list.

%   Copyright 1984-2016 The MathWorks, Inc.

% First, make sure we have a valid axes:
if ~isvalid(hAx) || ~(isgraphics(hAx,'axes') || isgraphics(hAx,'polaraxes'))
    error(message('MATLAB:scribe:legendcolorbarlayout:InvalidAxes'));
end

hManager  = matlab.graphics.shape.internal.AxesLayoutManager.getManager(hAx);

if nargout > 0
    hAxOut = hManager.Axes;
end

switch action
    case 'addToTree'
        hManager.addToTree(varargin{1});
    case 'addToLayout'
        hManager.addToLayout(varargin{1});
end
