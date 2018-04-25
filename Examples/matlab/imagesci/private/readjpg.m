function [A,junk] = readjpg(filename)
%READJPG Read image data from a JPEG file.

%   Steven L. Eddins, June 1996
%   Copyright 1984-2013 The MathWorks, Inc.

info = imjpginfo(filename,true);
depth = info.BitDepth / info.NumberOfSamples;
if (depth <= 8)
  
    A = rjpg8c(filename);
    
elseif (depth <= 12)
  
    A = rjpg12c(filename);
    
elseif (depth <= 16)
  
    A = rjpg16c(filename);
    
else
  
    error(message('MATLAB:imagesci:readjpg:unsupportedJPEGBitDepth', depth))
    
end

junk = [];
