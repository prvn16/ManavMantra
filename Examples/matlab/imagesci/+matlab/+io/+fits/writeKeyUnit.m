function writeKeyUnit(fptr,keyname,unit)
%writeKeyUnit write physical units string into existing keyword
%   writeKeyUnit(FPTR,KEYNAME,UNIT) writes a physical units string into an 
%   existing keyword.
%
%   This function corresponds to the "fits_write_key_unit" (ffpunt) function 
%   in the CFITSIO library C API.
%
%   Example:
%       import matlab.io.*
%       fptr = fits.createFile('myFitsFile.fits');
%       fits.createImg(fptr,'long_img',[10 20]);
%       fits.writeKey(fptr,'VELOCITY',12.3,'orbital speed');
%       fits.writeKeyUnit(fptr,'VELOCITY','km/s');
%       fits.closeFile(fptr);
%
%   See also fits, readKeyUnit.

%   Copyright 2011-2013 The MathWorks, Inc.
                                                                                                                 
validateattributes(fptr,{'uint64'},{'scalar'},'','FPTR');
validateattributes(keyname,{'char'},{'nonempty'},'','KEYNAME');
validateattributes(unit,{'char'},{},'','UNIT');

fitsiolib('write_key_unit',fptr,keyname,unit);
