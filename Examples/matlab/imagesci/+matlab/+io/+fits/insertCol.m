function insertCol(fptr,colnum,ttype,tform)
%insertCol insert column into table
%   insertCol(FPTR,COLNUM,TTYPE,TFORM) inserts a column into an ASCII or
%   binary table.
%
%   This function corresponds to the "fits_insert_col" (fficol) function in 
%   the CFITSIO library C API.
%
%   Example:
%       import matlab.io.*
%       fptr = fits.createFile('myfile.fits');
%       ttype = {'Col1','Col2'};
%       tform = {'3A','1D'};
%       tunit = {'m/s','candela'};
%       fits.createTbl(fptr,'binary',0,ttype,tform,tunit,'my-table');
%       fits.insertCol(fptr,3,'Col3','3D');
%       fits.closeFile(fptr);
%       fitsdisp('myfile.fits','index',2);
% 
%   See also fits, insertRows.

%   Copyright 2011-2013 The MathWorks, Inc.

validateattributes(fptr,{'uint64'},{'scalar'},'','FPTR');
validateattributes(colnum,{'double'},{'integer','scalar','positive'},'','COLNUM');
validateattributes(ttype,{'char'},{'nonempty'},'','TTYPE');
validateattributes(tform,{'char'},{'nonempty'},'','TFORM');

fitsiolib('insert_col',fptr,colnum,ttype,tform);
