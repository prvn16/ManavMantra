function deleteKey(fptr,keyname)
%deleteKey delete key by name
%   deleteKey(FPTR,KEYNAME) deletes a keyword by name.
%
%   This function corresponds to the "fits_delete_key" (ffdrec) function in 
%   the CFITSIO library C API.
%
%   Example:  
%       import matlab.io.*
%       srcFile = fullfile(matlabroot,'toolbox','matlab','demos','tst0012.fits');
%       copyfile(srcFile,'myfile.fits');
%       fileattrib('myfile.fits','+w');
%       fprintf('Before key deletion...\n');
%       fitsdisp('myfile.fits','index',1);
%       fptr = fits.openFile('myfile.fits','readwrite');
%       fits.deleteKey(fptr,'DATE');
%       fits.closeFile(fptr);
%       fprintf('\n\n\nAfter key deletion...\n');
%       fitsdisp('myfile.fits','index',1);
%
%   See also fits, deleteRecord, writeKey.

%   Copyright 2011-2013 The MathWorks, Inc.

validateattributes(fptr,{'uint64'},{'scalar'},'','FPTR');
validateattributes(keyname,{'char'},{'nonempty'},'','KEYNAME');
fitsiolib('delete_key',fptr,keyname);

