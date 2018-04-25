function X = dpxread(filename)
%dpxread   Read DPX image.
%    X = DPXREAD(FILENAME) reads the image X from the DPX file FILENAME.
%    FILENAME can contain the absolute path to the file, the name of a file
%    on the MATLAB path, or a relative path. X will be a UINT8 or UINT16
%    array depending on the bit depth of the pixels in FILENAME.
%
%    Digital Picture Exchange (DPX) is an ANSI standard file format
%    commonly used for still frames storage in digital intermediate post-
%    production facilities and film labs.
%
%    Example:
%    % Read and visualize a 12-bit RGB image. The image needs to be scaled
%    % to span the 16-bit data range expected by imshow.
%    maxOfDataRange = 2^12 - 1;
%    scaleFactor = intmax('uint16') / maxOfDataRange;
%    RGB = dpxread('peppers.dpx');
%    figure
%    imshow(RGB * scaleFactor)
%
%    See also DPXINFO.

% Copyright 2014-2017 The MathWorks, Inc.

filename = matlab.images.internal.stringToChar(filename);

validateattributes(filename, {'char'}, {'nonempty', 'row'}, mfilename, 'filename', 1)

readImages = true;
X = parseDPX(filename, readImages);

end