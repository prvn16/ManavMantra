function entries = getArchiveEntries(files, rootDir, fcnName, includeEmptyDirs)
%GETARCHIVEENTRIES Get entries for an archive
%
%   GETARCHIVEENTRIES gets the entries for an archive.  
%   FILES is a cell array of filenames to add to the
%   archive.  ROOTDIR is the root directory to search for the filenames
%   specified by FILES.  FCNNAME is the name of the calling function.
%
%   The return argument, ENTRIES, is a structure containing fields FILE
%   and ENTRY. FILE is the full filename of ENTRY.

% Copyright 2004-2011 The MathWorks, Inc.

% Only process unique files.
[~, i] = unique(files);
files = files(sort(i));

if nargin < 4
    includeEmptyDirs = false;
end

% Create the inputs structure.
if ~isempty(files)
    inputs = struct('path','','file','');
    inputs(numel(files)) = inputs(1);
else
    % If there are no inputs, then error.
    % There is no such thing as an "empty archive".
    eid=sprintf('MATLAB:%s:noEntries', fcnName);
    error(eid,'%s',getString(message('MATLAB:getArchiveEntries:noEntries',fcnName)));
end

% Create a structure of the inputs, parsing the file's directory and name.
for i = 1:length(files)
   filename = files{i};

   if isAbsolute(filename)
      % The file is absolute, i.e. /filename or C:\filename
      [pathstr, base, ext] = fileparts(filename);
      inputs(i).path = pathstr;    
      inputs(i).file = [base ext]; 

   else
      % The file does not have a directory name, use rootDir for path name.
      inputs(i).path = rootDir; 
      inputs(i).file = filename; 
   end
end

% rootDirIsPWD is true if the root directory is pwd, but input as '.' or ''
rootDirIsPWD = (isempty(rootDir) || isequal(rootDir,'.'));

% cwd is the current directory with all forward / for platform consistency.
cwd = convertSlash(pwd);

% fileList is a list a files used when checking if a new file should be
% added to the entry structure.
fileList = {};

% Build up list of return entries.
entries = [];

% Process each of the inputs
while ~isempty(inputs)
    
   % Pop the next input off the stack.
   pathstr = inputs(1).path;
   file    = inputs(1).file;
   inputs(1) = [];

   % Create a full filename of the input.
   fullFileName = fullfile(pathstr,file);

   % Check if the fullFileName is a directory and
   % obtain its contents.
   [fileIsDir, dirContents] = isDirectory(fullFileName, includeEmptyDirs);

   % Check if the input is specified with a '*'
   hasStar = ~isempty(find(file == '*',1));
   if hasStar
      % The input has a '*' in the name, add the directory listing.
      file = fileparts(file);
      inputs = addDirectory(inputs, dirContents, pathstr, file);

   elseif fileIsDir
      % The input is a directory, add the directory listing.
      inputs = addDirectory(inputs, dirContents, pathstr, file);

   elseif ~isFile(fullFileName, dirContents)
      eid=sprintf('MATLAB:%s:fileDoesNotExist',fcnName);
      error(eid,'%s',getString(message('MATLAB:getArchiveEntries:fileDoesNotExist',fullFileName)));

   else

      % Processing a file.
      if isempty(pathstr) 
         
         % Check for ~ or ~username in the base filename.        
         hasTilde = isunix && ~isempty(find(file(1) == '~',1));
         
         % Get the absolute filename if the file is on the MATLAB path.
         fullFileName = getAbsoluteFileName( ...
             fullFileName, dirContents, hasTilde, fcnName);

         if hasTilde
             % Reset pathstr to a full path and remove ~ or ~username from
             % file.
            [pathstr, base, ext] = fileparts(fullFileName);
            file = [base ext];
         end         
      end
      
      % Convert pathstr to full directory and common slash format.
      if isempty(pathstr)
        pathstr = cwd;
      else
        pathstr = convertSlash(pathstr);
      end

      % Check if the fullFileName is actually the name of the archive file.
      % If so, do not add it to the entries structure.
      file = convertSlash(file);
      fullFileName = convertSlash(fullFileName);
      

      % Only add unique filenames to the entries structure. If the
      % fullfileName is already a member of entries.file, then do not
      % add it to the structure. 
      %
      % Add the entry if:
      %   1) it is the first entry,
      %   2) the filename is unique.
      %
      % The filename is unique if it is:
      %   1) specified as an absolute file and not previously added,
      %   2) the rootDir has not been specified or is '.' (the pwd
      %      directory), and the file is specified relative and 
      %      not previously added.
      %
      % Check if the file has been added by creating a cell array of
      % full filenames of each entry. A new file candidate is compared
      % against this list. If a match is found, the candidate file is
      % not added.

      if  rootDirIsPWD && ~isAbsolute(fullFileName)
          pwdFullFileName = [pathstr '/' fullFileName];
          fileCandidate = pwdFullFileName;
      else
          fileCandidate = fullFileName;
      end

      if isempty(entries)
          addEntry = true;
      else
          addEntry = ~any(strcmp(fileCandidate, fileList));
      end

      if addEntry
          % Add the fullFileName and the base and extension name to
          % the entries structure.
          fileList{end+1} = fileCandidate;    %#ok<AGROW>
          entries(end+1).file = fullFileName; %#ok<AGROW>
          entries(end).entry = file;
      end
   end
