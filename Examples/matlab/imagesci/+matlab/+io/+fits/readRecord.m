function card = readRecord(fptr,keynum)
%readRecord return specified header record specified by number
%   CARD = readRecord(FPTR,KEYNUM) returns the entire 80-character header 
%   record identified by the numeric KEYNUM.  Trailing blanks will be 
%   truncated.
%
%   This function corresponds to the "fits_read_record" (ffgrec) function 
%   in the CFITSIO library C API.
%
%   Example:  Read the second record in each HDU.
%       import matlab.io.*
%       fptr = fits.openFile('tst0012.fits');
%       n = fits.getHdrSpace(fptr);
%       for j = 1:n
%           card = fits.readRecord(fptr,j);
%           fprintf('record %d:  "%s"\n', j, card);
%       end
%       fits.closeFile(fptr);
%
%   See also fits, deleteRecord, readKey, readCard.

%   Copyright 2011-2013 The MathWorks, Inc.
                                                                                                                 
validateattributes(fptr,{'uint64'},{'scalar'},'','fptr');
validateattributes(keynum,{'double'},{'scalar','integer','positive'},'','KEYNUM');

card = fitsiolib('read_record',fptr,keynum);
