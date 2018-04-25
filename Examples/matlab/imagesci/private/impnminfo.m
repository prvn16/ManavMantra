function info = impnminfo(filename)
%IMPNMINFO Get information about the image in a PPM/PGM/PBM file.
%
%   INFO = IMPNMINFO(FILENAME) returns information about the image
%   contained in a PPM, PGM or PBM file.  
%
%   PNM is not an image format by itself but means any of PPM, PGM, and PBM.
%
%   See also IMREAD, IMWRITE, IMFINFO.

%   The PNM formats PPM, PGM and PBM are described in the UNIX manual pages
%   ppm(5), pgm(5) and pbm(5) respectively.
%
% Author:	  Peter J. Acklam
% E-mail:	  pjacklam@online.no

%  Copyright 2001-2013 The MathWorks, Inc.

% Try to open the file for reading.
fid = fopen(filename, 'r');
assert(fid ~= -1, message('MATLAB:imagesci:validate:fileOpen', filename));

% Initialize universal structure fields to fix the order
info = initializeMetadataStruct('pnm', fid);

info.FormatSignature = [];
   
% Initialize PNM-specific structure fields to fix the order.

info.Encoding        = '';
info.MaxValue        = [];
info.ImageDataOffset = [];

% Look for the magic number (i.e., format signature).
[magicNumber, count] = fscanf(fid, '%c', 2);
if (count < 2)
    fclose(fid);
    error(message('MATLAB:imagesci:impnminfo:emptyMagicNumber'));
end
info.FormatSignature = magicNumber;
info.FormatVersion   = magicNumber;   

% Get the image format and encoding ('plain' is ascii, 'raw' is binary).
switch magicNumber
    case 'P1'
        info.Format	    = 'PBM';
        info.ColorType	= 'grayscale';	% black and white, actually
        info.Encoding	= 'ASCII';
    case 'P2'
        info.Format	    = 'PGM';
        info.ColorType	= 'grayscale';	% black and white, actually
        info.Encoding	= 'ASCII';
    case 'P3'
        info.Format	    = 'PPM';
        info.ColorType	= 'truecolor';
        info.Encoding	= 'ASCII';
    case 'P4'
        info.Format	    = 'PBM';
        info.ColorType	= 'grayscale';
        info.Encoding	= 'rawbits';
    case 'P5'
        info.Format	    = 'PGM';
        info.ColorType	= 'grayscale';
        info.Encoding	= 'rawbits';
    case 'P6'
        info.Format	    = 'PPM';
        info.ColorType	= 'truecolor';
        info.Encoding	= 'rawbits';
    otherwise
        fclose(fid);			% close file
        error(message('MATLAB:imagesci:impnminfo:invalidMagicNumber'));
end

% Read image size.
[header_data, count] = pnmgeti(fid, 2);
if count < 2
    fclose(fid);			% close file
    error(message('MATLAB:imagesci:impnminfo:unexpectedEOF'));
end

info.Width  = header_data(1);	% image width
info.Height = header_data(2);	% image height

% Read the maximum color-component value.  PBM images do not explicitly
% contain this value because it has to be 1. The maximum color component
% value of PGM and PPM images may be any positive integer so BitDepth
% might not be an integer!
if strcmp(info.Format, 'PBM')
    info.MaxValue = 1;
else
    [header_data, count] = pnmgeti(fid, 1);
    if count < 1
        fclose(fid);			% close file
        error(message('MATLAB:imagesci:impnminfo:maxValueTruncated'));
    end
    info.MaxValue = header_data(1);
end

info.BitDepth = log2(info.MaxValue + 1);
% Because truecolor images have 3 channels
if strcmp(info.ColorType,'truecolor')
    info.BitDepth = info.BitDepth * 3;
end

% Raw PNM images should have a single byte of whitespace between the
% image header and the pixel area.  Plain PNM images might have more
% whitespace and even comments but the main point in the plain case is
% that we are past the header.
info.ImageDataOffset = ftell(fid) + 1;

% We've got what we need, so close the file.
fclose(fid);
