function deleteRecord(fptr,keynum)
%deleteRecord delete key by record number
%   deleteRecord(FPTR,KEYNUM) deletes a keyword by record number.
%
%   This function corresponds to the "fits_delete_record" (ffdrec) function 
%   in the CFITSIO library C API.
%
%   Example:  Delete the 18th keyword ("ORIGIN") in a primary array.
%       import matlab.io.*
%       srcFile = fullfile(matlabroot,'toolbox','matlab','demos','tst0012.fits');
%       copyfile(srcFile,'myfile.fits');
%       fileattrib('myfile.fits','+w');
%       fptr = fits.openFile('myfile.fits','readwrite');
%       card = fits.readRecord(fptr,18);
%       fits.deleteRecord(fptr,18);
%       fits.closeFile(fptr);
%
%   See also fits, readRecord, deleteKey.

%   Copyright 2011-2013 The MathWorks, Inc.

validateattributes(fptr,{'uint64'},{'scalar'},'','FPTR');
validateattributes(keynum,{'numeric'},{'scalar','integer','positive'},'','KEYNUM');
fitsiolib('delete_record',fptr,keynum);


