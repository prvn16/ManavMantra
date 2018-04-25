classdef Folder < matlab.unittest.internal.coverage.MATLABSource
    % Class is undocumented and may change in a future release.
    
    %  Copyright 2017 The MathWorks, Inc.
    
    properties (SetAccess = private)
        Name string = string.empty(1,0);
    end
    
    methods
        function sources = Folder(folders)
             if nargin<1
                return
             end
            sources = repmat(sources,size(folders));
            [sources.Name] = folders{:};
        end
        
        function files = getFiles(source)
            currentContent = what(char(source.Name));
            filesCell = [fullfile(currentContent.path,currentContent.m)', fullfile(currentContent.path,currentContent.mlx)'];
            files = string(filesCell);
        end
        
        function folderName = getFolderName(source)
            folderName = source.Name;
        end
    end
end