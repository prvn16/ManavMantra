classdef File < matlab.unittest.internal.coverage.MATLABSource
    % Class is undocumented and may change in a future release.
    
    %  Copyright 2017 The MathWorks, Inc.
    
    properties (SetAccess = private)
        Name string  = string.empty(1,0);
    end
    
    methods
        function sources = File(fileArray)
            if nargin<1
                return
             end
            sources = repmat(sources,size(fileArray));
            [sources.Name] = fileArray{:};
        end
        
        function file = getFiles(source)
            file = source.Name;
        end
        
        function folderName = getFolderName(source)
            folderName = fileparts(source.Name);
        end
    end
end

