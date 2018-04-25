function [ids, pathBlk] = InstrumentationLocationInterface(in)
% InstrumentationLocationInterface: given a set of block handles
% returns the correspondent set of unique ids and block paths.

%   Copyright 2016-2017 The MathWorks, Inc.
    ids = cell(1, length(in));
    pathBlk = cell(1, length(in));
    try
        for iPt = 1:length(in)
            % Get SL identifier
            blockSID = Simulink.ID.getSID(in(iPt).Key);
            blockHandle = Simulink.ID.getHandle(blockSID);
            blockObj = get_param(blockHandle, 'Object');
            uniqueId = fxptds.SimulinkIdentifier(blockObj, in(iPt).OutPortIdx);
            ids{iPt} = uniqueId.UniqueKey;

            % Collect block paths
            pathBlk{iPt} = getfullname(blockHandle);
        end
    catch
        % Return empty cell array on exception
        ids = {};
        pathBlk = {};
    end
end
