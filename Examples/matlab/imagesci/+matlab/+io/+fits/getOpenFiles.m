function fptrs = getOpenFiles()
%getOpenFiles Return list of open FITS files.
%   fptrs = getOpenFiles() returns a list of file pointers of all
%   open FITS files.
%
%   Example:
%       import matlab.io.*
%       fptr = fits.openFile('tst0012.fits');
%       clear fptr;
%       fptr = fits.getOpenFiles(); 
%       fits.closeFile(fptr);
%
%   See also fits, openFile, closeFile.

%   Copyright 2011-2013 The MathWorks, Inc.

fptrs = fitsiolib('get_open_files');
