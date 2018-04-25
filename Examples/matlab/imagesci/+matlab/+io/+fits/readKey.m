function [value,comment] = readKey(fptr,keyname)
%readKey return the specified keyword
%   [VALUE,COMMENT] = readKey(FPTR,KEYNAME) returns the specified key and 
%   comment.  VALUE is returned as a string.
%
%   This function corresponds to the "fits_read_key_str" (ffgkys) function 
%   in the CFITSIO library C API.
%
%   Example:
%       import matlab.io.*
%       fptr = fits.openFile('tst0012.fits');
%       n = fits.getNumHDUs(fptr);
%       for j = 1:n
%           fits.movAbsHDU(fptr,j);
%           [key,comment] = fits.readKey(fptr,'NAXIS');
%           fprintf('HDU %d:  NAXIS %s, "%s"\n', j, key, comment);
%       end
%       fits.closeFile(fptr);
%
%   See also fits, readKeyCmplx, readKeyDbl, readKeyLongLong

%   Copyright 2011-2013 The MathWorks, Inc.
                                                                                                                 
validateattributes(fptr,{'uint64'},{'scalar'},'','FPTR');
validateattributes(keyname,{'char'},{'nonempty'},'','KEYNAME');
[value,comment] = fitsiolib('read_key_str',fptr,keyname);
