function [outDims, outNumDims] = getImageSize(filename)
%GETIMAGESIZE Internal function which returns the size and the number of 
%dimensions of the input file.

% Copyright 2015 The MathWorks, Inc.

info = matlab.io.internal.imagesci.imjpginfo(filename,true);

% RGB or Grayscale
if info.NumberOfSamples == 3
    outDims = [info.Height info.Width 3];
    outNumDims = 3;
else
    outDims = [info.Height info.Width];
    outNumDims = 2;
end

end

