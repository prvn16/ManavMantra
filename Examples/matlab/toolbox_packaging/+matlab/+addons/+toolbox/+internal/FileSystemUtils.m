classdef FileSystemUtils
    %FILESYSTEMUTILS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods(Static)
        
        % Returns a list of subdirectories found recursively from the root
        % input folder. The Subdirectories will be returned in BFS order 
        % and the file list will include the root folder.
        function BFSSubDirectories = findSubdirectoriesByBFS(rootFolder)
            subfoldersToSearch = {rootFolder};
            subfolderCollection = {rootFolder};
            while(numel(subfoldersToSearch)>0)
                %add all subfolders to the output list
                temp_subdirs=matlab.addons.toolbox.internal.FileSystemUtils.subdirectories(subfoldersToSearch{1});
                subfolderCollection = [subfolderCollection; temp_subdirs];
                %add all subfolders to be checked for further subfolders
                subfoldersToSearch(1)=[];
                subfoldersToSearch = [subfoldersToSearch; temp_subdirs];
            end
            BFSSubDirectories=subfolderCollection;
        end
        
        % Searches the given subfolder list to find the given file name.
        function [file] = findFileInFolders(fileName, allFolders, useCaseSensitivity)
            possibleMatches = ...
                cellfun(@(x) matlab.addons.toolbox.internal.FileSystemUtils.searchForFileByNameAndExt(x, fileName, useCaseSensitivity), ...
                allFolders, 'UniformOutput' , 0);
            indices = cell2mat(cellfun(@(x) ~isempty(x),possibleMatches,'UniformOutput',0));
            file = matlab.addons.toolbox.internal.FileSystemUtils.selectFirstMatch(possibleMatches, indices);
        end
        
        % Searches all subfolders under given root folder using breadth-first 
        % search logic to find the given file name.
        function [file] = findFileBFS(fileName, rootFolder, useCaseSensitivity)
            allFolders = matlab.addons.toolbox.internal.FileSystemUtils.findSubdirectoriesByBFS(rootFolder);
            file = matlab.addons.toolbox.internal.FileSystemUtils.findFileInFolders(fileName, allFolders, useCaseSensitivity);
        end

        % Uses alternative to 'exist' for file existence checks to avoid 
        % false positives based on file searches against the MATLAB search
        % path.  Falls back on using 'exist' if the Java VM is not
        % available.
        function exists = fileOrFolderExists(fileName)
            if usejava('jvm')
                exists = java.io.File(fileName).exists();
            else
                existResult = exist(fileName, 'file');
                exists = logical((existResult==2) || (existResult==7));
            end
        end
        
    end
    
    methods(Static, Access=private)

        %Returns a list of all the directories within a folder. This
        %function is not recursive.
        function subDirectories = subdirectories(folderName)
            allDirectories = dir(folderName);
            isub = [allDirectories(:).isdir];
            subDirectories = {allDirectories(isub).name}';
            subDirectories(ismember(subDirectories,{'.','..'})) = [];
            subDirectories = cellfun(@(x) fullfile(folderName, x), subDirectories, 'UniformOutput',false);
        end
        
        %function that returns the first result of a cell array or returns
        %'' (blanks string. This is useful if you know the returned values
        %are either 0 or 1 in quantity or if you just want the first result
        %for BFS reasons.
        function [firstResult] = selectFirstMatch(allItems, matchedItemIndices)
            if (~isempty(allItems))
                pathIndex=find(matchedItemIndices,1,'first');
                if(~isempty(pathIndex))
                    firstResult = allItems{pathIndex};
                else
                    firstResult = '';
                end
            else
                firstResult = '';
            end
        end
        
        
        function [fileMatch] = searchForFileByNameAndExt(folderLocation, fileName, caseSensitiveOnName)
            [~, ~, ext] = fileparts(fileName);
            %possible to be case sensitive on the name (but not the
            %extension-- doc center ppl said to use lowercase for xml)
            %dir() returns the actual cases of the names if you do not
            %specify the name in the regex--it will return whatever you
            %specify for ext though--which is always lowercase in this
            %class
            comparisonFunction=@strcmp;
            if(~caseSensitiveOnName)
                comparisonFunction=@strcmpi;
            end
            contentsOfFolderByExt = dir(fullfile(folderLocation,strcat('*',ext)));
            matchesbyName = cellfun(@(x) comparisonFunction(x,fileName),{contentsOfFolderByExt(:).name},'UniformOutput',false);
            fileMatch = matlab.addons.toolbox.internal.FileSystemUtils.selectFirstMatch({contentsOfFolderByExt(:).name}, [matchesbyName{:}]);
            if(~isempty(fileMatch))
                fileMatch = fullfile(folderLocation, fileMatch);
            else
                fileMatch = '';
            end
        end
        
    end
    
end

