classdef(Abstract) Source < matlab.mixin.Heterogeneous
    % Class is undocumented and may change in a future release.
    
    %  Copyright 2017 The MathWorks, Inc.
    
    properties(Abstract, SetAccess = private)
        Name string
    end
    
    methods (Abstract)
          files = getFiles(sources)
          folderName = getFolderName(source)
    end
end