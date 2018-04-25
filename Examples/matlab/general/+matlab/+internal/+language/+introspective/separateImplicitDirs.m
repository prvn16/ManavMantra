% Break off all implicit dirs from a directory
function [parentDir, implicitDirs] = separateImplicitDirs(sourceDir)
    % To implement a new implicit directory pattern, add it to this list.
    implicitDirList = {'private', '[+@][^\\/]++'};

    % Build the Regular Expression
    assertBeginOfDirName = '(?<=[\\/]|^)';
    implicitDirList = [implicitDirList{1}, sprintf('|%s', implicitDirList{2:end})];
    matchEndOfDirName = '([\\/]|$)';
    implicitDirPattern = [assertBeginOfDirName '((', implicitDirList, ')' matchEndOfDirName ')*+$'];
    
    [implicitDirs, split] = regexp(sourceDir, implicitDirPattern, 'match', 'split', 'once');
    parentDir = split{1};
end

