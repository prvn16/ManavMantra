function hdrwrite(hdrImage, filename)
%HDRWRITE   Write Radiance .hdr file.
%    HDRWRITE(HDR, FILENAME) creates a Radiance .hdr file from HDR, a
%    single- or double-precision high dynamic range RGB image.  The .hdr
%    file with the name FILENAME uses run-length encoding to minimize file
%    size. 
%
%    See also HDRREAD, MAKEHDR, TONEMAP.

%   Copyright 2007-2017 The MathWorks, Inc.

validateattributes(hdrImage, {'single', 'double'}, ...
    {'finite', 'nonempty', 'nonnan', 'nonnegative', 'nonsparse', 'real'}, ...
    mfilename, 'HDR', 1);

filename = matlab.images.internal.stringToChar(filename);
validateattributes(filename, {'char'}, {'row'}, mfilename, 'FILENAME', 2);

if ((ndims(hdrImage) > 3) || (size(hdrImage, 3) ~= 3))
    error(message('images:hdrwrite:notRGB'))
end

width = size(hdrImage, 2);
if (width > 32767)
    error(message('images:hdrwrite:imageTooWide'))
end

% Convert the HDR RGB data to RBGE data.
rgbe = rgb2rgbe(permute(hdrImage, [2 1 3]));

% Write the RGBE data to the file.
[fid, msg] = fopen(filename, 'w');

if (fid < 1)
    error(message('images:hdrwrite:fileOpen', filename, msg))
end

oc = onCleanup(@() fclose(fid));
fprintf(fid, '#?RADIANCE\n');
fprintf(fid, '#Made with MATLAB\n');
fprintf(fid, 'FORMAT=32-bit_rle_rgbe\n');
fprintf(fid, '\n');
fprintf(fid, '-Y %d +X %d\n', size(hdrImage, 1), size(hdrImage, 2));

for row = 1:size(hdrImage,1)

    fwrite(fid, [2 2], 'uint8');
    fwrite(fid, width, 'uint16', 'ieee-be');

    for sample = 1:4
        dataStart = (row - 1) * width + 1;
        scanline = rleCoder(rgbe(dataStart:(dataStart + width - 1), sample), width);
        fwrite(fid, scanline, 'uint8');
    end

end
