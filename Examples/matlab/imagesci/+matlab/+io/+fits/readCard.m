function card = readCard(fptr,keyname)
%readCard Return entire header record of keyword.
%   CARD = readCard(FPTR,KEYNAME) returns the entire 80-character header 
%   record of the keyword, with any trailing blank characters stripped off.
%
%   This function corresponds to the "fits_read_card" (ffgcrd) function in 
%   the CFITSIO library C API.
%
%   Example:
%       import matlab.io.*
%       fptr = fits.openFile('tst0012.fits');
%       n = fits.getNumHDUs(fptr);
%       for j = 1:n
%           fits.movAbsHDU(fptr,j);
%           card = fits.readCard(fptr,'NAXIS');
%           fprintf('HDU %d:  ''%s''\n', j, card);
%       end
%       fits.closeFile(fptr);
%
%   See also fits, readRecord, readKey;

%   Copyright 2011-2013 The MathWorks, Inc.
                                                                                                                 
validateattributes(fptr,{'uint64'},{'scalar'},'','FPTR');
validateattributes(keyname,{'char'},{'row','nonempty'},'','KEYNAME');
card = fitsiolib('read_card',fptr,keyname);
