function outputNames = createArchive(archiveFileName, files, rootDir, ...
                       createArchiveEntryFcn, archiveOutputStream, fcnName)
%CREATEARCHIVE Create an archive of files
%
%   createArchive creates an archive archiveFileName from the files specified by
%   files and rootDir. outputNames is a string cell array of relative path
%   filenames stored in the archive. For all operating systems, the
%   directory delimiter is '/'.
%
%   archiveFileName is a string containing the name of the archive.
%
%   files is a string cell array of the filenames to add to the archive.
%
%   rootDir is a string containing the name of the root directory of FILES.
%
%   createArchiveEntryFcn is a function handle to create an archive entry
%
%   archiveOutputStream is a Java stream object attached to the archive 
%   output file.
%
%   fcnName is the string name of the calling function and used in
%   constructing error messages.

% Copyright 2004-2012 The MathWorks, Inc.

% Create a structure of the inputs.
entries = getArchiveEntries(files, rootDir, fcnName, true);

% Check for duplicates
checkDuplicateEntries(entries, fcnName)

entries = FilterOutArchiveFile(entries, archiveFileName, fcnName);

% Create a stream copier to copy files
streamCopier = ...
   com.mathworks.mlwidgets.io.InterruptibleStreamCopier.getInterruptibleStreamCopier;

% Add each entry to the archive.
for i = 1:length(entries)
   % Create the entry objects.
   addArchiveEntry(archiveFileName, createArchiveEntryFcn, entries(i), ...
                   archiveOutputStream, streamCopier, fcnName);
end

% Close stream.
archiveOutputStream.close;

% Return outputNames
outputNames = {entries(:).entry};


function entries = FilterOutArchiveFile(entries, archiveFileName,archiveFcn)
%Get full path
fileAttrib = getFileAttrib(archiveFileName);
archiveFileName = fileAttrib.Name;
archiveFile = java.io.File(archiveFileName);

for i = length(entries):-1:1
    fileAttrib = getFileAttrib(entries(i).file);
    fileName = fileAttrib.Name;
    file = java.io.File(fileName);
    if compareTo(archiveFile, file) == 0
    % do not add the archiveFilename to the entries structure
        wid = sprintf('MATLAB:%s:archiveName', archiveFcn);
        warning(wid,'%s', ...
            getString(message('MATLAB:createArchive:archiveName',upper(archiveFcn),archiveFileName)));
        entries(i) = [];
    end
end
  
%--------------------------------------------------------------------------
function checkDuplicateEntries(entries, fcnName)
% Check for duplicate entry names.
allNames = {entries.entry};
[uniqueNames,i] = unique(allNames);
if length(uniqueNames) < length(entries)
   firstDup = allNames{min(setdiff(1:length(entries),i))};
   eid = sprintf('MATLAB:%s:duplicateEntry',fcnName);
   error(eid, '%s', ...
       getString(message('MATLAB:createArchive:duplicateEntry',upper(fcnName),firstDup)));
end

%--------------------------------------------------------------------------
function addArchiveEntry(archiveFileName, createArchiveEntryFcn, entry, ...
                         fileOutputStream, streamCopier, archiveFcn)

% Get the file attribute and the Unix file mode.
[fileAttrib, unixFileMode] = getFileAttrib(entry.file);

if fileAttrib.directory
    entry.entry(end+1) = '/';
end

% Create the archive entry
archiveEntry = createArchiveEntryFcn(entry, fileAttrib, unixFileMode);

if fileAttrib.directory
    fileOutputStream.putNextEntry(archiveEntry);
else
    % Create a Java file input stream from the archive entry
    try
       file = java.io.File(entry.file);
       fileInputStream = java.io.FileInputStream(file);
    catch %#ok<CTCH> Not concerned with why we can't open the file
       eid = sprintf('MATLAB:%s:openEntryError',archiveFcn);
       warning(eid,'%s', ...
           getString(message('MATLAB:createArchive:openEntryError',entry.file)));
       return;
    end

    % Put and copy the entry into the archive
    try
       fileOutputStream.putNextEntry(archiveEntry);
       streamCopier.copyStream(fileInputStream,fileOutputStream);
    catch %#ok<CTCH> Not concerned with why we can't write to stream
       eid=sprintf('MATLAB:%s:copyStreamError', archiveFcn);
       error(eid,'%s', ...
           getString(message('MATLAB:createArchive:copyStreamError', ...
                 entry.entry, archiveFcn, archiveFileName)));
    end

    % Close everything up.
    fileInputStream.close;
end

fileOutputStream.closeEntry;

%--------------------------------------------------------------------------
function [attrib, mode] = getFileAttrib(filename)
% Get the file attributes and the Unix file mode
%
% The input FILENAME is a string.
% The output attrib is a struct.
% The output MODE is string which can be converted to a number if it is used.

% Obtain the file attributes (modes)
[status, attrib, id] = fileattrib(filename);
if ~status
   error(id,'%s',getString(message('MATLAB:createArchive:noFileAttrib',filename)));
end

if nargout == 1
    return;
end

% Convert each mode to a string.
userMode  = convertMode(attrib.UserRead,  attrib.UserWrite,  attrib.UserExecute);

if isunix
  groupMode = convertMode(attrib.GroupRead, attrib.GroupWrite, attrib.GroupExecute);
  otherMode = convertMode(attrib.OtherRead, attrib.OtherWrite, attrib.OtherExecute);
else
  % The Group and Other mode is not defined for Windows.
  % Set mode to read-execute in case the file is extracted on Unix
  % and for consistency with Windows extraction.
  groupMode = '5';
  otherMode = '5';
end

% Concatenate the UID and modes together.
mode  = ['100' userMode groupMode otherMode];


%--------------------------------------------------------------------------
function mode = convertMode(readMode, writeMode, executeMode)
% Convert the read, write, execute mode to a string (0-7).
%
% The inputs, READMODE, WRITEMODE, EXECUTEMODE, are integers (1 or 0)
% denoting if the particular mode is set. The output, MODE, is a
% string denoting the mode's octal attribute represented by
% the value '0' - '7'.

octalReadMode    = 4;
octalWriteMode   = 2;
octalExecuteMode = 1;
mode = octalReadMode*readMode + ...
       octalWriteMode*writeMode + ...
       octalExecuteMode*executeMode;
mode = num2str(mode);

