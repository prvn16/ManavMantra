function [m,f] = genmanifest(src, target)
% GENMANFIEST Generate a matlab.depfun.internal.Manifest object and return 
% files.
%
%   [manifest, files] = genmanifest('blackjack.m', 'PCTWorker
% 
    src = resolveFileTypeAmbiguity(src);
    m = matlab.depfun.internal.Manifest(src, target);
    f = files(m);
end

% 'file' and 'file.m' may exist in the same directory. In that case, 
% genmanifest('file', ...) is ambiguous. If 'file' is present in the file
% list, and 'file.m' exists in the same directory, AND 'file.m' is NOT on the
% file list, replace 'file' with 'file.m' on the file list.
function files = resolveFileTypeAmbiguity(files)
    import matlab.depfun.internal.requirementsConstants
    % Convert single char array to cell array containing a char array.
    if ischar(files)
        files = { files };
    end

    % Resolve ambiguity of file names without extensions
    for k=1:numel(files)
        [path,name,ext] = fileparts(files{k});
        if isempty(ext)
            fileNames = cellfun(@(x) fullfile(path,strcat(name,x)),...
                             requirementsConstants.executableMatlabFileExt,'UniformOutput',0);
            fileNamesExistIdx = cellfun(@(f)matlabFileExists(f),fileNames,'UniformOutput',0);
            fileName = cell2mat(fileNames(find(cell2mat(fileNamesExistIdx),1)));
            if(~isempty(fileName))
                files{k}=fileName; 
            end
        end
    end
end
