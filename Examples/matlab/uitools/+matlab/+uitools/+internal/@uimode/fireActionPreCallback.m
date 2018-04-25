function fireActionPreCallback(hThis,evd)
% This function is undocumented and will change in a future release

%Execute the ActionPreCallback callback

%   Copyright 2013 The MathWorks, Inc.

hFig = hThis.FigureHandle;
blockState = hThis.Blocking;
hThis.Blocking = true;
try
    if ~isempty(hThis.ActionPreCallback)
        hgfeval(hThis.ActionPreCallback,hFig,evd);
    end
catch
    warning(message('MATLAB:uitools:uimode:callbackerror'));
end
hThis.Blocking = blockState;