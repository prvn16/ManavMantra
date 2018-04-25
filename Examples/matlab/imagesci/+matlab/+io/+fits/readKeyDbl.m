function [value,comment] = readKeyDbl(fptr,keyname)
%readKeyDbl return the specified keyword as double precision value
%   [VALUE,COMMENT] = readKeyDbl(FPTR,KEYNAME) returns the specified key and 
%   comment.  
%
%   This function corresponds to the "fits_read_key_dbl" (ffgkyd) function in 
%   the CFITSIO library C API.
%
%   Example:
%       import matlab.io.*
%       fptr = fits.openFile('tst0012.fits');
%       n = fits.getNumHDUs(fptr);
%       for j = 1:n
%           fits.movAbsHDU(fptr,j);
%           [key,comment] = fits.readKeyDbl(fptr,'NAXIS');
%           fprintf('HDU %d:  NAXIS %s, "%s"\n', j, key, comment);
%       end
%       fits.closeFile(fptr);
%
%   See also fits, readKey, readKeyCmplx, readKeyLongLong

%   Copyright 2011-2013 The MathWorks, Inc.
                                                                                                                 
validateattributes(fptr,{'uint64'},{'scalar'},'','FPTR');
validateattributes(keyname,{'char'},{'nonempty'},'','KEYNAME');
[value,comment] = fitsiolib('read_key_dbl',fptr,keyname);
