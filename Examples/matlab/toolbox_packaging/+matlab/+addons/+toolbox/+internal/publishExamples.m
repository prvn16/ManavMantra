function [statuses, ids, messages] = publishExamples(files)
files = string(files);
statuses = false(size(files));
ids = cell(size(files));
messages = cell(size(files));
for idx = 1:length(files)
    if isMFile(files{idx})
       [statuses(idx), ids{idx}, messages{idx}] = publishMFile(files{idx});
    elseif isMlxFile(files{idx})
        [statuses(idx), ids{idx}, messages{idx}] = publishMlxFile(files{idx});
    else
        statuses(idx) = false;
        ids{idx} = 'MATLAB:toolbox_packaging:publishing:InvalidExample';
        messages{idx} = getString(message(ids{idx}, files{idx}));
        dispError(files{idx}, MException(ids{idx}, messages{idx}));
    end
end
end

function [status, id, message] = publishMFile(file)
try
    currentDirectory = pwd;
    filePath = fileparts(file);
    onCleanupObj = onCleanup(@()cd(currentDirectory));
    if isPrivate(filePath)
        cd(filePath)
    else
        cd(getValidPathEntryParent(filePath));
    end
    publish(getQualifiedFunctionOrMethodName(file));
    status = true;
    id = '';
    message = '';
catch ME
    dispError(file, ME);
    status = false;
    id = ME.identifier;
    message = ME.message;
end
end

function [status, id, message] = publishMlxFile(file)
try
    htmlFile = createHtmlFilenameFor(file);
    makeHtmlFilePath(htmlFile);
    %matlab.internal.liveeditor.executeAndSave(file);
    matlab.internal.liveeditor.openAndConvert(file, htmlFile);
    status = true;
    id = '';
    message = '';
catch ME
    dispError(file, ME);
    status = false;
    id = ME.identifier;
    message = ME.message;
end
end

function isfile = isMFile(file)
[~, ~, extension] = fileparts(file);
isfile = strcmpi(extension, '.m');
end

function isfile = isMlxFile(file)
[~, ~, extension] = fileparts(file);
isfile = strcmpi(extension, '.mlx');
end

function htmlFile = createHtmlFilenameFor(file)
htmlFile = char(com.mathworks.toolbox_packaging.utils.ToolboxPathUtils.exampleFileLocationFor(file));
end

function makeHtmlFilePath(htmlFile)
path = fileparts(htmlFile);
[status, msg, msgID] = mkdir(path);
if ~status
    throw(MException(msgID, msg));
end
end

function fileParent = getValidPathEntryParent(file)
    fileParent = char(com.mathworks.fileutils.MatlabPath.getValidPathEntryParent(java.io.File(file)));
end

function entryName = getQualifiedFunctionOrMethodName(file)
    entryName = char(com.mathworks.fileutils.MatlabPath.getQualifiedFunctionOrMethodName(java.io.File(file)));
end

function private = isPrivate(file)
    private = com.mathworks.fileutils.MatlabPath.isPrivate(java.io.File(file));
end

function dispError(file, ME)
disp(getString(message('MATLAB:toolbox_packaging:publishing:ErrorWhilePublishing', file)));
disp(getReport(ME, 'basic'));
end

