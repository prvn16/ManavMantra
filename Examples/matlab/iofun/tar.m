function varargout = tar(tarFilename,files,varargin)
%TAR Compress files into tar file.
%
%   TAR(TARFILENAME,FILES) creates a tar file with the name TARFILENAME from the list
%   of files and directories specified in FILES. Relative paths are stored in the tar
%   file, but absolute paths are not. Directories recursively include all of their
%   content.
%   
%   TARFILENAME is the name of the tar file. The '.tar' extension is appended to
%   TARFILENAME if omitted. TARFILENAME's extension may end in '.tgz' or '.gz'. In
%   this case, TARFILENAME is gzipped.
%
%   FILES is a character vector or cell array of character vectors specifing the
%   files or directories to be included in TARFILENAME.  Individual files that are on
%   the MATLABPATH can be specified as partial pathnames. Otherwise an individual
%   file can be specified relative to the current directory or with an absolute path.
%   Directories must be specified relative to the current directory or with absolute
%   paths.  On UNIX systems, directories may also start with a "~/" or a
%   "~username/", which expands to the current user's home directory or the specified
%   user's home directory, respectively.  The wildcard character '*' may be used when
%   specifying files or directories, except when relying on the MATLABPATH to resolve
%   a filename or partial pathname.
%
%   TAR(TARFILENAME,FILES,ROOTDIR) allows the path for FILES to be specified relative
%   to ROOTDIR rather than the current directory.
%
%   ENTRYNAMES = TAR(...) returns a cell array of the relative path entry names
%   contained in TARFILENAME.
%
%   Example ------- % Tar all files in the current directory to the file backup.tgz
%   tar('backup.tgz','.');
% 
%   See also GZIP, GUNZIP, UNTAR, UNZIP, ZIP.

% Copyright 2004-2016 The MathWorks, Inc.

% Check number of arguments
narginchk(2,3);
nargoutchk(0,1);

[tarFilename,files,varargin{1:nargin-2}] = matlab.io.internal.utility.convertStringsToChars(tarFilename,files,varargin{:});

% Parse arguments
[files, rootDir, tarFilename, compressFcn] =  ...
   parseArchiveInputs(mfilename, tarFilename, files, varargin{:});

% Open output stream.
try
   tarFile = java.io.File(tarFilename);
   fileOutputStream = java.io.FileOutputStream(tarFile);
   if isempty(compressFcn)
     tarOutputStream = com.mathworks.mlwidgets.io.MwTarOutputStream(fileOutputStream);
   else
     gzOutputStream = java.util.zip.GZIPOutputStream(fileOutputStream);
     tarOutputStream = com.mathworks.mlwidgets.io.MwTarOutputStream(gzOutputStream);
   end
catch exception
   error(message('MATLAB:tar:openError', tarFilename));
end

% Create the archive
try
   files = createArchive(tarFilename, files, rootDir, ...
      @createArchiveEntry, tarOutputStream, mfilename);
catch exception
   fileOutputStream.close;
   tarFile.delete;
   throw(exception);
end

% Close stream.
fileOutputStream.close;

if nargout == 1
   varargout{1} = files;
end

%--------------------------------------------------------------------------
function tarEntry = createArchiveEntry(entry, fileAttrib, unixFileMode) %#ok<INUSL>
% Create the TAR archive entry. 
%
% Inputs:
%   ENTRY is a structure with fieldnames entry and file. 
%   FILEATTRIB is a struct representing the file's attributes, 
%   which TAR ignores. 
%   There is no representation in the TarEntry class for PC attributes.
%   UNIXFILEMODE is a double (octal) representation of the file's mode.
%
% Outputs:
%   TARENTRY is a Java TarArchiveEntry object.

% Create a Tar entry
file = java.io.File(entry.file);
tarEntry = org.apache.commons.compress.archivers.tar.TarArchiveEntry(...
                                                        file, entry.entry);

% Set the Unix file mode.
% Convert the mode to octal.
unixFileMode = base2dec(unixFileMode, 8);
tarEntry.setMode(unixFileMode);

% Set timestamp.
lastModified = file.lastModified;
tarEntry.setModTime(lastModified)
