function clientforeach(workerFcn, clientFcn, varargin)
%CLIENTFOREACH Helper that calls the underlying clientforeach

%   Copyright 2017 The MathWorks, Inc.

% This prevents this frame and anything below it being added to the gather
% error stack.
frameMarker = matlab.bigdata.internal.InternalStackFrame; %#ok<NASGU>

try
    inputs = unpackValueImpls(varargin);
    clientforeach(workerFcn, clientFcn, inputs{:});
catch err
    matlab.bigdata.internal.util.assertNotInternal(err);
    rethrow(err);
end

end
