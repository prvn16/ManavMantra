function filename = unmapFile(filename)
% unmapFile Reverses any mapping that MATLAB Editor might have applied
%
% This function maps a filename that resides on the MW_DEBUG_SYMBOL_PATH
% back to the corresponding filename in the current sandbox.  It is a
% pass through no-op if the environemnt variable MW_DEBUG_SYMBOL_PATH is
% not set or if the filename is not located in one of these alternate code
% trees.

symbolPath = getenv('MW_DEBUG_SYMBOL_PATH');

if ispc
    symbolPath = strrep(symbolPath, '/', filesep);
end

if (~isempty(symbolPath))
    for newPath = regexp(symbolPath, pathsep, 'split');
        newPath = strrep(newPath{1},'//','/');     % Only needed on UNIX
        if (strncmp(filename, newPath, length(newPath)))
            filename = strcat(matlabroot, filename(length(newPath)+1:end));
            break;
        end
    end
end

