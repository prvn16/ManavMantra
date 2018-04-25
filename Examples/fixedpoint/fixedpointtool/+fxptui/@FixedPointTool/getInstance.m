function obj = getInstance(model)
% GETINSTANCE Returns the stored instance of the repository.

% Copyright 2015-2016 The MathWorks, Inc.

    if nargin < 1
        [msg, identifier] = fxptui.message('incorrectInputArgsModel');
        e = MException(identifier, msg);
        throwAsCaller(e);
    end
    if nargin > 0
        sys = find_system('type','block_diagram','Name',model);
        if isempty(sys)
            [msg, identifier] = fxptui.message('modelNotLoaded',model);
            e = MException(identifier, msg);
            throwAsCaller(e);
        end
    end
    obj = fxptui.FixedPointTool.Instance;
    obj.setModel(model);
    obj.initSDIEngineListeners;
end
