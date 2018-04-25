function setTileDim(fptr,tilesize)
%setTileDim set tile dimensions 
%   fits.setTileDim(FPTR,TILEDIMS) specifies the size of the image 
%   compression tiles to be used when creating a compressed image.
%
%   This function corresponds to the "fits_set_tile_dim" function in the
%   CFITSIO library C API.
%
%   Example:
%       import matlab.io.*
%       fptr = fits.createFile('myfile.fits');
%       fits.setCompressionType(fptr,'RICE_1');
%       fits.setTileDim(fptr,[64 128]);
%       fits.createImg(fptr,'byte_img',[256 512]);
%       data = ones(256,512,'uint8');
%       fits.writeImg(fptr,data);
%       fits.closeFile(fptr);
%       fitsdisp('myfile.fits','mode','full');
%
%   See also fits, setCompressionType.

%   Copyright 2011-2013 The MathWorks, Inc.
                                                                                                                 
validateattributes(fptr,{'uint64'},{'scalar'},'','FPTR');
validateattributes(tilesize,{'double'},{'row','positive','integer'},'','TILEDIMS');

switch(numel(tilesize))
    case {1,2}
        tilesize = fliplr(tilesize);
    otherwise
        tilesize = [tilesize(2) tilesize(1) tilesize(3:end)];
end

fitsiolib('set_tile_dim',fptr,tilesize);
