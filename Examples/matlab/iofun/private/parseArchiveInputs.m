function [files, rootDir, archiveFilename, compressFcn] = parseArchiveInputs(...
   archiveFcn, archiveFilename, files, varargin)
%PARSEARCHIVEINPUTS Parse arguments for archive functions.
%
%   PARSEARCHIVEINPUTS parses and checks an archive function's input
%   arguments. 
%
%   Inputs Arguments:
%   -----------------
%   ARCHIVEFCN is the string name of the archive function, generally the
%   name of the calling function, and is the extension for the archive. 
%
%   ARCHIVEFILENAME is a string name of the archive. 
%   
%   FILES is a character string or cell array of filenames to add to an
%   archive.
%
%   VARARGIN is a cell array which contains ROOTDIR, the name of the root
%   directory for FILES. 
%
%   Output Arguments:
%   ----------------- 
%   The output FILES is a string cell array of the filenames to be added to
%   the archive. 
%
%   ROOTDIR is a string directory name and will be returned empty if not
%   supplied. 
%
%   ARCHIVEFILENAME is the name of the archive filename. 
%
%   COMPRESSFCN is a handle to a function which compresses the archive.
%   (Currently only GZIP is supported.) COMPRESSFCN is empty if no
%   compression is required.

%   Copyright 2004-2011 The MathWorks, Inc.

% Check the FILES and ROOTDIR inputs
[files, rootDir] = checkFilesDirInputs(archiveFcn, files, varargin{:});

% archiveFilename must be a character string
if ~ischar(archiveFilename)
   eid = sprintf('MATLAB:%s:invalidFileString', archiveFcn);
   error(eid, '%s', ...
      getString(message('MATLAB:parseArchiveInputs:invalidFileString', upper(archiveFcn))));
end

% Get the compression function if requested
[~, ~, archiveExt]=fileparts(archiveFilename);
if nargout >= 4
   compressFcn = getArchiveCompressFcn(archiveExt, archiveFcn);
else
   compressFcn = [];
end

% If no compression function and no extension is given for output,
% or the extension is not equal to the default
% then add the default extension to the filename.
%
% For example:
%  ArchiveFilename   New ArchiveFilename
%  ---------------   -------------------
%  MFYILE.comressExt MYFILE.compressExt
%  MFYILE.archiveExt MYFILE.archiveExt
%  MYFILE            MYFILE.defArhiveExt
%  MYFILE.dat        MYFILE.dat.defArchiveExt

defArchiveExt = ['.' lower(archiveFcn)];
if isempty(compressFcn) && ...
      (isempty(archiveExt) || ~isequal(archiveExt,defArchiveExt))
   archiveFilename = [archiveFilename defArchiveExt];
end

% archiveFilename must not be a directory 
[path,name]=fileparts(archiveFilename);
if isempty(name) || exist(archiveFilename,'dir') 
   if isempty(name)
     archiveFilename = path;
   end
   eid = sprintf('MATLAB:%s:isDirectory', archiveFcn);
   error(eid, '%s', ...
      getString(message('MATLAB:parseArchiveInputs:isDirectory', upper(archiveFcn), archiveFilename)));
end
