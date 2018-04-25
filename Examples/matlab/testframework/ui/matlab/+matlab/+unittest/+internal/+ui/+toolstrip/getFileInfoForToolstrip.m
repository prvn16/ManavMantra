function [isTestFile, isValidFile] = getFileInfoForToolstrip(file)
% This function is undocumented and may change in a future release.

% Note: For performance reasons, this file assumes the file input is a full
% path file name (coming from the editor).

% Copyright 2017 The MathWorks, Inc.
import matlab.unittest.internal.ui.toolstrip.getClassFileInfoForToolstrip;
import matlab.unittest.internal.ui.toolstrip.getFunctionFileInfoForToolstrip;

isTestFile = false;
isValidFile = false;

try
    if ~isfile(file)
        return; % Protect against "Untitled" and when file no longer exists
    end

    [~,~,ext] = fileparts(file);
    if ~strcmpi(ext,'.m') % We currently only support .m files
        return;
    end

    parseTree = mtree(file,'-file');

    if ~parseTree.isempty && parseTree.root.iskind('ERR')
        return;
    end
    isValidFile = true;

    fileType = parseTree.FileType;
    if fileType == mtree.Type.ClassDefinitionFile
        isTestFile = getClassFileInfoForToolstrip(file,parseTree);
    elseif fileType == mtree.Type.FunctionFile
        isTestFile = getFunctionFileInfoForToolstrip(file,parseTree);
    else
        % do nothing with script based tests
    end
catch
    % mtree can error above or indirectly via getClassFileInfoForToolstrip
    % if a file no longer exists mid-execution. Even though there is an
    % isfile check above, a file can be renamed on a different thread even
    % after this check. For sanity sake, it is best to wrap the entire
    % algorithm in a try/catch.
end
end