classdef Environment < handle
    
    % Environment specific variables
    properties(Abstract)
        FullToolboxRoot
        RelativeToolboxRoot
        DependencyDatabasePath
    end
    
    properties(Constant)
        PcmPath = fullfile(fileparts(mfilename('fullpath')), ...
            ['pcm_' computer('arch') '_db']);
    end
    
end