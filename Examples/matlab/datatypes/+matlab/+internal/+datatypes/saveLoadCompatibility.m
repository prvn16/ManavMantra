classdef (Abstract) saveLoadCompatibility
    
    properties(Abstract, Constant, Access='protected')
        version;
    end

    methods(Hidden)
        function serialized = setCompatibleVersionLimit(obj, serialized, minCompatVer)
            serialized.versionSavedFrom = obj.version; % scalar double. version number of saved object
            serialized.minCompatibleVersion = minCompatVer; % scalar double. minimum running version required to reconstruct an instance from serialized data
            serialized.incompatibilityMsg = '';        % character row vector. Addition to warning message in case of incompatible load
        end

        function tf = isIncompatible(obj, serializedObj, warnMsgID)
            % Warn if current version is below the minimum compatible version of the serialized object
            tf = obj.version < serializedObj.minCompatibleVersion;
            if tf
                warnState = warning('backtrace','off'); % warn without backtrace for cleaner display
                restoreWarnState = onCleanup(@()warning(warnState));
                msg = strcat(getString(message(warnMsgID)), serializedObj.incompatibilityMsg);
                warning(warnMsgID, msg);
            end
        end
    end
end