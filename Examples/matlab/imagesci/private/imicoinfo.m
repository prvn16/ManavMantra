function info = imicoinfo(filename)
%IMICOINFO Get information about the image in an ICO file.
%   INFO = IMICOINFO(FILENAME) returns information about
%   the image contained in an ICO file containing one or more
%   Microsoft Windows icon resources.  
%
%   See also IMREAD, IMWRITE, IMFINFO.

%   Copyright 1984-2013 The MathWorks, Inc.


fid = fopen(filename, 'r', 'ieee-le');  % ICO files are little-endian
assert(fid ~= -1, message('MATLAB:imagesci:validate:fileOpen', filename));

% Initialize universal structure fields to fix the order
info = initializeMetadataStruct('ico', fid);

% Initialize ICO-specific structure fields to fix the order
info.FormatSignature = [];
info.NumColormapEntries = [];
info.Colormap = [];

% Read the resource header to verify the correct type
sig = fread(fid, 2, 'uint16');
assert(~isempty(sig), message('MATLAB:imagesci:imfinfo:fileEmpty', filename));
assert(isequal(sig, [0; 1]), ...
    message('MATLAB:imagesci:imfinfo:badFormat', filename, 'ICO'));

% Find the number of icons in the file
imcount = fread(fid, 1, 'uint16');

for p = 1:imcount
    info(p).Filename = info(1).Filename;
    info(p).FileModDate = info(1).FileModDate;
    info(p).FileSize = info(1).FileSize;
    info(p).Format = 'ico';
    info(p).FormatSignature = sig';

    % Offset to the current icon directory entry
    idpos = 6 + 16*(p - 1);
    fseek(fid, idpos, 'bof');
    
    % Read the icon directory
    info(p).Width = fread(fid, 1, 'uint8');
    info(p).Height = fread(fid, 1, 'uint8');
    
    % Number of colors in the palette.  Strangely, this is unused.
    % Could be zero, and we must be ready for that.
    fread(fid,1,'uint8');

    % position past a reserved byte.
    fseek(fid,1,'cof');     
    
    % Number of planes and bits per pixel.  We don't need them here.
    fread(fid,1,'uint16');
    fread(fid,1,'uint16');

    info(p).ResourceSize = fread(fid, 1, 'uint32');
    info(p).ResourceDataOffset = fread(fid, 1, 'uint32');
    
    % A 256x256 image in a PNG file has its height and width marked as 0.
    % Additionally, an image of this dimension is stored as PNG image. So,
    % parse it as a PNG stream and not a BITMAP.
    if info(p).Width == 0 && info(p).Height == 0
        infoPNG = pnginfoc(filename, false, double(info(p).ResourceDataOffset));
        
        % As the information returned for PNG is different from that for
        % bitmaps, matching the 
        info(p).Width = 256;
        info(p).Height = 256;
        info(p).BitmapHeaderSize = [];
        info(p).NumPlanes = 1;
        info(p).BitDepth = uint16(infoPNG.BitDepth);
        info(p).CompressionType = infoPNG.Format;
        info(p).BitmapSize = uint32(double(info(p).Height) * double(info(p).Width) * (double(info(p).BitDepth)/8));
        info(p).NumColormapEntries = size(infoPNG.Colormap, 1);
        info(p).ColormapOffset = [];
        info(p).ColorType = infoPNG.ColorType;
        info(p).ImageDataOffset = info(p).ResourceDataOffset;
        info(p).Colormap = infoPNG.Colormap;
        continue;
    end

    % Start reading bitmap (DIB) header info.
    fseek(fid, info(p).ResourceDataOffset, 'bof');
    
    info(p).BitmapHeaderSize = fread(fid, 1, 'uint32');

    % Pixmap width and height (already have this).
    fread(fid,1,'uint32');
    fread(fid,1,'uint32');
    
    info(p).NumPlanes = fread(fid, 1, 'uint16'); % should be 1
    info(p).BitDepth = fread(fid, 1, 'uint16');
    
    % Compression, should always be zero.
    fread(fid,1,'uint32');
    info(p).CompressionType = 'none';
    
    info(p).BitmapSize = fread(fid, 1, 'uint32');

    % Skip over the horizontal and vertical resolution.
    fseek(fid,8,'cof');
    
    num_colors_in_palette = fread(fid,1,'uint32');
    
    if info(p).BitDepth == 32
        % No colormap
        info(p).NumColormapEntries = 0;
    else
        if num_colors_in_palette == 0 
            info(p).NumColormapEntries = 2^(info(p).BitDepth);
        else
            info(p).NumColormapEntries = num_colors_in_palette;
        end
    end
    
    % Skip over "number of important colors"
    fread(fid,1,'uint32');
    
    % Headers must be at least 40 bytes, but they may be larger.
    
    % If there's a colormap, skip ahead to it and read it.
    if info(p).NumColormapEntries == 0
        
        % It's truecolor, so the Colormap fields do not make sense here.
        info(p).ColormapOffset = [];
        info(p).ColorType = 'truecolor';
        
        info(p).ImageDataOffset = info(p).ResourceDataOffset + ...
            info(p).BitmapHeaderSize;
    else
        
        info(p).ColormapOffset = info(p).ResourceDataOffset + ...
            info(p).BitmapHeaderSize;
        
        fseek(fid, info(p).ColormapOffset, 'bof');
        
        % Read the RGBQUAD colormap: [blue green red reserved]
        [data, count] = fread(fid, (info(p).NumColormapEntries)*4, 'uint8');
        
        if (count ~= info(p).NumColormapEntries*4)
            msg = ferror(fid);
            fclose(fid);
            error(message('MATLAB:imagesci:imfinfo:freadError','COLORMAP',msg));
        end
        
        % Throw away the reserved byte, swap red and blue, and rescale
        data = reshape(data, 4, info(p).NumColormapEntries)';
        cmap = data(:,1:3);
        cmap = fliplr(cmap);
        cmap = cmap ./ 255;
        
        info(p).Colormap = cmap;
        info(p).ColorType = 'indexed';
        info(p).ImageDataOffset = ftell(fid);
    end
   
    
    % Other validity checks
    if ((info(p).Width < 0) || (info(p).Height < 0))
        fclose(fid);
        error(message('MATLAB:imagesci:imfinfo:badImageDimensions','ICO'));
    end
end

fclose(fid);
