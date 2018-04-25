function [value,comment] = readKeyLongStr(fptr,keyname)
%readKeyLongStr return the specified keyword
%   [VALUE,COMMENT] = readKeyLongStr(FPTR,KEYNAME) returns the specified 
%   long string value and comment.  
%
%   This function corresponds to the "fits_read_key_longstr" (ffgkls) 
%   function in the CFITSIO library C API.
%
%   Example:
%       import matlab.io.*
%       idata = repmat(char(97:106),1,10);
%       fptr = fits.createFile('myfile.fits');
%       fits.createImg(fptr,'byte_img',[100 200]);
%       fits.writeKey(fptr,'mykey',idata);
%       odata1 = fits.readKey(fptr,'mykey');
%       odata2 = fits.readKeyLongStr(fptr,'mykey');
%       fits.closeFile(fptr);
%
%   See also fits, readKey;

%   Copyright 2011-2013 The MathWorks, Inc.
                                                                                                                 
validateattributes(fptr,{'uint64'},{'scalar'},'','FPTR');
validateattributes(keyname,{'char'},{'nonempty'},'','KEYNAME');
[value,comment] = fitsiolib('read_key_longstr',fptr,keyname);
