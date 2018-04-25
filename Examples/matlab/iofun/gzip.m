function varargout = gzip(files, varargin)
%GZIP Compress files into GNU zip files.
%
%   GZIP(FILES) creates GNU zip files from the list of files specified in FILES.
%
%   FILES is a character vector or cell array of character vectors containing a list
%   of files or directories.  Files specified in FILES can be a MATLABPATH relative
%   partial filename.  Directories specified in FILES must be either relative to the
%   current directory or absolute.  On UNIX systems, directories may also start with
%   a "~/" or a "~username/", which expands to the current user's home directory or
%   the specified user's home directory, respectively. FILES may contain the wildcard
%   character '*' but must be either relative to the current directory or specified
%   with an absolute directory.  Directories recursively gzip all of their content.
%   The output gzipped files are written to the same directory as the input files and
%   with the file extension '.gz'.
%
%   GZIP(FILES, OUTPUTDIR) writes the gzipped file into the directory OUTPUTDIR.
%   OUTPUTDIR is created if it does not exist.
%
%   FILENAMES = GZIP(...) gzips the files and returns the relative path names of the
%   gzipped files into the cell array, FILENAMES.
%
%   Example
%   -------
%   % gzip all *.m and *.mat files in the current directory and store the
%   % results into the directory 'archive'.
%   gzip({'*.m','*.mat'},'archive');
%
%   See also GUNZIP, TAR, UNTAR, UNZIP, ZIP.

% Copyright 2004-2016 The MathWorks, Inc.

narginchk(1,2);
nargoutchk(0,1);

[files,varargin{1:nargin-1}] = matlab.io.internal.utility.convertStringsToChars(files,varargin{:});

% rootDir is always ''
dirs = [{''},varargin];

% Check input arguments.

[files, rootDir, outputDir,dirCreated] = checkFilesDirInputs(mfilename, files, dirs{:});
try
% Get entries
entries = getArchiveEntries(files, rootDir, mfilename);

% Gzip the files
names = gzipwrite(entries, outputDir);

% Return the names if requested 
if nargout == 1
   varargout{1} = names;
end
catch exception
    if ~isempty(dirCreated)
        rmdir(dirCreated, 's');
    end
    rethrow(exception);
end

    
%----------------------------------------------------------------------
function gzipFilenames = gzipwrite(entries, outputDir)

% This InterruptibleStreamCopier is unsupported and may change without notice.
streamCopier = ...
   com.mathworks.mlwidgets.io.InterruptibleStreamCopier.getInterruptibleStreamCopier;

% Setup a cell for the names of the output gzipped files.
gzipFilenames = cell(1,numel(entries));
gzipExt = '.gz';
getOutputDirFromFile = isempty(outputDir);
% Process entries.
for k=1:numel(entries)
   
  % Create a name for the output gzipped file.
  filename = entries(k).file;
  [path, baseName, ext] = fileparts(filename);
  if getOutputDirFromFile
     outputDir = path;
  end
  gzipFilename = fullfile(outputDir,[ baseName ext gzipExt]);

  % Create Java input streams.
  fileInStream = [];
  try
     javaInFile   = java.io.File(filename);
     fileInStream = java.io.FileInputStream(javaInFile);
  catch exception
     % Unable to access the file.
     if ~isempty(fileInStream)
       fileInStream.close;
     end
     error(message('MATLAB:gzip:javaOpenError', filename));
  end

  % Create output streams and gzip the file.
  gzipOutStream = [];
  try
     fileOutStream = java.io.FileOutputStream(java.io.File(gzipFilename));
     gzipOutStream = java.util.zip.GZIPOutputStream( fileOutStream );
     streamCopier.copyStream(fileInStream,gzipOutStream);
  catch exception
     if ~isempty(fileInStream)
       fileInStream.close;
     end
     if ~isempty(gzipOutStream)
        gzipOutStream.close;
     end
     error(message('MATLAB:gzip:javaOutputOpenError', gzipFilename));
  end
    
  % Cleanup and close the streams.
  fileInStream.close;
  gzipOutStream.close;
 
  gzipFilenames{k} = gzipFilename;
 
 end
