function insertBTbl(fptr,nrows,ttype,tform,tunit,extname,pcount)
%insertBTbl insert binary table after current HDU
%   insertBTbl(FPTR,NROWS,TTYPE,TFORM,TUNIT,EXTNAME,PCOUNT) inserts a
%   a new binary table extension immediately following the current HDU. Any 
%   following extensions will be shifted down to make room for the new 
%   extension. If there are no other following extensions then the new 
%   table extension will simply be appended to the end of the file. If the 
%   FITS file is currently empty then this routine will create a dummy 
%   primary array before appending the table to it. The new extension will 
%   become the CHDU.  If there are following extensions in the file and if 
%   the table contains variable length array columns then PCOUNT must 
%   specify the expected final size of the data heap, otherwise PCOUNT 
%   must be zero. 
%
%   This function corresponds to the "fits_insert_btbl" (ffibin) function in 
%   the CFITSIO library C API.
%
%   Example:  Create a table following the primary array, then insert a new
%   table just before it.
%       import matlab.io.*
%       fptr = fits.createFile('myfile.fits');
%       ttype = {'Col1','Col2'};
%       tform = {'9A','1D'};
%       tunit = {'m/s','candela'};
%       fits.createTbl(fptr,'binary',10,ttype,tform,tunit,'my-table');
%       fits.movRelHDU(fptr,-1);
%       fits.insertBTbl(fptr,5,ttype,tform,tunit,'my-new-table',0);
%       fits.closeFile(fptr);
%       fitsdisp('myfile.fits');
%
%   See also fits, createTbl, insertATbl.

%   Copyright 2011-2013 The MathWorks, Inc.

validateattributes(fptr,{'uint64'},{'scalar'},'','FPTR');
validateattributes(nrows,{'double'},{'integer','scalar','>=',0},'','NROWS');
validateattributes(ttype,{'cell'},{'nonempty'},'','TTYPE');

validateattributes(tform,{'cell'},{'nonempty'},'','TFORM');

validateattributes(tunit,{'cell'},{'nonempty'},'','TUNIT');
validateattributes(extname,{'char'},{'nonempty'},'','EXTNAME');
validateattributes(pcount,{'double'},{'integer','scalar','>=',0},'','PCOUNT');

fitsiolib('insert_btbl',fptr,nrows,ttype,tform,tunit,extname,pcount);
