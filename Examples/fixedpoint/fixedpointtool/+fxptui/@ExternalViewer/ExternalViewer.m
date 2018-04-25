classdef ExternalViewer < handle
    %EXTERNALVIEWER Abstract Class of external viewer as API
	
	%   Copyright 2013-2016 The MathWorks, Inc.
       
    methods(Static)
        function updateGlobalEnabledState(enable) %#ok<INUSD>
        end
        function runRenamed(oldRunName, newRunName) %#ok<INUSD>
        end
        function proposedTypeAnnotated(result) %#ok<INUSD>
        end
        function runsDeleted(varargin)
        end
        function typesApplied(applySuccess) %#ok<INUSD>
        end
        function typesProposed(SUDObject) %#ok<INUSD>
        end
		function overrideConvertedMATLABFunctionBlocks(modelName, blkData) %#ok<INUSD>
        end
        function markSimCompleted 
        end
        function applyIdealizedShortcutBeforePropose
        end
        function restoreModelSettings
        end
    end
    
end

