function insertRows(fptr,firstrow,nrows)
%insertRows insert rows into table
%   insertRows(FPTR,FIRSTROW,NROWS) inserts rows into an ASCII or binary
%   table.  FIRSTROW is a one-based number.
%
%   This function corresponds to the "fits_insert_rows" (ffirow) function in 
%   the CFITSIO library C API.
%
%   Example:  Insert five rows into an empty table.
%       import matlab.io.*
%       fptr = fits.createFile('myfile.fits');
%       ttype = {'Col1','Col2'};
%       tform = {'3A','1D'};
%       tunit = {'m/s','candela'};
%       fits.createTbl(fptr,'binary',0,ttype,tform,tunit,'my-table');
%       fits.insertRows(fptr,1,5);
%       fits.closeFile(fptr);
%       fitsdisp('myfile.fits','index',2);
%
%   See also fits, insertCol, deleteRows.

%   Copyright 2011-2013 The MathWorks, Inc.

validateattributes(fptr,{'uint64'},{'scalar'},'','FPTR');
validateattributes(firstrow,{'double'},{'integer','scalar','positive'},'','FIRSTROW');
validateattributes(nrows,{'double'},{'integer','scalar','positive'},'','NROWS');

fitsiolib('insert_rows',fptr,firstrow-1,nrows);
