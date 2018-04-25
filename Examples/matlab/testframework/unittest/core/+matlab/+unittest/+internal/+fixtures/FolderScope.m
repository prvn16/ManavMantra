classdef FolderScope < double
    % This class is undocumented and may change in a future release.
    
    % Copyright 2016 The MathWorks, Inc.
    
    enumeration
        % Across - Shared across folder boundaries, possibly across an entire suite.
        Across (1)
        
        % Boundary - Defines folder boundaries.
        Boundary (2)
        
        % Within - Shared only within a single folder.
        Within (3)
    end
end

