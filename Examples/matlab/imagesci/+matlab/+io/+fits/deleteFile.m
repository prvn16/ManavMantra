function deleteFile(fptr)
%deleteFile delete a FITS file.
%   deleteFile(FPTR) closes and deletes an open FITS file.  This can be 
%   useful if a FITS file cannot be properly closed.
%
%   This function corresponds to the "fits_delete_file" (ffdelt) function in 
%   the CFITSIO library C API.
%
%   Example:
%       import matlab.io.*
%       srcFile = fullfile(matlabroot,'toolbox','matlab','demos','tst0012.fits');
%       copyfile(srcFile,'myfile.fits');
%       fileattrib('myfile.fits','+w');
%       fptr = fits.openFile('myfile.fits','readwrite');
%       fits.deleteFile(fptr);
%       fptrs = fits.getOpenFiles()
%
%   See also fits, createFile, closeFile.

%   Copyright 2011-2013 The MathWorks, Inc.

validateattributes(fptr,{'uint64'},{'scalar'},'','FPTR');

fitsiolib('delete_file',fptr);
