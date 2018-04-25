function compressFcn = getArchiveCompressFcn(extension, archiveFcn)
%GETARCHIVECOMPRESSFCN Get a compression function handle for an archive
%
%   GETARCHIVECOMPRESSFCN returns a handle to a compress (or uncompress)
%   function by comparing the string EXTENSION with known compression
%   extensions. ARCHIVEFCN is the name of the archive function (e.g. tar,
%   untar, zip, unzip).

%   Copyright 2004 The MathWorks, Inc.

switch lower(extension)
   case {'.tgz','.gz'} % GZip
      if isequal(archiveFcn(1:2),'un')
         compressFcn = @gunzip;
      else
         compressFcn = @gzip;
      end
      
   case {'.bz2', '.bz', '.tbz2' '.tbz', 'bzip2'} % BZip2
      % Currently BZip2 is unsupported
      compressFcn = [];
      
   otherwise
      compressFcn = [];
end

