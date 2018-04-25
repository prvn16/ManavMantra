function varargout = unzip(zipFilename,varargin)
%UNZIP Extract contents of zip file.
%
%   UNZIP(ZIPFILENAME) extracts the archived contents of ZIPFILENAME into the current
%   folder, preserving the files' attributes and timestamps. ZIPFILENAME is the name
%   of the zip file. If ZIPFILENAME does not include the full path, UNZIP searches
%   for the file in the current folder and along the MATLAB path. If you do not
%   specify the file extension, UNZIP appends .zip.
%
%   If any files in the target folder have the same name as files in the zip file,
%   and you have write permission to the files, UNZIP overwrites the existing files
%   with the archived versions. If you do not have write permission, UNZIP issues a
%   warning.
%
%   UNZIP(ZIPFILENAME, OUTPUTDIR) extracts the contents of ZIPFILENAME into the
%   folder OUTPUTDIR.
%
%   UNZIP(URL, ...) extracts the zip contents from an Internet URL. The URL must
%   include the protocol type (e.g., "http://"). The UNZIP function downloads the URL
%   to the temporary folder on your system, and deletes the URL on cleanup.
%
%   FILENAMES = UNZIP(...) returns the names of the extracted files in the cell array
%   FILENAMES. If OUTPUTDIR specifies a relative path, FILENAMES contains the
%   relative path. If OUTPUTDIR specifies an absolute path, FILENAMES contains the
%   absolute path.
%
%   Unsupported zip files
%   ---------------------
%   UNZIP does not support password-protected or encrypted zip archives.
%
%   Examples
%   --------
%   % Copy the demo MAT-files to the folder 'archive'.
%   % Zip the demo MAT-files to demos.zip
%   rootDir = fullfile(matlabroot, 'toolbox', 'matlab', 'demos');
%   zip('demos.zip', '*.mat', rootDir)
%
%   % Unzip demos.zip to the folder 'archive'
%   unzip('demos.zip', 'archive')
%
%   % Download Cleve Moler's "Numerical Computing with MATLAB" examples
%   % to the output folder 'ncm'.
%   url ='http://www.mathworks.com/moler/ncm.zip';
%   ncmFiles = unzip(url, 'ncm')
%
%   See also FILEATTRIB, GZIP, GUNZIP, TAR, UNTAR, ZIP.

%   Copyright 1984-2016 The MathWorks, Inc.

narginchk(1,2);
nargoutchk(0,1);

[zipFilename,varargin{1:nargin-1}] = matlab.io.internal.utility.convertStringsToChars(zipFilename,varargin{:});

cleanUpUrl = [];
% Argument parsing.
[zipFilename, outputDir, url, urlFilename] = parseUnArchiveInputs( ...
   mfilename, zipFilename, {'zip'}, 'ZIPFILENAME', varargin{:});
    
if url && ~isempty(urlFilename) && exist(urlFilename,'file')
    cleanUpUrl = urlFilename;
end

zipFile = [];
entries = [];

% Create a Java ZipFile object and obtain the entries.
try

   % Create a Java file of the ZIP filename.
   zipJavaFile  = java.io.File(zipFilename);

   % Create a Java ZipFile and validate it.
   zipFile = org.apache.tools.zip.ZipFile(zipJavaFile);

   % Extract the entries from the ZipFile.
   entries = zipFile.getEntries;

catch exception
   if ~isempty(zipFile)
       zipFile.close;
   end    
   delete(cleanUpUrl);
   error(message('MATLAB:unzip:invalidZipFile', zipFilename));
end

cleanUpObject = onCleanup(@()cellfun(@(x)x(), {@()zipFile.close,@()delete(cleanUpUrl)}));

% Setup the ZIP API to process the entries.
api.getNextEntry    = @getNextEntry;
api.getEntryName    = @getEntryName;
api.getInputStream  = @getInputStream;
api.getFileMode     = @getFileMode;
api.getModifiedTime = @getModifiedTime;

% Extract ZIP contents.
try
    files = extractArchive(outputDir, api, mfilename);
catch extractArchiveException
    throwAsCaller(extractArchiveException);
end

if nargout == 1
   varargout{1} = files;
end

%--------------------------------------------------------------------------
   function entry = getNextEntry
      try
         if entries.hasMoreElements
            entry = entries.nextElement;
         else
            entry = [];
         end
      catch exception
         error(message('MATLAB:unzip:invalidZipFileEntry', zipFilename));
      end
   end

%--------------------------------------------------------------------------
   function entryName = getEntryName(entry)
      entryName = char(entry.getName);
      % if the zip file was created as a MS-DOS FAT file replace any
      % backslashes, since they can't be part of a valid filename
      if entry.getPlatform == 0
          entryName = strrep( entryName, '\', filesep );
      end
   end

%--------------------------------------------------------------------------
   function inputStream = getInputStream(entry)
      % ZipFile throws a ZipException when there is an invalid compression
      % method.  This happens with password protected zip files for
      % example.  Return an empty stream and throw an error further on 
      % downstream in extractArchives copySteam method.
      try
          inputStream  = zipFile.getInputStream(entry);
      catch exception %#ok<SETNU>
          inputStream = [];
      end
          
   end

%--------------------------------------------------------------------------
   function fileMode = getFileMode(entry)
      if ispc
         % Return the external attribute for Windows.
         % The external attribute is the Unix file mode shifted
         % left by 16 bits with the system, hidden, and archive
         % attributes in the lower 2-bytes.
         fileMode = entry.getExternalAttributes;
      else
         % Return the Unix file mode
         fileMode = entry.getUnixMode;
      end
   end

%--------------------------------------------------------------------------
   function modifiedTime = getModifiedTime(entry)
      modifiedTime = entry.getTime;
   end

%--------------------------------------------------------------------------
end
