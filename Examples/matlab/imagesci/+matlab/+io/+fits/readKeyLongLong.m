function [value,comment] = readKeyLongLong(fptr,keyname)
%readKeyLongLong return the specified keyword as int64
%   [VALUE,COMMENT] = readKeyLongLong(FPTR,KEYNAME) returns the specified key 
%   and comment.  VALUE is returned an int64 scalar value. 
%
%   This function corresponds to the "fits_read_key_lnglng" (ffgkyjj) 
%   function in the CFITSIO library C API.
%
%   Example:
%       import matlab.io.*
%       fptr = fits.openFile('tst0012.fits');
%       n = fits.getNumHDUs(fptr);
%       for j = 1:n
%           fits.movAbsHDU(fptr,j);
%           [key,comment] = fits.readKeyLongLong(fptr,'NAXIS');
%           fprintf('HDU %d:  NAXIS %d, "%s"\n', j, key, comment);
%       end
%       fits.closeFile(fptr);
%
%   See also fits, readKey, readKeyCmplx, readKeyDbl

%   Copyright 2011-2013 The MathWorks, Inc.
                                                                                                                 
validateattributes(fptr,{'uint64'},{'scalar'},'','FPTR');
validateattributes(keyname,{'char'},{'nonempty'},'','KEYNAME');
[value,comment] = fitsiolib('read_key_lnglng',fptr,keyname);