end

% If there is nothing to do, error.
% There is no such thing as an "empty archive".
if isempty(entries)
   eid=sprintf('MATLAB:%s:noEntries', fcnName);
   error(eid,'%s',getString(message('MATLAB:getArchiveEntries:noEntries',fcnName)))
end

%--------------------------------------------------------------------------
function inputs = addDirectory(inputs, dirContents, pathstr, file)
% Add a directory listing to inputs.

% Push all matches onto the stack.
for i = 1:length(dirContents)
   inputs(end+1).path = pathstr; %#ok<AGROW>
   inputs(end).file   = fullfile(file, dirContents{i});
end

%--------------------------------------------------------------------------
function varIsFile = isFile(filename, dirContents)
% Check if filename exists and is a file.

% For speed, use the results of the DIR command, 
% for files in the current directory, or specified with a directory name.
if numel(dirContents) == 1
   varIsFile = true;
else
   % The DIR command will not be sufficient for files on the MATLAB path,
   % and specified without a directory.
   % Since the file may be on the MATLAB path, fall back to using exist.
   varIsFile = any(exist(filename, 'file') == [2, 3, 4, 6]);
end

%--------------------------------------------------------------------------
function [fileIsDir, dirContents] = isDirectory(filename, includeEmptyDirs)
% Check if filename exists and is a directory.

dirContents = dir(filename);
dirContents = {dirContents.name};
fileIsDir = numel(dirContents) > 1;
if fileIsDir
    dirContents = setdiff(dirContents,{'.','..'});
    if includeEmptyDirs && isempty(dirContents)
        % make an empty directory look like a file
        fileIsDir = false;
        dirContents = {filename};
    end
end

%--------------------------------------------------------------------------
function absoluteFileName = getAbsoluteFileName(filename, dirContents, ...
   hasTilde, fcnName)
% Return the absolute filename if it's not in the current directory,
% otherwise return filename.

if numel(dirContents) == 1 && ~hasTilde
   % File is found in pwd
   absoluteFileName = filename;
   
else
   [fid, errmsg] = fopen(filename);
   if fid ~= -1
      absoluteFileName = fopen(fid);
      fclose(fid);
   else
      eid = sprintf('MATLAB:%s:fopenError',fcnName);
      error(eid,'%s',getString(message('MATLAB:getArchiveEntries:fopenError',filename,errmsg)));
   end
end

%--------------------------------------------------------------------------
function name = convertSlash(name)
name = strrep(name, '\', '/');
if strncmp(name,'./',2)
   % Remove first occurrence of './'
   name = name(3:end);
end
