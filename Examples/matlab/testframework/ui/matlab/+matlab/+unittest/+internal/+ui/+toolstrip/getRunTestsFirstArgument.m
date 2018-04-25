function firstArg = getRunTestsFirstArgument(fullFileName)
% This function is undocumented and may change in a future release.

% Copyright 2017 The MathWorks, Inc.
import matlab.unittest.internal.getParentNameFromFilename;
import matlab.unittest.internal.whichFile;

parentName = getParentNameFromFilename(fullFileName);

if strcmp(whichFile(parentName),fullFileName)
    firstArg = parentName;
else
    pattern = ['^' regexptranslate('escape',pwdWithFilesep)];
    firstArg = regexprep(fullFileName,pattern,'');
end
end

function str = pwdWithFilesep()
str = pwd;
% When at drive root, like "C:\", then pwd already contains filesep so we
% conditionally add filesep only if needed
if ~endsWith(str,filesep)
    str = [str,filesep];
end
end