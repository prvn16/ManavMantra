function unit = readKeyUnit(fptr,keyname)
%readKeyUnit return physical units string from keyword
%   UNITS = fits.readKeyUnit(FPTR,KEYNAME) returns the physical units string
%   from an existing keyword.   If no units are defined, UNITS is returned
%   as an empty string.
%
%   This function corresponds to the "fits_read_key_unit" (ffgunt) function 
%   in the CFITSIO library C API.
%
%   Example:
%       import matlab.io.*
%       fptr = fits.createFile('myfile.fits');
%       fits.createImg(fptr,'long_img',[10 20]);
%       fits.writeKey(fptr,'VELOCITY',12.3,'orbital speed');
%       fits.writeKeyUnit(fptr,'VELOCITY','km/s');
%       units = fits.readKeyUnit(fptr,'VELOCITY');
%       fits.closeFile(fptr);
%
%   See also fits, readKey, writeKeyUnit.

%   Copyright 2011-2013 The MathWorks, Inc.
                                                                                                                 
validateattributes(fptr,{'uint64'},{'scalar'},'','FPTR');
validateattributes(keyname,{'char'},{'nonempty'},'','KEYNAME');

unit = fitsiolib('read_key_unit',fptr,keyname);

