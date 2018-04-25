function deleteRows(fptr,firstrow,nrows)
%deleteRows delete rows from table
%   deleteRows(FPTR,FIRSTROW,NROWS) deletes rows from an ASCII or binary 
%   table.
%
%   This function corresponds to the "fits_delete_rows" (ffdrow) function in 
%   the CFITSIO library C API.
%
%   Example:  Delete the second, third, and fourth rows in a binary table 
%   (second HDU).
%       import matlab.io.*
%       srcFile = fullfile(matlabroot,'toolbox','matlab','demos','tst0012.fits');
%       copyfile(srcFile,'myfile.fits');
%       fileattrib('myfile.fits','+w');
%       fprintf('Before:  '); fitsdisp('myfile.fits','index',2,'mode','min');
%       fptr = fits.openFile('myfile.fits','readwrite');
%       fits.movAbsHDU(fptr,2);
%       fits.deleteRows(fptr,2,2);
%       fits.closeFile(fptr);
%       fprintf('After :  '); fitsdisp('myfile.fits','index',2,'mode','min');
%
%   See also fits, deleteCol, insertRows.

%   Copyright 2011-2013 The MathWorks, Inc.

validateattributes(fptr,{'uint64'},{'scalar'},'','FPTR');
validateattributes(firstrow,{'double'},{'scalar','integer','positive'},'','FIRSTROW');
validateattributes(nrows,{'double'},{'scalar','integer','positive'},'','nrows');

fitsiolib('delete_rows',fptr,firstrow,nrows);
