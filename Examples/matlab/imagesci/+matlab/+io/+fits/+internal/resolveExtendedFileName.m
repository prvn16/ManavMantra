function [fullExtFileName, fullFileName, hasExtSyntax] = resolveExtendedFileName(origFileName)
%resolveExtendedFileName Determine the full path to the file if the file
%name is specified using the extended syntax.
%   [FULLEXTFILENAME, FULLFILENAME, HASEXTSYNTAX] = resolveExtendedFileName(ORIGFILENAME)
%   resolves the full path to the file when the file name is specified
%   using the extended syntax and FULLEXTFILENAME contains the fully
%   resolved name. FULLFILENAME contains the fully resolved name without
%   the extended syntax and HASEXTSYNTAX returns TRUE if ORIGFILENAME
%   contains an extended syntax.

%   Copyright 2017 The MathWorks, Inc.

hasExtSyntax = false;

[origFilePath, origFileName, origFileExt] = fileparts(origFileName);
truncFileExt1 = extractBefore(origFileExt, '+');
truncFileExt2 = extractBefore(origFileExt, '[');

if isempty(origFileExt) || (isempty(truncFileExt1) && isempty(truncFileExt2))
    truncatedFileName = origFileName;
else
    % If code reached here, it means that the extension has either a + or [
    % or both. If it has both, this is not supported.
    if ~isempty(truncFileExt1) && ~isempty(truncFileExt2)
        error(message('MATLAB:imagesci:fits:fileOpenError')); 
    end

    hasExtSyntax = true;
    if isempty(truncFileExt1)
        truncFileExt = truncFileExt2;
    else
        truncFileExt = truncFileExt1;
    end
    truncatedFileName = fullfile(origFilePath, [origFileName, truncFileExt]);
end

fid = fopen(truncatedFileName, 'r');
if fid == -1
    error(message('MATLAB:imagesci:fits:fileOpenError')); 
end
fullFileName = fopen(fid);
fclose(fid);

[fullFilePath, fileName] = fileparts(fullFileName);
fullExtFileName = fullfile(fullFilePath, [fileName, origFileExt]);
