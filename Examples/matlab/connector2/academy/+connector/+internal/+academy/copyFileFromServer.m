function copyFileFromServer(url,destFile)

wo = weboptions('ContentReader',@(x) copyFileWithCreateFolder(x,destFile));
try
    [status, msg] = webread(url,wo);
catch MExc
    status = 0;
    msg = MExc.message;
end

if status
    disp('Success');
else
    disp(['Fail: ' msg]);
end

end


function [status, msg] = copyFileWithCreateFolder(sourceFile,destFile)
    destFolder = fileparts(destFile);
    if (~isempty(destFolder)) && (~exist(destFolder,'dir'))
        mkdir(destFolder);
    end
    [status, msg] = copyfile(sourceFile,destFile,'f');
end