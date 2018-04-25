function hdu_type = deleteHDU(fptr)
%deleteHDU delete current HDU in FITS file
%   HDU_TYPE = deleteHDU(FPTR) deletes the current HDU in the FITS file.  
%   Any following HDUs will be shifted forward in the file, filling the gap
%   created by the deleted HDU.  In the case of deleting the primary array
%   (the first HDU in the file) then the current primary array will be
%   replaced by a null primary array containing the minimum set of required
%   keywords and no data.  If there are more HDUs in the file following the
%   HDU being deleted, then the current HDU will be redefined to point to 
%   the following HDU.  If there are no following HDUs then the current HDU
%   will be redefined to point to the previous HDU.  HDU_TYPE returns the
%   type of the new current HDU.
%
%   This function corresponds to the "fits_delete_hdu" (ffdhdu) function in 
%   the CFITSIO library C API.
%
%   Example:  Delete the second HDU in a FITS file.  
%       import matlab.io.*
%       srcFile = fullfile(matlabroot,'toolbox','matlab','demos','tst0012.fits');
%       copyfile(srcFile,'myfile.fits');
%       fileattrib('myfile.fits','+w');
%       fitsdisp('myfile.fits','mode','min');
%       fptr = fits.openFile('myfile.fits','readwrite');
%       fits.movAbsHDU(fptr,2);
%       new_current_hdu = fits.deleteHDU(fptr);
%       fits.closeFile(fptr);
%       fitsdisp('myfile.fits','mode','min');
%
%   See also fits, copyHDU.

%   Copyright 2011-2013 The MathWorks, Inc.

validateattributes(fptr,{'uint64'},{'scalar'},'','FPTR');
hdu_type = fitsiolib('delete_hdu',fptr);
