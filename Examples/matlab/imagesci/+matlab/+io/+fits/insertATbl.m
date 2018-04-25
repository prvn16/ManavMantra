function insertATbl(fptr,rowlen,nrows,ttype,tbcol,tform,tunit,extname)
%insertATbl insert ASCII table after current HDU
%   insertATbl(FPTR,ROWLEN,NROWS,TTYPE,TBCOL,TFORM,TUNIT,EXTNAME) inserts a
%   a new ASCII table extension immediately following the current HDU. Any
%   following extensions will be shifted down to make room for the new
%   extension. If there are no other following extensions then the new
%   table extension will simply be appended to the end of the file. If the
%   FITS file is currently empty then this routine will create a dummy
%   primary array before appending the table to it. The new extension will
%   become the current HDU.   If ROWLEN is 0, then CFITSIO will calculate 
%   the default ROWLEN based on the TBCOL and TTYPE values.
%
%   TFORM may take the following forms.  In each case, 'w' and 'ww'
%   represent the widths of the ASCII columns.
%
%       Iw     - int16 column 
%       Aw     - ASCII column
%       Fww.dd - Fixed point with 'dd' digits after the decimal point
%       Eww.dd - single precision with 'dd' digits of precision
%       Dww.dd - double precision with 'dd' digits of precision
%
%   Binary tables are recommended instead of ASCII tables.
%
%   This function corresponds to the "fits_insert_atbl" (ffitab) function 
%   in  the CFITSIO library C API.
%
%   Example:  Create an ASCII table inbetween two images.
%       import matlab.io.*
%       fptr = fits.createFile('myfile.fits');
%       fits.createImg(fptr,'uint8',[20 30]);
%       fits.createImg(fptr,'int16',[30 40]);
%       fits.movRelHDU(fptr,-1);
%       ttype = {'Name','Short','Fix','Double'};
%       tbcol = [1 17 28 43];
%       tform = {'A15','I10','F14.2','D12.4'};
%       tunit = {'','m**2','cm','km/s'};
%       fits.insertATbl(fptr,0,0,ttype,tbcol,tform,tunit,'my-table');
%       fits.writeCol(fptr,1,1,char('abracadabra','hocus-pocus'));
%       fits.writeCol(fptr,2,1,int16([0; 1]));
%       fits.writeCol(fptr,3,1,[12.4; 4/3]);
%       fits.writeCol(fptr,4,1,[12.4; 4e8/3]);
%       fits.closeFile(fptr);
%       fitsdisp('myfile.fits','mode','min');
%
%   See also fits, createTbl, insertBTbl.

%   Copyright 2011-2013 The MathWorks, Inc.

validateattributes(fptr,{'uint64'},{'scalar'},'','FPTR');
validateattributes(rowlen,{'double'},{'integer','scalar','>=',0},'','ROWLEN');
validateattributes(nrows,{'double'},{'integer','scalar','>=',0},'','NROWS');
validateattributes(ttype,{'cell'},{'nonempty'},'','TTYPE');
n = numel(ttype);
validateattributes(tbcol,{'double'},{'integer','row','size',[1 n]},'','TBCOL');
validateattributes(tform,{'cell'},{'nonempty','row','size',[1 n]},'','TFORM');
validateattributes(tunit,{'cell'},{'nonempty','row','size',[1 n]},'','TUNIT');
validateattributes(extname,{'char'},{'nonempty'},'','EXTNAME');


fitsiolib('insert_atbl',fptr,rowlen,nrows,ttype,tbcol,tform,tunit,extname);
