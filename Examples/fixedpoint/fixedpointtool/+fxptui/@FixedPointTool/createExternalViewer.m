function externalviewer = createExternalViewer(~)
% CREATEEXTERNALVIEWER Creates an external viewer instance to interact with
% the Codeview UI.

% Copyright 2015-2016 The MathWorks, Inc.

if fxptui.isMATLABFunctionBlockConversionEnabled()
    externalviewer = fxptui.CodeViewExternal;
else
    externalviewer = fxptui.ExternalViewer;
end
end