function metadata = imjp2info(filename)
%IMJP2NFO Information about a JPEG 200 file.
%   METADATA = IMJP2INFO(FILENAME) returns a structure containing
%   information about the JPEG 2000 file specified by the string
%   FILENAME.  
%
%   See also IMFINFO.

%   Copyright 2008-2013 The MathWorks, Inc.

% Call the interface to the Kakadu library.
metadata = imjp2infoc(filename);

d = dir(filename);
metadata.Filename = filename;
metadata.FileModDate = datestr(d.datenum);
metadata.FileSize = d.bytes;

