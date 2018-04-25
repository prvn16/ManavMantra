classdef (Abstract) MATLABSource < matlab.unittest.internal.coverage.Source
    % Class is undocumented and may change in a future release.
    
    %  Copyright 2017 The MathWorks, Inc.
    
    
    methods (Sealed)
        function fileInformationArray = produceFileInformation(sources)            
            import matlab.unittest.internal.fileinformation.FileInformation;

            numSources = numel(sources);
            fileInfoCell = cell(1,numSources);
            for idx = 1: numSources
                files = getFiles(sources(idx));
                fileInfoCell{idx} = getFileInformationFromFiles(files);
            end
            fileInformationArray = [FileInformation.empty(1,0) fileInfoCell{:}];
        end
    end
end
function fileInformationArray = getFileInformationFromFiles(files)
import matlab.unittest.internal.fileinformation.FileInformation;

numFiles = numel(files);
fileInfoCell = cell(1,numFiles);
for idx = 1: numFiles
    fileInfoCell{idx} = FileInformation.forFile(files{idx});
end
fileInformationArray = [FileInformation.empty(1,0) fileInfoCell{:}];
end
