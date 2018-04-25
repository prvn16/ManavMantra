function [info, exif_offset, ifd_idx] = imjpgbaselineinfo(fid)
%IMJPGBASELINEINFO Information about a JPEG file.
%   [INFO, EXIF_OFFSET, IDX] = IMJPGBASELINEINFO(FILENAME) returns a 
%   structure containing information about the JPEG file specified by the 
%   string FILENAME.  
%
%   EXIF_OFFSET is the byte position of the Exif IFD.  
%
%   Copyright 2012-2015 The MathWorks, Inc.

% This will point to the start of Exif metadata if it exists.

[info, exif_offset, ifd_idx] = matlab.io.internal.imagesci.imjpgbaselineinfo(fid);

