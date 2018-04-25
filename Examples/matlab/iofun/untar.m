function varargout = untar(tarFilename, varargin)
%UNTAR Extract contents of tar file.
%
%   UNTAR(TARFILENAME) extracts the archived contents of TARFILENAME into the current
%   directory and sets the file's attributes. On Windows, the hidden, system and
%   archive attributes are not set. UNTAR overwrites an existing file with the same
%   name as the archive name if the existing file's attributes and ownership permit;
%   otherwise a warning is issued.
%
%   TARFILENAME is the name of the tar file. TARFILENAME is gunzipped to a temporary
%   directory and deleted if its extension ends in '.tgz' or '.gz'.  If an extension
%   is omitted, UNTAR searches for TARFILENAME appended with '.tgz', '.tar.gz' or
%   '.tar' until a file exists. TARFILENAME can include the directory name;
%   otherwise, the file must be in the current directory or in a directory on the
%   MATLAB path.
%
%   UNTAR(TARFILENAME,OUTPUTDIR) extracts the archived contents of TARFILENAME into
%   the directory OUTPUTDIR. OUTPUTDIR is created if it does not exist.
%
%   UNTAR(URL, ...) extracts the tar archive from an  Internet URL. The URL must
%   include the protocol type (e.g., 'http://' or 'ftp://'). The URL is downloaded to
%   the temp directory and deleted.
%
%   FILENAMES = UNTAR(...) extracts the tar archive and returns the relative path
%   names of the extracted files into the cell array, FILENAMES.
%
%   Example: 
%   % Copy all *.m files in the current directory to the directory 'backup'
%   tar('mymfiles.tar.gz','*.m');
%   untar('mymfiles','backup');
%
%   % Untar and list Cleve Moler's Numerical Computing with MATLAB examples
%   % to the output directory 'ncm'.
%   url ='http://www.mathworks.com/moler/ncm.tar.gz';
%   ncmFiles = untar(url,'ncm')
%
%   See also FILEATTRIB, GZIP, GUNZIP, TAR, UNZIP, ZIP.

%   Copyright 2004-2016 The MathWorks, Inc.

narginchk(1,2);
nargoutchk(0,1);

[tarFilename,varargin{1:nargin-1}] = matlab.io.internal.utility.convertStringsToChars(tarFilename,varargin{:});

% Argument parsing.
[tarFilename, outputDir, url, urlFilename, uncompressFcn] = ...
   parseUnArchiveInputs(mfilename, tarFilename, ...
                        {'tgz', 'tar.gz', 'tar'},  ...
                        'TARFILENAME', varargin{:});

% Test if the tarfile needs to be uncompressed.
if ~isempty(uncompressFcn)
   try
      tarFilename = uncompressFcn(tarFilename,tempdir);
   catch exception
      % If the tar file is a URL, the HTTP client may have
      % uncompressed the file.  If so, allow the file to pass.
      if ~(url && isequal('MATLAB:gunzip:notGzipFormat', exception.identifier))
         throw(exception)
      end
   end
end

% Create a Java TarInputStream object.
tarJavaFile  = java.io.File(tarFilename);
fileInStream = java.io.FileInputStream(tarJavaFile);
tarInStream  = com.mathworks.mlwidgets.io.MwTarInputStream(fileInStream);

% Setup the TAR API to process the entries.
api.getInputStream  = @getInputStream;
api.getEntryName    = @getEntryName;
api.getNextEntry    = @getNextEntry;
api.getFileMode     = @getFileMode;
api.getModifiedTime = @getModifiedTime;

% Extract TAR contents.
try
   files = extractArchive( outputDir, api, mfilename);
catch exception
   cleanup;
   throw(exception)
end

cleanup;
if nargout == 1
   varargout{1} = files;
end

%--------------------------------------------------------------------------
   function inputStream = getInputStream(entry) %#ok<INUSD>
      inputStream  = tarInStream;
   end

%--------------------------------------------------------------------------
   function entryName = getEntryName(entry)     %#ok<INUSD>
      byteName = tarInStream.getByteName();
      int8Name = int8(byteName');
      uint8Name = typecast(int8Name,'uint8');
      if tarInStream.useUTF8ForName()
         entryName = native2unicode(uint8Name, 'UTF-8');
      else
         entryName = native2unicode(uint8Name);
      end
   end

%--------------------------------------------------------------------------
   function entry = getNextEntry
      entry = tarInStream.getNextEntry();
      
      % Validate the entry.
      
      % If the stream encounters an invalid entry it will return null.
      % This happens with an invalid tar file.
      % TODO: only with an invalid tar file?
      if tarInStream.hasInvalidEntry()
          cleanup;
          error(message('MATLAB:untar:invalidTarFile', tarFilename));
      end
      
      if ~isempty(entry) &&  ~entry.isDirectory && ...
            (entry.getSize    < 0 || ...
            entry.getGroupId < 0 || ...
            entry.getMode   < 0 || ...
            entry.getUserId  < 0 )
         cleanup;
         error(message('MATLAB:untar:invalidTarFile', tarFilename));
      end
   end

%--------------------------------------------------------------------------
   function fileMode = getFileMode(entry)
      fileMode = entry.getMode;
      if ispc
         % On a PC, the unix file mode must be shifted by 16 bits
         % to make it appear as an external file attribute.
         % The Zip classes shift the unix mode by 16 bits,
         % but the Tar classes do not.
         %
         % Tar does not preserve the hidden, archive, and system file
         % attributes. These attributes are in the lower 2-bytes.
         fileMode = bitshift(fileMode, 16);
      end
   end

%--------------------------------------------------------------------------
   function modifiedTime = getModifiedTime(entry)
      lastModified = entry.getModTime;
      modifiedTime = lastModified.getTime;
   end

%--------------------------------------------------------------------------
   function cleanup
      fileInStream.close;
      tarInStream.close;
      if ~isempty(uncompressFcn)
         tarJavaFile.delete;
      end
      if url && ~isempty(urlFilename) && exist(urlFilename,'file')
         delete(urlFilename)
      end
   end
end
