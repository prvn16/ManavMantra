function writeCol(fptr,colnum,firstrow,coldata)
%writeCol write elements into ASCII or binary table column
%   writeCol(FPTR,COLNUM,FIRSTROW,COLDATA) writes elements into an 
%   ASCII or binary table extension column.
%
%   When writing rows of data to a variable length field, COLDATA must be
%   a cell array.
%
%   This function corresponds to the "fits_write_col" (ffpcl) function in
%   the CFITSIO library C API.
%
%   Example:  Write to a table with ASCII, uint8, double precision, and
%   variable length double precision columns.
%       import matlab.io.*
%       fptr = fits.createFile('myfile.fits');
%       ttype = {'Col1','Col2','Col3','Col4'};
%       tform = {'3A','3B','1D','1PD'};
%       tunit = {'m/s','kg/m^3','candela','parsec'};
%       fits.createTbl(fptr,'binary',0,ttype,tform,tunit,'my-table');
%       fits.writeCol(fptr,1,1,['dog'; 'cat']);
%       fits.writeCol(fptr,2,1,[0 1 2; 3 4 5; 6 7 8; 9 10 11]);
%       fits.writeCol(fptr,3,1,[1; 2; 3; 4]);
%       fits.writeCol(fptr,4,1,{1;[1 2];[1 2 3];[1 2 3 4]});
%       fits.closeFile(fptr);
%       fitsdisp('myfile.fits','index',2,'mode','full');
%
%   Example:  Write to a table with logical, bit, double precision, and
%   variable length complex single precision columns.
%       import matlab.io.*
%       fptr = fits.createFile('myfile.fits');
%       ttype = {'Col1','Col2','Col3','Col4'};
%       tform = {'2L','3X','1D','1PC'};
%       tunit = {'','kg/m^3','candela','parsec'};
%       fits.createTbl(fptr,'binary',0,ttype,tform,tunit,'my-table');
%       fits.writeCol(fptr,1,1,[false false; true false]);
%       fits.writeCol(fptr,2,1,int8([0 1 1; 1 1 1; 1 1 1; 1 0 1]));
%       fits.writeCol(fptr,3,1,[1; 2; 3; 4]);
%       data = cell(4,1);
%       data{1} = single(1);
%       data{2} = single(1+2j);
%       data{3} = single([1j 2 3+j]);
%       data{4} = single([1 2+3j 3 4]);
%       fits.writeCol(fptr,4,1,data);
%       fits.closeFile(fptr);
%       fitsdisp('myfile.fits','index',2,'mode','full');
%
%   See also fits, createTbl, readCol.

%   Copyright 2011-2013 The MathWorks, Inc.
                                                                                                                 
validateattributes(fptr,{'uint64'},{'scalar'},'','FPTR');
validateattributes(colnum,{'double'},{'scalar','integer','positive'},'','COLNUM');
validateattributes(firstrow,{'double'},{'scalar','integer'},'','FIRSTROW');
dtypes = {'cell','char','logical','double','single','int64','int32','int16','int8','uint8'};
validateattributes(coldata,dtypes,{'nonempty'},'','COLDATA');

if ischar(coldata)
    coldata = coldata';
else
    if ~iscell(coldata)
        coldata = permute(coldata,[2 1]);
    end
end
fitsiolib('write_col',fptr,colnum,firstrow,coldata);
