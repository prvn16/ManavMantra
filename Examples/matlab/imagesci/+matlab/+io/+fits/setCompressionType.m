function setCompressionType(fptr,comptype)
%setCompressionType sets image compression type
%   setCompressionType(FPTR,COMPTYPE) specifies the image compression
%   algorithm that should be used when writing a FITS imge.
%
%   Supported values for COMPTYPE include:
%
%       'GZIP'
%       'GZIP2'
%       'RICE'
%       'PLIO'
%       'HCOMPRESS' 
%       'NOCOMPRESS'
%
%   This function corresponds to the "fits_set_compression_type" function
%   in the CFITSIO library C API.
%
%   Example:
%       import matlab.io.*
%       fptr = fits.createFile('myfile.fits');
%       fits.setCompressionType(fptr,'GZIP2');
%       fits.createImg(fptr,'long_img',[256 512]);
%       data = reshape(1:256*512,[256 512]);
%       data = int32(data);
%       fits.writeImg(fptr,data);
%       fits.closeFile(fptr);
%       fitsdisp('myfile.fits','mode','full');
%
%   See also fits, setTileDim, createImg.

%   Copyright 2011-2013 The MathWorks, Inc.
                                                                                                                 
validateattributes(fptr,{'uint64'},{'scalar'},'','FPTR');
validateattributes(comptype,{'char'},{'row'},'','COMPTYPE');

compschemes = {'GZIP','GZIP1','GZIP_1','GZIP2','GZIP_2', ...
    'RICE','RICE1', 'RICE_1', 'PLIO', 'PLIO1', 'PLIO_1', ...
    'HCOMPRESS','HCOMPRESS1','HCOMPRESS_1','NOCOMPRESS'};
comptype = validatestring(comptype,compschemes);

% Expand any shorthand values for the compression type.
switch(comptype)
    case {'GZIP','GZIP1','GZIP_1'}
        comptype = matlab.io.fits.getConstantValue('GZIP_1');
    case {'GZIP2','GZIP_2'}
        comptype = matlab.io.fits.getConstantValue('GZIP_2');
    case {'RICE','RICE1','RICE_1'}
        comptype = matlab.io.fits.getConstantValue('RICE_1');
    case {'PLIO','PLIO1','PLIO_1'}
        comptype = matlab.io.fits.getConstantValue('PLIO_1');
    case {'HCOMPRESS','HCOMPRESS1','HCOMPRESS_1'}
        comptype = matlab.io.fits.getConstantValue('HCOMPRESS_1');
    case 'NOCOMPRESS'
        comptype = matlab.io.fits.getConstantValue('NOCOMPRESS');
end
        

fitsiolib('set_compression_type',fptr,comptype);
