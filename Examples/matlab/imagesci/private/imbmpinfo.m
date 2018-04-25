function metadata = imbmpinfo(filename)
%IMBMPINFO Get information about the image in a BMP file.
%   METADATA = IMBMPINFO(FILENAME) returns information about
%   the image contained in a BMP file.
%
%   See also IMREAD, IMWRITE, IMFINFO.

%   Copyright 1984-2016 The MathWorks, Inc.

%   Required reading before editing this file: Encyclopedia of
%   Graphics File Formats, 2nd ed., pp. 572-591, pp. 630-650.

fid = fopen(filename, 'r', 'ieee-le');  % BMP files are little-endian
assert(fid ~= -1, message('MATLAB:imagesci:validate:fileOpen', filename));
cfid = onCleanup(@() fclose(fid));

metadata = initializeBMPInfoStruct(fid);

% Determine how to read the bitmap.
metadata.FormatSignature = getSignature(fid);

% Read the bitmap's info.
metadata = readBMPInfo(fid, metadata);

% Clean up and do post-processing.
metadata = postProcess(metadata);


%------------------------------------------------------------
function metadata = initializeBMPInfoStruct(fid)
%INITIALIZEBMPINFOSTRUCT  Create and initialize the metadata struct,
%fixing fields. 

% Initialize universal structure fields to fix the order
metadata = initializeMetadataStruct('bmp', fid);

% Initialize BMP-specific structure fields to fix the order
metadata.FormatSignature = [];
metadata.NumColormapEntries = [];
metadata.Colormap = [];
metadata.RedMask = [];
metadata.GreenMask = [];
metadata.BlueMask = [];


%------------------------------------------------------------
function signature = getSignature(fid)
%GETSIGNATURE  Get the file's format signature.
  
