function deleteCol(fptr,colnum)
%deleteCol delete column from table
%   deleteCol(FPTR,COLNUM) deletes the column from an ASCII or binary 
%   table.
%
%   This function corresponds to the "fits_delete_col" (ffdcol) function in 
%   the CFITSIO library C API.
%
%   Example:  Delete the second column in a binary table.
%       import matlab.io.*
%       srcFile = fullfile(matlabroot,'toolbox','matlab','demos','tst0012.fits');
%       copyfile(srcFile,'myfile.fits');
%       fileattrib('myfile.fits','+w');
%       fprintf('Before:  '); fitsdisp('myfile.fits','index',2,'mode','min');
%       fptr = fits.openFile('myfile.fits','readwrite');
%       fits.movAbsHDU(fptr,2);
%       fits.deleteCol(fptr,2);
%       fits.closeFile(fptr);
%       fprintf('After :  '); fitsdisp('myfile.fits','index',2,'mode','min');
%
%   See also fits, deleteRows.

%   Copyright 2011-2013 The MathWorks, Inc.

validateattributes(fptr,{'uint64'},{'scalar'},'','FPTR');
validateattributes(colnum,{'double'},{'scalar','integer','positive'},'','COLNUM');
fitsiolib('delete_col',fptr,colnum);
