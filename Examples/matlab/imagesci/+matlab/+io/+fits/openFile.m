function fptr = openFile(filename, mode)
%openFile Open FITS file.
%   FPTR = openFile(FILENAME) opens a existing FITS file in read-only mode 
%   and returns a file pointer FPTR, which will reference the primary
%   array (first header data unit, or "HDU").
%
%   FPTR = openFile(FILENAME,MODE) opens a existing FITS file according to
%   the MODE, which describes the type of access.  MODE may be either
%   'READONLY' or 'READWRITE'.
%
%   This function corresponds to the "fits_open_file" (ffopen) function in 
%   the CFITSIO library C API.
%
%   Example:  Open a file in read-only mode and read image data from the
%   primary array.
%       import matlab.io.*
%       fptr = fits.openFile('tst0012.fits');
%       imagedata = fits.readImg(fptr);
%       fits.closeFile(fptr);
%
%   Example:  Open a file in read-write mode and add a comment to the
%   primary array.
%       import matlab.io.*
%       srcFile = fullfile(matlabroot,'toolbox','matlab','demos','tst0012.fits');
%       copyfile(srcFile,'myfile.fits'); 
%       fileattrib('myfile.fits','+w'); 
%       fptr = fits.openFile('myfile.fits','readwrite');
%       fits.writeComment(fptr,'This is just a comment.');
%       fits.closeFile(fptr);
%
%   See also fits, createFile, closeFile.

%   Copyright 2011-2015 The MathWorks, Inc.

if nargin < 2
    mode = 'READONLY';
end

validateattributes(filename,{'char'},{'nonempty'},'openFile','FILENAME');
validateattributes(mode,    {'char'},{'nonempty'},'openFile','MODE');

mode = validatestring(mode,{'readonly','readwrite'});


% Get the full path name if it's on the path.
fid = fopen(filename,'r');
if fid == -1
    % The CFITSIO library allows the filename to be specified as
    % 'myfile.fits+3' or 'myfile.fits[extname]' in the call to openFile.
    % This will trip up fopen. Guard against this.
    try
        [filename, ~, hasExt] = matlab.io.fits.internal.resolveExtendedFileName(filename);
    catch ME
        throwAsCaller(ME);
    end
else
    filename = fopen(fid);
    fclose(fid);
end

switch(mode)
    case 'readonly'
        mode = matlab.io.fits.getConstantValue('READONLY');

    case 'readwrite'
        mode = matlab.io.fits.getConstantValue('READWRITE');

end


fptr = fitsiolib('open_file',filename,mode);