fseek(fid, 0, 'bof');
signature = char(fread(fid, 2, 'uint8')');

% The signature must have already been determined by ISBMP
% by this point.
assert(~isempty(signature), 'Signature cannot be empty.');



%------------------------------------------------------------
function metadata = readBMPInfo(fid, metadata)
%READBMPINFO  Read the metadata from the bitmap headers.
  
  
%
% Use the algorithm from Encyclopedia of Graphics File Formats,
% 2ed, pp. 584-585
%

switch metadata.FormatSignature
    case 'BM'

        % We have a single-image BMP file. It may be
        % a Windows or an OS/2 file.

        fseek(fid, 14, 'bof');
        headersize = fread(fid, 1, 'uint32');
        fseek(fid, 0, 'bof');

        if (isempty(headersize))
            error(message('MATLAB:imagesci:imbmpinfo:truncatedHeader'));
        end

        switch headersize
            case 12
                % win 2
                metadata = readWin2xInfo(fid, metadata);

            case {40, 56}
                % win 3
                % BITMAPV3INFOHEADER has the same structure as Windows V3
                % BMP header
                metadata = readWin3xInfo(fid, metadata);

            case 64 
                % OS/2 2.x
                metadata = readOS2v2Info(fid, metadata);

            case 108
                % win 4
                metadata = readWin4xInfo(fid, metadata);

            case 124
                % win 5;
                metadata = readWin5xInfo(fid, metadata);

            otherwise

                error(message('MATLAB:imagesci:imbmpinfo:unhandledHeaderSize', headersize));

        end

    otherwise

        error(message('MATLAB:imagesci:imbmpinfo:unhandledFormatSignature',...
            metadata.FormatSignature));

end



%------------------------------------------------------------
function metadata = readBMPFileHeader(fid, metadata)
%READBMPFILEHEADER  Read the BMPFileHeader structure.
  
fseek(fid, 2, 'cof');  % FileType (usually 'BM')
metadata.FileSize = fread(fid, 1, 'uint32');
fseek(fid, 4, 'cof');  % skip 2 reserved 16-bit words
metadata.ImageDataOffset = fread(fid, 1, 'uint32');



%------------------------------------------------------------
function metadata = readWin2xBitmapHeader(fid, metadata)
%READWIN2XBITMAPHEADER  Read the Win2xBitmapHeader structure.
  
% Version 2.x headers have UINT16-sized height and width.
metadata.BitmapHeaderSize = fread(fid, 1, 'uint32');
metadata.Width = fread(fid, 1, 'uint16');
metadata.Height = fread(fid, 1, 'uint16');
metadata.NumPlanes = fread(fid, 1, 'uint16');
metadata.BitDepth = fread(fid, 1, 'uint16');

if (isempty(metadata.Width) || isempty(metadata.Height))
    error(message('MATLAB:imagesci:imbmpinfo:truncatedBitmapHeader',2));
end

        

%------------------------------------------------------------
function metadata = readWin3xBitmapHeader(fid, metadata)
%READWIN3XBITMAPHEADER  Read the Win3xBitmapHeader structure.

% Version 3.x and later headers have UINT32-sized height and width.
metadata.BitmapHeaderSize = fread(fid, 1, 'uint32');
metadata.Width = fread(fid, 1, 'int32');
metadata.Height = fread(fid, 1, 'int32');
metadata.NumPlanes = fread(fid, 1, 'uint16');
metadata.BitDepth = fread(fid, 1, 'uint16');

if (isempty(metadata.Width) || isempty(metadata.Height))
    error(message('MATLAB:imagesci:imbmpinfo:truncatedBitmapHeader',3));
end

% CompressionType will get decoded later after we really know
% what type of bitmap we have.  It's a chicken and an egg problem.
metadata.CompressionType = fread(fid, 1, 'uint32');
metadata.CompressionType = decodeCompression(fid,metadata.CompressionType, ...
                                                   metadata.FormatVersion);



metadata.BitmapSize = fread(fid, 1, 'uint32');
metadata.HorzResolution = fread(fid, 1, 'int32');
metadata.VertResolution = fread(fid, 1, 'int32');
metadata.NumColorsUsed = fread(fid, 1, 'uint32');
metadata.NumImportantColors = fread(fid, 1, 'uint32');



%------------------------------------------------------------
function metadata = readWin4xBitmapHeader(fid, metadata)
%READWIN4XBITMAPHEADER  Read the Win4xBitmapHeader structure.

metadata = readWin3xBitmapHeader(fid, metadata);

metadata.RedMask = fread(fid, 1, 'uint32');
metadata.GreenMask = fread(fid, 1, 'uint32');
metadata.BlueMask = fread(fid, 1,  'uint32');
metadata.AlphaMask = fread(fid, 1, 'uint32');
metadata.ColorspaceType = decodeColorspaceType(fread(fid, 1, 'uint32'));
metadata.RedX = fread(fid, 1, 'int32');
metadata.RedY = fread(fid, 1, 'int32');
metadata.RedZ = fread(fid, 1, 'int32');
metadata.GreenX = fread(fid, 1, 'int32');
metadata.GreenY = fread(fid, 1, 'int32');
metadata.GreenZ = fread(fid, 1, 'int32');
metadata.BlueX = fread(fid, 1, 'int32');
metadata.BlueY = fread(fid, 1, 'int32');
metadata.BlueZ = fread(fid, 1, 'int32');
metadata.GammaRed = fread(fid, 1, 'uint32');
metadata.GammaGreen = fread(fid, 1, 'uint32');
metadata.GammaBlue = fread(fid, 1, 'uint32');

if (isequal(metadata.CompressionType, 'bitfields'))
    metadata.NumColormapEntries = 0;
    metadata.Colormap = [];
end



%------------------------------------------------------------
function metadata = readWin5xBitmapHeader(fid, metadata)
%READWIN5XBITMAPHEADER  Read the Win5xBitmapHeader structure.

metadata = readWin4xBitmapHeader(fid, metadata);

metadata.Intent = decodeIntent(fread(fid, 1, 'uint32'));
metadata.ProfileDataOffset = fread(fid, 1, 'uint32');
metadata.ProfileSize = fread(fid, 1, 'uint32');

fseek(fid, 4, 'cof'); % skip 4-byte reserved DWORD.



%------------------------------------------------------------
function compressionType = decodeCompression(fid,compNum, verName)
%DECODECOMPRESSION  Find the compression type given the header value.
  

switch compNum
    case 0
        compressionType = 'none';
        
    case 1
        compressionType = '8-bit RLE';
        
    case 2
        compressionType = '4-bit RLE';
        
    case 3
        if (isequal(verName, 'os2'))
            compressionType = 'Huffman 1D';
        else
            compressionType = 'bitfields';
        end
        
    case 4
        % Only valid for OS/2 2.x
        compressionType = '24-bit RLE';
        
    otherwise
        error(message('MATLAB:imagesci:imbmpinfo:unrecognizedCompression',compNum));
        
end



%------------------------------------------------------------
function metadata = readVersion2xColormap(fid, metadata)
%READVERSION2XCOLORMAP  Read colormap entries for version 2.x bitmaps.
  
metadata.NumColormapEntries = floor((metadata.ImageDataOffset - ftell(fid))/3);

if (metadata.NumColormapEntries > 0)
        
    [map,count] = fread(fid, metadata.NumColormapEntries*3, 'uint8');
    if (count ~= metadata.NumColormapEntries*3)
        msg = ferror(fid);
        error(message('MATLAB:imagesci:imfinfo:freadError','Colormap',msg));
    end

    map = reshape(map, 3, metadata.NumColormapEntries);
    metadata.Colormap = double(flipud(map)')/255;
    
end



%------------------------------------------------------------
function metadata  = readVersion3xColormap(fid, metadata)
%READVERSION3XCOLORMAP  Read colormap entries for version 3.x bitmaps.

metadata.NumColormapEntries = floor((metadata.ImageDataOffset - ftell(fid))/4);

if (metadata.NumColormapEntries > 0)

    [map,count] = fread(fid, metadata.NumColormapEntries*4, 'uint8');
    if (count ~= metadata.NumColormapEntries*4)
        msg = ferror(fid);
        error(message('MATLAB:imagesci:imfinfo:freadError','Colormap',msg));
    end

    map = reshape(map, 4, metadata.NumColormapEntries);
    metadata.Colormap = double(flipud(map(1:3,:))')/255;

end  



%------------------------------------------------------------
function metadata = readVersion3xMasks(fid, metadata)
%READVERSION3XMASKS  Read color masks for version 3 (NT) bitmaps.
  
metadata.NumColormapEntries = 0;
metadata.Colormap = [];

metadata.RedMask = fread(fid, 1, 'uint32');
metadata.GreenMask = fread(fid, 1, 'uint32');
metadata.BlueMask = fread(fid, 1, 'uint32');



%------------------------------------------------------------
function metadata = readWin2xInfo(fid, metadata)
%READWIN2XINFO  Read the metadata from a Win 2.x BMP.
  
metadata = readBMPFileHeader(fid, metadata);
metadata = readWin2xBitmapHeader(fid, metadata);
metadata.CompressionType = 'none';

metadata.FormatVersion = 'Version 2 (Microsoft Windows 2.x)';

metadata = readVersion2xColormap(fid, metadata);



%------------------------------------------------------------
function metadata = readWin3xInfo(fid, metadata)
%READWIN3XINFO  Read the metadata from a Win 3.x/NT BMP.
  
metadata.FormatVersion = 'Version 3';
metadata = readBMPFileHeader(fid, metadata);
metadata = readWin3xBitmapHeader(fid, metadata);
    
if (isequal(metadata.CompressionType, 'bitfields'))
    metadata.FormatVersion = 'Version 3 (Microsoft Windows NT)';
else
    metadata.FormatVersion = 'Version 3 (Microsoft Windows 3.x)';
end

if ((isequal(metadata.CompressionType, 'Version 3 (Microsoft Windows NT)')) && ...
    ((metadata.BitDepth == 16) || (metadata.BitDepth == 32)) && ...
    (~isequal(metadata.CompressionType,'bitfields')))
    
    error(message('MATLAB:imagesci:imbmpinfo:invalidBMPmetadata',3));
end
    
if (isequal(metadata.CompressionType, 'bitfields'))
    metadata = readVersion3xMasks(fid, metadata);
else
    metadata = readVersion3xColormap(fid, metadata);
end



%------------------------------------------------------------
function metadata  = readWin4xInfo(fid, metadata)
%READWIN4XINFO  Read the metadata from a Win 95 BMP.
  
metadata.FormatVersion = 'Version 4 (Microsoft Windows 95)';
metadata = readBMPFileHeader(fid, metadata);
metadata = readWin4xBitmapHeader(fid, metadata);

if (((metadata.BitDepth == 16) || (metadata.BitDepth == 32)) && ...
    (~strcmp(metadata.CompressionType,'bitfields')))
    error(message('MATLAB:imagesci:imbmpinfo:invalidBMPmetadata',4));
end

metadata = readVersion3xColormap(fid, metadata);



%------------------------------------------------------------
function metadata  = readWin5xInfo(fid, metadata)
%READWIN5XINFO  Read the metadata from a Win 2000 BMP.
  
metadata.FormatVersion = 'Version 5 (Microsoft Windows 2000)';
metadata = readBMPFileHeader(fid, metadata);
metadata = readWin5xBitmapHeader(fid, metadata);
metadata = readVersion3xColormap(fid, metadata);



%------------------------------------------------------------
function metadata = readOS2v2Info(fid, metadata)
%READOS2V2INFO  Read the metadata from an OS/2 v.2 BMP.

metadata.FormatVersion = 'OS/2 2.x';

% image data offset is at offset 10
fseek(fid,10,'bof');
metadata.ImageDataOffset = fread(fid,1,'uint32');

% Header size is next, always 64 for OS2 v2
metadata.BitmapHeaderSize = fread(fid,1,'uint32');

metadata.Width = fread(fid,1,'uint32');
metadata.Height = fread(fid,1,'uint32');
metadata.NumPlanes = fread(fid,1,'uint16');
metadata.BitDepth = fread(fid,1,'uint16');

compNum = fread(fid,1,'uint32');
metadata.CompressionType = decodeCompression(fid,compNum,'os2');

metadata.BitmapSize = fread(fid,1,'uint32');
metadata.HorzResolution = fread(fid, 1, 'uint32');
metadata.VertResolution = fread(fid, 1, 'uint32');
metadata.NumColorsUsed = fread(fid, 1, 'uint32');
metadata.NumImportantColors = fread(fid, 1, 'uint32');
units = fread(fid, 1, 'uint16');
if (isempty(units))
    error(message('MATLAB:imagesci:imbmpinfo:truncatedField','Units'));
end

if (units == 0)
    metadata.Units = 'pixels/meter';
else
    metadata.Units = 'unknown';
end
fseek(fid, 2, 'cof');  % skip 2-byte pad
metadata.Recording = fread(fid, 1, 'uint16');

halftoning = fread(fid, 1, 'uint16');
if (isempty(halftoning))
    error(message('MATLAB:imagesci:imbmpinfo:truncatedField','HalftoningAlgorithm'));
end

switch halftoning
case 0
    metadata.HalftoningAlgorithm = 'none';
        
case 1
    metadata.HalftoningAlgorithm = 'error diffusion';

case 2
    metadata.HalftoningAlgorithm = 'PANDA';
        
case 3
    metadata.HalftoningAlgorithm = 'super-circle';
    
otherwise
    metadata.HalftoningAlgorithm = 'unknown';
    
end

metadata.HalftoneField1 = fread(fid, 1, 'uint32');
metadata.HalftoneField2 = fread(fid, 1, 'uint32');

encoding = fread(fid, 1, 'uint32');
if (isempty(encoding))
    error(message('MATLAB:imagesci:imbmpinfo:truncatedField','ColorEncoding'));
end

if (encoding == 0)
    metadata.ColorEncoding = 'RGB';
else
    metadata.ColorEncoding = 'unknown';
end

metadata.ApplicationIdentifier = fread(fid, 1, 'uint32');

metadata.NumColormapEntries = floor((metadata.ImageDataOffset - ftell(fid))/4);
if (metadata.NumColormapEntries > 0)
    map = fread(fid, metadata.NumColormapEntries*4, 'uint8');
    map = reshape(map, 4, metadata.NumColormapEntries);
    metadata.Colormap = double(flipud(map(1:3,:))')/255;
end



%------------------------------------------------------------
function metadata = postProcess(metadata)
%POSTPROCESS  Perform some post processing and validity checking.
  
if (isempty(metadata.NumColormapEntries))
    metadata.NumColormapEntries = 0;
end

if (metadata.NumColormapEntries > 0)
    metadata.ColorType = 'indexed';
else
    if (metadata.BitDepth <= 8)
        metadata.ColorType = 'grayscale';
    else
        metadata.ColorType = 'truecolor';
    end
end

if (metadata.Width < 0)
    error(message('MATLAB:imagesci:imfinfo:badImageDimensions','BMP'));
end


%------------------------------------------------------------
function cstype_str = decodeColorspaceType(cstype_num)
%DECODECOLORSPACETYPE  Determine the colorspace type from a constant.

switch (cstype_num)
case 0
    cstype_str = 'Calibrated RGB';

case 1934772034
    cstype_str = 'sRGB';
    
case 1466527264
    cstype_str = 'Windows default';
    
case 1279872587
    cstype_str = 'Linked profile';
    
case 1296188740
    cstype_str = 'Embedded profile';
   
otherwise
    cstype_str = 'Unknown';
end



%------------------------------------------------------------
function intent_str = decodeIntent(intent_num)
%DECODEINTENT  Determine the rendering intent from a constant.

switch (intent_num)
case 0
    intent_str = 'None';
    
case 1
    intent_str = 'Graphic: Saturation';
    
case 2
    intent_str = 'Proof: Relative Colorimetric';

case 4
    intent_str = 'Picture: Perceptual';
    
case 8
    intent_str = 'Match: Absolute Colorimetric';
    
end

